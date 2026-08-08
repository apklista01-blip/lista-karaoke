/// Resultado das estatísticas de uso do app.
///
/// Contém os contadores de acessos únicos (por dispositivo) em
/// diferentes períodos, além do histórico diário.
class AcessoStats {
  final int hoje;
  final int semana;
  final int mes;
  final int total;
  final List<Map<String, dynamic>> porDia; // [{data: 'YYYY-MM-DD', total: int}]

  const AcessoStats({
    required this.hoje,
    required this.semana,
    required this.mes,
    required this.total,
    required this.porDia,
  });

  factory AcessoStats.vazio() => const AcessoStats(
    hoje: 0,
    semana: 0,
    mes: 0,
    total: 0,
    porDia: <Map<String, dynamic>>[],
  );
}
