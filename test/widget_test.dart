// Teste básico de smoke do app karaokê.
//
// Como a HomePage faz chamadas de rede para o Supabase, este teste não
// inicializa o app completo. Ele apenas valida que o modelo SongModel
// funciona corretamente com a conversão de mapas.

import 'package:flutter_test/flutter_test.dart';

import 'package:lista_karaoke_online/models/song_model.dart';

void main() {
  test('SongModel.fromMap converte corretamente', () {
    final song = SongModel.fromMap({
      'id': 'abc-123',
      'numero': 70,
      'cantor': 'PETTER FERRAZ',
      'musica': 'Amor ou o Litrão',
      'trecho': 'Eu achei que eu bebia bem',
      'letra_completa': 'Letra completa aqui',
    });

    expect(song.id, 'abc-123');
    expect(song.numero, 70);
    expect(song.cantor, 'PETTER FERRAZ');
    expect(song.musica, 'Amor ou o Litrão');
    expect(song.trecho, 'Eu achei que eu bebia bem');
    expect(song.letraCompleta, 'Letra completa aqui');
  });

  test('SongModel.fromMap com letra_completa nula', () {
    final song = SongModel.fromMap({
      'id': '1',
      'numero': 100,
      'cantor': 'GRUPO',
      'musica': 'HOJE VOU PAGODEAR',
      'trecho': '',
    });

    expect(song.letraCompleta, isNull);
  });
}
