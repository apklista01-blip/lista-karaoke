import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_client.dart';

/// Serviço de registro de acesso ao app.
///
/// Gera/recupera um identificador único por dispositivo (APK e Web)
/// e insere uma linha na tabela "acessos" do Supabase a cada abertura,
/// permitindo ao admin consultar estatísticas de uso (diário, semanal,
/// mensal).
///
/// IMPORTANTE: a chamada é protegida com try/catch. Se a tabela
/// "acessos" não existir ou não houver permissão, o app simplesmente
/// ignora o erro e continua funcionando normalmente.
class AccessLog {
  static const String _deviceKey = 'device_id_v1';

  /// Gera ou recupera o id único deste dispositivo/navegador.
  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceKey);
    if (id == null || id.isEmpty) {
      id = _generateDeviceId();
      await prefs.setString(_deviceKey, id);
    }
    return id;
  }

  /// Gera um id aleatório único.
  static String _generateDeviceId() {
    final rand = Random();
    final bytes = List.generate(16, (_) => rand.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final now = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    return '$hex-$now';
  }

  /// Registra a abertura do app na tabela "acessos".
  ///
  /// Nunca lança exceções para o chamador (usa try/catch interno).
  static Future<void> registrarAcesso() async {
    try {
      final deviceId = await _getDeviceId();
      if (deviceId.isEmpty) return;

      final client = SupabaseClientFactory.instance;
      await client.from('acessos').insert({'dispositivo_id': deviceId});
    } catch (_) {
      // Silencioso: se não houver tabela/permissão/rede, não quebra o app.
    }
  }
}
