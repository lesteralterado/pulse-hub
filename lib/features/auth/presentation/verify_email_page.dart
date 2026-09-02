import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_presenter.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_page_scaffold.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _resent = false;

  @override
  void initState() {
    super.initState();
    // Clear any error left over from a different auth form.
    Future.microtask(() {
      if (mounted) ref.read(authControllerProvider.notifier).reset();
    });
  }

  Future<void> _resend() async {
    setState(() => _resent = false);
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .resendEmailVerification(widget.email);
    if (succeeded && mounted) {
      setState(() => _resent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AuthPageScaffold(
      title: 'Verify your email',
      subtitle: widget.email.isEmpty
          ? 'Check your inbox for a verification link.'
          : "We've sent a verification link to ${widget.email}.",
      footer: TextButton(
        onPressed: isLoading ? null : () => context.go(AppConstants.routeLogin),
        child: const Text('Back to sign in'),
      ),
      children: [
        if (authState.hasError)
          AuthErrorBanner(message: describeError(authState.error!)),
        if (_resent && !authState.hasError)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Verification email resent.',
              textAlign: TextAlign.center,
            ),
          ),
        OutlinedButton(
          onPressed: isLoading || widget.email.isEmpty ? null : _resend,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Resend verification email'),
        ),
      ],
    );
  }
}
