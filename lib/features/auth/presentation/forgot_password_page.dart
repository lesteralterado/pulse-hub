import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_presenter.dart';
import '../../../core/utils/validators.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_page_scaffold.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    // Clear any error left over from a different auth form.
    Future.microtask(() {
      if (mounted) ref.read(authControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());

    if (succeeded && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AuthPageScaffold(
      title: 'Reset your password',
      subtitle: "We'll email you a link to reset your password",
      footer: TextButton(
        onPressed: isLoading ? null : () => context.go(AppConstants.routeLogin),
        child: const Text('Back to sign in'),
      ),
      children: [
        if (_emailSent)
          const Text(
            'Check your inbox for a password reset link.',
            textAlign: TextAlign.center,
          )
        else
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (authState.hasError)
                  AuthErrorBanner(message: describeError(authState.error!)),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: Validators.email,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send reset link'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
