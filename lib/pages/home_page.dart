import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../core/supabase_client.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';
import 'admin_login_page.dart';
import 'song_detail_page.dart';

/// Página inicial: catálogo de músicas com busca.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  Future<List<SongModel>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchSongs('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _future = _fetchSongs(value.trim());
      });
    });
  }

  /// Remove acentos e normaliza a string para busca "branda".
  String _normalize(String input) {
    const withAccents = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const withoutAccents = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
    final buffer = StringBuffer();
    for (final rune in input.split('')) {
      final idx = withAccents.indexOf(rune);
      buffer.write(idx >= 0 ? withoutAccents[idx] : rune);
    }
    return buffer.toString().toLowerCase();
  }

  /// Carrega TODAS as músicas do catálogo usando paginação.
  ///
  /// O PostgREST limita cada consulta a 1000 linhas, então fazemos um loop
  /// com ranges para trazer o catálogo completo e depois filtramos em memória.
  Future<List<SongModel>> _fetchSongs(String query) async {
    final client = SupabaseClientFactory.instance;
    const fields = 'numero, cantor, musica, trecho, letra_completa';
    const pageSize = 1000;

    var from = 0;
    final all = <SongModel>[];

    while (true) {
      final to = from + pageSize - 1;
      final response = await client
          .from('songs')
          .select(fields)
          .order('numero', ascending: true)
          .range(from, to);

      final list = (response as List?) ?? const [];
      if (list.isEmpty) break;

      all.addAll(list.map((e) => SongModel.fromMap(e as Map<String, dynamic>)));

      if (list.length < pageSize) break;
      from += pageSize;
    }

    final normalizedQuery = _normalize(query).trim();
    if (normalizedQuery.isEmpty) return all;

    // Busca branda: ignora maiúsculas e acentos.
    return all.where((song) {
      return _normalize(song.cantor).contains(normalizedQuery) ||
          _normalize(song.musica).contains(normalizedQuery) ||
          song.numero.toString().contains(normalizedQuery);
    }).toList();
  }

  /// Abre a tela de detalhes de uma música.
  void _openDetail(BuildContext context, SongModel song) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SongDetailPage(song: song)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KARAOKE CABANA DONA ANGELA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Área do Admin',
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AdminLoginPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar por número, cantor ou música...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<SongModel>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitFadingCircle(
                          color: Colors.pinkAccent,
                          size: 48,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Erro ao carregar músicas.\n'
                            'Verifique a conexão com o Supabase e as '
                            'permissões (RLS).\n\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final songs = snapshot.data ?? const <SongModel>[];
                    if (songs.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma música encontrada.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: songs.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SongCard(
                          song: song,
                          onTap: () => _openDetail(context, song),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
