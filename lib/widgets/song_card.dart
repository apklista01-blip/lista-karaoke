import 'package:flutter/material.dart';

import '../models/song_model.dart';

/// Card exibindo um resumo de uma música.
class SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Determina se o ícone de favorito deve ser exibido.
    final showFavorite = isFavorite != null && onFavoriteToggle != null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  song.numero.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.musica,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.cantor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showFavorite) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: isFavorite!
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos',
                  icon: Icon(
                    isFavorite! ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite!
                        ? Colors.redAccent
                        : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  onPressed: onFavoriteToggle,
                ),
                const SizedBox(width: 4),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

