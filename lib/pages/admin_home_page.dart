import 'package:flutter/material.dart';

import '../core/supabase_client.dart';
import '../models/song_model.dart';
import '../widgets/loading_button.dart';

/// Painel do administrador com três recursos:
/// 1. Incluir nova música
/// 2. Buscar / Corrigir / Excluir música
/// 3. Enviar mensagem para os usuários
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  // ---- Incluir música ----
  final _addNumeroCtrl = TextEditingController();
  final _addCantorCtrl = TextEditingController();
  final _addMusicaCtrl = TextEditingController();
  bool _adding = false;
  String? _addMessage;

  // ---- Buscar / Corrigir / Excluir ----
  final _searchCtrl = TextEditingController();
  List<SongModel> _searchResults = [];
  bool _searching = false;
  String? _searchMessage;

  // ---- Mensagem ----
  final _msgCtrl = TextEditingController();
  bool _sendingMsg = false;
  String? _msgResult;

  @override
  void dispose() {
    _addNumeroCtrl.dispose();
    _addCantorCtrl.dispose();
    _addMusicaCtrl.dispose();
    _searchCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await SupabaseClientFactory.instance.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ============================================================
  // 1) INCLUIR MÚSICA
  // ============================================================
  Future<void> _addSong() async {
    final numero = int.tryParse(_addNumeroCtrl.text.trim());
    final cantor = _addCantorCtrl.text.trim();
    final musica = _addMusicaCtrl.text.trim();

    if (numero == null || numero <= 0) {
      setState(() => _addMessage = 'Informe um número de música válido.');
      return;
    }
    if (cantor.isEmpty || musica.isEmpty) {
      setState(() => _addMessage = 'Informe o artista e o nome da música.');
      return;
    }

    setState(() {
      _adding = true;
      _addMessage = null;
    });

    try {
      final client = SupabaseClientFactory.instance;
      await client.from('songs').insert({
        'numero': numero,
        'cantor': cantor,
        'musica': musica,
        'trecho': 'Trecho não informado',
        'letra_completa': null,
      });

      if (!mounted) return;
      setState(() {
        _addMessage = '✅ Música $numero incluída com sucesso!';
        _addNumeroCtrl.clear();
        _addCantorCtrl.clear();
        _addMusicaCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _addMessage = '❌ Erro ao incluir: $e');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  // ============================================================
  // 2) BUSCAR / CORRIGIR / EXCLUIR
  // ============================================================
  Future<void> _searchSongs() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _searching = true;
      _searchMessage = null;
    });

    try {
      final client = SupabaseClientFactory.instance;
      final numero = int.tryParse(query);

      // Busca por número exato, ou por texto (cantor/música) via ILIKE
      final response = await client
          .from('songs')
          .select('numero, cantor, musica, trecho, letra_completa')
          .or(
            numero != null
                ? 'numero.eq.$numero, cantor.ilike.%$query%, musica.ilike.%$query%'
                : 'cantor.ilike.%$query%, musica.ilike.%$query%',
          )
          .order('numero', ascending: true)
          .limit(50);

      final list = (response as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _searchResults = list
            .map((e) => SongModel.fromMap(e as Map<String, dynamic>))
            .toList();
        if (_searchResults.isEmpty) {
          _searchMessage = 'Nenhuma música encontrada para "$query".';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searchMessage = '❌ Erro na busca: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  /// Abre um diálogo para corrigir (editar) uma música.
  Future<void> _editSong(SongModel song) async {
    final numeroCtrl = TextEditingController(text: song.numero.toString());
    final cantorCtrl = TextEditingController(text: song.cantor);
    final musicaCtrl = TextEditingController(text: song.musica);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corrigir Música'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Artista',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: musicaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome da Música',
                  prefixIcon: Icon(Icons.music_note),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    final numero = int.tryParse(numeroCtrl.text.trim());
    if (numero == null || numero <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Número inválido.')));
      return;
    }

    try {
      final client = SupabaseClientFactory.instance;
      await client
          .from('songs')
          .update({
            'numero': numero,
            'cantor': cantorCtrl.text.trim(),
            'musica': musicaCtrl.text.trim(),
          })
          .eq('numero', song.numero);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Música corrigida!')));
      await _searchSongs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Erro ao corrigir: $e')));
    }
  }

  /// Exclui uma música (com confirmação).
  Future<void> _deleteSong(SongModel song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Música'),
        content: Text(
          'Excluir a música ${song.numero} - ${song.musica} de ${song.cantor}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final client = SupabaseClientFactory.instance;
      await client.from('songs').delete().eq('numero', song.numero);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🗑️ Música excluída!')));
      await _searchSongs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Erro ao excluir: $e')));
    }
  }

  // ============================================================
  // 3) ENVIAR MENSAGEM
  // ============================================================
  Future<void> _sendMessage() async {
    final conteudo = _msgCtrl.text.trim();
    if (conteudo.isEmpty) {
      setState(() => _msgResult = 'Digite a mensagem antes de enviar.');
      return;
    }

    setState(() {
      _sendingMsg = true;
      _msgResult = null;
    });

    try {
      final client = SupabaseClientFactory.instance;
      final user = client.auth.currentUser;
      await client.from('mensagens').insert({
        'conteudo': conteudo,
        'ativa': true,
        'admin_uid': user?.id,
      });

      if (!mounted) return;
      setState(() {
        _msgResult = '✅ Mensagem enviada aos usuários!';
        _msgCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _msgResult = '❌ Erro ao enviar: $e');
    } finally {
      if (mounted) setState(() => _sendingMsg = false);
    }
  }

  // ============================================================
  // BUILD: NAVEGAÇÃO ENTRE MENUS
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Menu horizontal de navegação
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.add),
                    label: Text('Incluir'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.search),
                    label: Text('Buscar'),
                  ),
                  ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.campaign),
                    label: Text('Mensagem'),
                  ),
                ],
                selected: {_currentIndex},
                onSelectionChanged: (selection) =>
                    setState(() => _currentIndex = selection.first),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildAddPanel(),
                  _buildSearchPanel(),
                  _buildMessagePanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Painel 1: Incluir música ----
  Widget _buildAddPanel() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Incluir nova música no catálogo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addNumeroCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Número da música',
              prefixIcon: Icon(Icons.tag),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addCantorCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome do artista',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addMusicaCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome da música',
              prefixIcon: Icon(Icons.music_note),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_addMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_addMessage!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
          ],
          LoadingButton(
            loading: _adding,
            label: 'Enviar para a lista',
            icon: Icons.send,
            onPressed: _addSong,
          ),
        ],
      ),
    );
  }

  // ---- Painel 2: Buscar / Corrigir / Excluir ----
  Widget _buildSearchPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => _searchSongs(),
                  decoration: const InputDecoration(
                    hintText: 'Número, artista ou música...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Buscar',
                icon: _searching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                onPressed: _searching ? null : _searchSongs,
              ),
            ],
          ),
        ),
        if (_searchMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _searchMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Digite um termo e toque em Buscar.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final song = _searchResults[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(song.numero.toString()),
                        ),
                        title: Text(
                          song.musica,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.cantor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Corrigir',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editSong(song),
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () => _deleteSong(song),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---- Painel 3: Enviar mensagem ----
  Widget _buildMessagePanel() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enviar mensagem para os usuários do app',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'A mensagem aparecerá como um aviso no topo da tela inicial.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgCtrl,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Digite a mensagem...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          if (_msgResult != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_msgResult!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
          ],
          LoadingButton(
            loading: _sendingMsg,
            label: 'Enviar mensagem',
            icon: Icons.campaign,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
