import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/wallet_providers.dart';

/// Registers an existing wallet address for read-only display — no
/// signing, no WalletConnect SDK, no key custody. See the Phase 8
/// scoping discussion for why: those need real infrastructure this
/// project doesn't have yet.
class ConnectWalletPage extends ConsumerStatefulWidget {
  const ConnectWalletPage({super.key});

  @override
  ConsumerState<ConnectWalletPage> createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends ConsumerState<ConnectWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  String? _validateAddress(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Wallet address is required';
    if (trimmed.length < 10 || trimmed.length > 100) {
      return 'That doesn\'t look like a valid wallet address';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(walletRepositoryProvider)
        .connectWallet(_addressController.text.trim());
    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(myWalletProvider);
        Navigator.of(context).pop();
      },
      failure: (error) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = describeError(error);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect wallet'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Connect'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste your existing BOT Chain wallet address to see it here. '
                'This connects the address for viewing only — PulseHub never '
                'asks for your private key or seed phrase.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _addressController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(labelText: 'Wallet address'),
                validator: _validateAddress,
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
