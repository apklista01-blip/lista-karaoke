import 'package:flutter/material.dart';

import '../core/favorites_store.dart';
import '../core/song_cache.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';
import 'song_detail_page.dart';

/// Página que lista as músicas marcadas como favoritas.
///
/// Carrega o catálogo a partir do cache local (o mesmo que alimenta a busca
/// da HomePage) e filtra apenas os números presentes nos favoritos.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _loading = true;
  List<SongModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega os favoritos juntando o cache local com a lista de números.
  Future<void> _loadFavorites() async {
    setState(() => _loading = true);

    final favSet = await FavoritesStore.load();
    final cached = await SongCache.load();

    List<SongModel> result = [];
    if (cached != null) {
      result = cached
          .where((s) => favSet.contains(s.numero))
          .toList()
        ..sort((a, b) => a.numero.compareTo(b.numero));
    }

    if (!mounted) return;
    setState(() {
      _favorites = result;
      _loading = false;
    });
  }

  /// Abre a tela de detalhes de uma música.
  void _openDetail(SongModel song) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SongDetailPage(song: song)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Você ainda não tem músicas favoritas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Toque no coração de uma música para favoritá-la.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _favorites.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final song = _favorites[index];
        return SongCard(
          song: song,
          isFavorite: true,
          onFavoriteToggle: () async {
            await FavoritesStore.toggle(song.numero);
            if (!mounted) return;
            final favSet = FavoritesStore.current;
            setState(() {
              _favorites = _favorites
                  .where((s) => favSet.contains(s.numero))
                  .toList();
            });
          },
          onTap: () => _openDetail(song),
        );
      },
    );
  }
}

