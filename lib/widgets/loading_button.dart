import 'package:flutter/material.dart';

/// Botão com estado de carregamento (spinner) reutilizável.
class LoadingButton extends StatelessWidget {
  final bool loading;
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.loading,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color ?? scheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.check),
      label: Text(
        loading ? 'Aguarde...' : label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
