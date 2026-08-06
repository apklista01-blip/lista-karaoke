/// Modelo de uma mensagem enviada pelo admin aos usuários do app.
class MensagemModel {
  final int id;
  final String conteudo;
  final bool ativa;
  final DateTime criadaEm;

  const MensagemModel({
    required this.id,
    required this.conteudo,
    required this.ativa,
    required this.criadaEm,
  });

  factory MensagemModel.fromMap(Map<String, dynamic> map) {
    return MensagemModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      conteudo: (map['conteudo'] ?? '').toString(),
      ativa: (map['ativa'] ?? true) == true,
      criadaEm:
          DateTime.tryParse((map['criada_em'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conteudo': conteudo,
      'ativa': ativa,
      'criada_em': criadaEm.toIso8601String(),
    };
  }
}
