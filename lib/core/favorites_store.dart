import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de persistência local dos favoritos.
///
/// Salva um conjunto de números de música no armazenamento do dispositivo
/// (via `shared_preferences`), permitindo que o usuário marque/desmarque
/// músicas como favoritas e que elas permaneçam salvas entre sessões.
class FavoritesStore {
  static const String _key = 'favorites_v1';

  /// Mantém a lista de favoritos em memória para leitura rápida.
  static Set<int> _cache = <int>{};

  /// Carrega os números das músicas favoritas salvas.
  ///
  /// Retorna um `Set<int>` vazio caso ainda não existam favoritos salvos.
  static Future<Set<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _cache = <int>{};
      return _cache;
    }

    try {
      final numbers = raw
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      _cache = numbers;
    } catch (_) {
      _cache = <int>{};
    }
    return _cache;
  }

  /// Retorna o conjunto de favoritos carregado em memória.
  static Set<int> get current => _cache;

  /// Verifica se um número de música está nos favoritos.
  static bool isFavorite(int numero) => _cache.contains(numero);

  /// Alterna o estado de favorito do número informado e persiste.
  ///
  /// Retorna `true` se a música passou a ser favorita, `false` se foi removida.
  static Future<bool> toggle(int numero) async {
    if (!_cache.remove(numero)) {
      _cache.add(numero);
      await _save();
      return true;
    }
    await _save();
    return false;
  }

  /// Remove todos os favoritos.
  static Future<void> clear() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Persiste a lista de favoritos no armazenamento local.
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final joined = _cache.toList()..sort();
    await prefs.setString(_key, joined.join(','));
  }
}

