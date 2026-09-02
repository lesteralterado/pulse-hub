import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_presenter.dart';
import '../../../core/utils/validators.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_page_scaffold.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final succeeded = await ref.read(authControllerProvider.notifier).signUp(
          email: email,
          password: _passwordController.text,
        );

    if (succeeded && mounted) {
      context.go(
        Uri(
          path: AppConstants.routeVerifyEmail,
          queryParameters: {'email': email},
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AuthPageScaffold(
      title: 'Create your account',
      subtitle: 'Join the PulseHub community',
      footer: TextButton(
        onPressed: isLoading ? null : () => context.go(AppConstants.routeLogin),
        child: const Text('Already have an account? Sign in'),
      ),
      children: [
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: Validators.password,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                validator: (value) =>
                    Validators.confirmPassword(value, _passwordController.text),
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
                    : const Text('Create account'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
