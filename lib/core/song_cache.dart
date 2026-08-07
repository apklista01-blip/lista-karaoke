import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/song_model.dart';

/// Serviço de cache local da lista de músicas.
///
/// Salva o catálogo completo em formato JSON no armazenamento do dispositivo
/// (via `shared_preferences`), permitindo que a busca funcione de forma
/// instantânea mesmo antes de carregar do Supabase, ou sem conexão.
class SongCache {
  static const String _key = 'song_cache_v1';
  static const String _updatedAtKey = 'song_cache_updated_at_v1';

  /// Salva a lista completa de músicas no cache local.
  static Future<void> save(List<SongModel> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final json = songs.map((s) => s.toMap()).toList();
    await prefs.setString(_key, jsonEncode(json));
    await prefs.setString(_updatedAtKey, DateTime.now().toIso8601String());
  }

  /// Carrega a lista de músicas salvas no cache local.
  ///
  /// Retorna `null` caso não exista cache salvo anteriormente.
  static Future<List<SongModel>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => SongModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Retorna a data/hora da última atualização do cache, se houver.
  static Future<DateTime?> lastUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_updatedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
