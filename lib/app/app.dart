import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/push_tokens/presentation/controllers/push_token_providers.dart';
import 'router.dart';

class SentinelApp extends ConsumerWidget {
  const SentinelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // Keeps device_push_tokens in sync with the signed-in user for the
    // app's entire lifetime (registers on sign-in, re-registers on token
    // refresh) — see push_token_providers.dart. Watched here, not read
    // once in bootstrap(), because it must react to every future
    // sign-in/sign-out, not just the session active at startup. A no-op on
    // Web / while `UnavailablePushTokenSource` is the only source (see its
    // doc comment).
    ref.watch(pushTokenRegistrationProvider);

    return MaterialApp.router(
      title: 'Sentinel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
