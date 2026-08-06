/// Modelo de uma música do catálogo de karaokê.
class SongModel {
  final String id;
  final int numero;
  final String cantor;
  final String musica;
  final String trecho;
  final String? letraCompleta;

  const SongModel({
    required this.id,
    required this.numero,
    required this.cantor,
    required this.musica,
    required this.trecho,
    this.letraCompleta,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    String parseString(dynamic v) => (v ?? '').toString();

    final numero = parseInt(map['numero']);

    return SongModel(
      // O schema real não possui coluna 'id'; usa 'numero' como identificador.
      id: map['id']?.toString() ?? numero.toString(),
      numero: numero,
      cantor: parseString(map['cantor']),
      musica: parseString(map['musica']),
      trecho: parseString(map['trecho']),
      letraCompleta: map['letra_completa']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'cantor': cantor,
      'musica': musica,
      'trecho': trecho,
      'letra_completa': letraCompleta,
    };
  }
}
