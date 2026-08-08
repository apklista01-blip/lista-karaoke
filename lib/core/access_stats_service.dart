import '../models/acesso_stats.dart';
import 'supabase_client.dart';

/// Serviço de consulta das estatísticas de uso do app.
///
/// Consulta a tabela "acessos" no Supabase usando agregações SQL
/// (COUNT DISTINCT por dispositivo) para os períodos: hoje, semana
/// (7 dias), mês (30 dias), total e histórico por dia.
class AccessStatsService {
  /// Busca as estatísticas de acessos.
  ///
  /// Retorna [AcessoStats.vazio] em caso de erro (ex.: tabela não criada
  /// ou sem permissão), para não quebrar o painel do admin.
  static Future<AcessoStats> fetch() async {
    try {
      final client = SupabaseClientFactory.instance;

      // Contador de acessos únicos por dispositivo nos períodos.
      final response = await client.rpc('stats_acessos');

      if (response is Map<String, dynamic>) {
        return AcessoStats(
          hoje: (response['hoje'] as num?)?.toInt() ?? 0,
          semana: (response['semana'] as num?)?.toInt() ?? 0,
          mes: (response['mes'] as num?)?.toInt() ?? 0,
          total: (response['total'] as num?)?.toInt() ?? 0,
          porDia: _parsePorDia(response['por_dia']),
        );
      }

      return AcessoStats.vazio();
    } catch (_) {
      return AcessoStats.vazio();
    }
  }

  /// Converte a lista de { data, total } vinda da RPC.
  static List<Map<String, dynamic>> _parsePorDia(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
