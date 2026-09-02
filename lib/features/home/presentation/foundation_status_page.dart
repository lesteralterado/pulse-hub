import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/startup_info.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/application/auth_providers.dart';

/// Temporary Phase 1/2 root screen: proves theme, routing, Riverpod, env
/// config, Supabase startup and auth session state are wired together
/// correctly. Replaced by the real bottom-navigation shell in Phase 3.
class FoundationStatusPage extends ConsumerWidget {
  const FoundationStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupInfo = ref.watch(startupInfoProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isSigningOut = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          if (currentUser != null)
            IconButton(
              tooltip: 'Sign out',
              icon: isSigningOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              onPressed: isSigningOut
                  ? null
                  : () => ref.read(authControllerProvider.notifier).signOut(),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foundation ready', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _StatusRow(label: 'Environment', value: startupInfo.environment),
                  _StatusRow(
                    label: 'Supabase',
                    value: startupInfo.supabaseConfigured
                        ? 'Connected'
                        : 'Not configured',
                  ),
                  _StatusRow(
                    label: 'Signed in as',
                    value: currentUser?.email ?? 'nobody',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: bodyStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(value, style: bodyStyle),
        ],
      ),
    );
  }
}
