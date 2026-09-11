import 'package:flutter/material.dart';

import '../../../core/database/connection/connection_stub.dart'
    if (dart.library.html) '../../../core/database/connection/connection_web.dart'
    if (dart.library.io) '../../../core/database/connection/connection_native.dart'
    as conn;
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';

/// Web-only gate shown before any recovery data is readable.
///
/// The web build has no OS keystore to transparently hold a per-device
/// encryption key (see native's `KeyService`), so the user's own passphrase
/// *is* the key — entered here, held only in memory for the session, and
/// never persisted anywhere. Losing it means losing this browser's data:
/// there is no recovery path, by design.
///
/// Replaces the PIN/biometric lock entirely on web (see [BootstrapShell]) —
/// one true secret instead of two parallel ones.
class WebPassphraseScreen extends StatefulWidget {
  final void Function(AppDatabase database) onUnlocked;

  const WebPassphraseScreen({super.key, required this.onUnlocked});

  @override
  State<WebPassphraseScreen> createState() => _WebPassphraseScreenState();
}

enum _Phase { loading, create, unlock, opening }

class _WebPassphraseScreenState extends State<WebPassphraseScreen> {
  _Phase _phase = _Phase.loading;
  String? _error;

  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _minLength = 8;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final exists = await conn.webDatabaseExists();
    if (!mounted) return;
    setState(() => _phase = exists ? _Phase.unlock : _Phase.create);
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _phase = _Phase.opening;
      _error = null;
    });

    final passphrase = _passphraseController.text;
    final db = AppDatabase(passphrase);
    try {
      // Forces a real page read — a wrong passphrase fails here, not on
      // PRAGMA key itself (SQLite/SQLCipher only detects a bad key once it
      // actually tries to decrypt a page).
      await db.customSelect('SELECT 1 FROM sqlite_master LIMIT 1').get();
    } catch (_) {
      await db.close();
      if (!mounted) return;
      setState(() {
        _phase = _Phase.unlock;
        _error = 'Incorrect passphrase.';
      });
      return;
    }

    widget.onUnlocked(db);
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.loading) {
      return const _Scaffold(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.cyanSecondary),
        ),
      );
    }

    final isCreate = _phase == _Phase.create;
    final isOpening = _phase == _Phase.opening;

    return _Scaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.enhanced_encryption_outlined,
                size: 48, color: AppColors.cyanSecondary),
            const SizedBox(height: 16),
            Text(
              isCreate ? 'Create a passphrase' : 'Enter your passphrase',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCreate
                  ? 'This encrypts your recovery data in this browser. '
                      "There's no password reset — if you forget it, this "
                      "browser's data can't be recovered."
                  : 'Unlocks your recovery data in this browser.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _passphraseController,
              obscureText: true,
              autofocus: true,
              enabled: !isOpening,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Passphrase',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cyanSecondary),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your passphrase';
                }
                if (isCreate && value.length < _minLength) {
                  return 'Use at least $_minLength characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => isCreate ? null : _submit(),
            ),
            if (isCreate) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                enabled: !isOpening,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm passphrase',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cyanSecondary),
                  ),
                ),
                validator: (value) {
                  if (value != _passphraseController.text) {
                    return "Passphrases don't match";
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isOpening ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cyanSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isOpening
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(isCreate ? 'Create' : 'Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Widget child;
  const _Scaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
