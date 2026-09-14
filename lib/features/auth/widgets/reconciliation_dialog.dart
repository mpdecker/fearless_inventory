import 'package:flutter/material.dart';

import '../../../core/services/cloud_backup_service.dart';

/// Shown whenever `CloudSyncNotifier` detects that the cloud backup and
/// this device's data disagree. Never silently resolves either way — one
/// of the two buttons must be tapped for anything to change; dismissing
/// the dialog (tap outside, back button) leaves the conflict unresolved
/// and it reappears at the next check (sign-in, or opening Account).
class ReconciliationDialog extends StatefulWidget {
  final DateTime remoteUpdatedAt;
  final DateTime? localBackedUpAt;
  final Future<void> Function(String passphrase) onUseCloudBackup;
  final VoidCallback onKeepLocalData;

  const ReconciliationDialog({
    super.key,
    required this.remoteUpdatedAt,
    required this.localBackedUpAt,
    required this.onUseCloudBackup,
    required this.onKeepLocalData,
  });

  @override
  State<ReconciliationDialog> createState() => _ReconciliationDialogState();
}

class _ReconciliationDialogState extends State<ReconciliationDialog> {
  final _passphraseController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _submit() async {
    final passphrase = _passphraseController.text;
    if (passphrase.isEmpty) {
      setState(() => _error = 'Enter the passphrase used for that backup.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.onUseCloudBackup(passphrase);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on CloudBackupUnreachable {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = "Couldn't reach the cloud backup. Check your connection and try again.";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Could not decrypt with that passphrase.';
      });
    }
  }

  void _keepLocal() {
    widget.onKeepLocalData();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localLabel = widget.localBackedUpAt == null
        ? 'This device has no earlier backup'
        : "This device's data from ${_formatDate(widget.localBackedUpAt!)}";

    return AlertDialog(
      title: const Text('Data mismatch found'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cloud backup from ${_formatDate(widget.remoteUpdatedAt)}'),
          const SizedBox(height: 4),
          Text(localLabel),
          const SizedBox(height: 16),
          TextField(
            controller: _passphraseController,
            obscureText: true,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Passphrase for the cloud backup',
            ),
            onSubmitted: (_) => !_isSubmitting ? _submit() : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _keepLocal,
          child: const Text("Keep this device's data"),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Use cloud backup'),
        ),
      ],
    );
  }
}
