import 'package:flutter/material.dart';

/// Mixin for forms that need discard confirmation
/// Handles the back button and WillPopScope
mixin DiscardFormMixin<T extends StatefulWidget> on State<T> {
  /// Track if form has unsaved changes
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  /// Call this when form data changes
  void markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  /// Call this when form is saved successfully
  void markAsSaved() {
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  /// Override this to customize the dialog
  Future<bool> showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('¿Descartar cambios?'),
          ],
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que deseas descartarlos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Call this to handle back navigation
  Future<bool> handleBackNavigation() async {
    if (_hasUnsavedChanges) {
      return await showDiscardDialog();
    }
    return true;
  }

  /// Wrap your scaffold with this to handle back button
  Widget buildWithDiscardProtection({required Widget child}) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldDiscard = await showDiscardDialog();
        if (shouldDiscard && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}

/// Form field wrapper that tracks changes
class TrackedFormField extends StatelessWidget {
  final Widget child;
  final VoidCallback onChanged;

  const TrackedFormField({
    super.key,
    required this.child,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: (notification) {
        // Track any changes
        onChanged();
        return false;
      },
      child: child,
    );
  }
}

/// TextFormField with change tracking
class TrackedTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const TrackedTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
