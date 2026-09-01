import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../widgets/foundation_status_page.dart';

/// Single source of truth for app navigation. Phase 1 only wires the root
/// route to a status page; feature routes (Home/Community/Learn/Dashboard/
/// Profile) are added in Phase 3 once the bottom-navigation shell exists.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeRoot,
    routes: [
      GoRoute(
        path: AppConstants.routeRoot,
        builder: (context, state) => const FoundationStatusPage(),
      ),
    ],
  );
}
