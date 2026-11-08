import 'package:go_router/go_router.dart';

import 'data/models/file_entry.dart';
import 'features/browser/browser_page.dart';
import 'features/home/home_page.dart';
import 'features/recycle_bin/recycle_bin_page.dart';
import 'features/search/search_page.dart';
import 'features/settings/settings_page.dart';
import 'features/workspace/workspace_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/workspace',
      builder: (context, state) {
        final entry = state.extra as FileEntry;
        return WorkspacePage(entry: entry);
      },
    ),
    GoRoute(
      path: '/browser',
      builder: (context, state) {
        final dir = state.extra as FileEntry;
        return BrowserPage(directory: dir);
      },
    ),
    GoRoute(
      path: '/recycle-bin',
      builder: (context, state) => const RecycleBinPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
