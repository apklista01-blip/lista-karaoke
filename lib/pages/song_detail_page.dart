import 'package:flutter/material.dart';

import '../models/song_model.dart';

/// Tela de detalhes de uma música: mostra número, cantor, música,
/// trecho em destaque e a letra completa (com rolagem).
class SongDetailPage extends StatelessWidget {
  final SongModel song;

  const SongDetailPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasTrecho = song.trecho.trim().isNotEmpty;
    final hasLetra =
        song.letraCompleta != null && song.letraCompleta!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('Música ${song.numero}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Número em destaque
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    song.numero.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Música
              Text(
                song.musica,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),

              // Cantor
              Text(
                song.cantor,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Trecho em destaque
              if (hasTrecho) ...[
                Text(
                  'Trecho',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    song.trecho,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Letra completa
              if (hasLetra) ...[
                Text(
                  'Letra Completa',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    song.letraCompleta!,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ],

              // Sem conteúdo extra
              if (!hasTrecho && !hasLetra)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Nenhum trecho ou letra disponível para esta música.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
