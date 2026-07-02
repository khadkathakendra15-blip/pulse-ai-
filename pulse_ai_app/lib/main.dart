import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/body_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/score_screen.dart';
import 'theme/colors.dart';
import 'widgets/bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.screenBg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Pulse AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: C.screenBg,
          colorScheme: const ColorScheme.dark(
            primary: C.accent,
            surface: C.screenBg,
          ),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        // Responsive shell — full-width on phones, a centered phone-width
        // panel on tablet/desktop/web so the mobile UI never stretches.
        builder: (context, child) => _Responsive(child: child ?? const SizedBox()),
        home: const _Root(),
      ),
    );
  }
}

/// Constrains the whole app to a phone-width column and centres it on wide
/// viewports; passes through untouched on real phones. The constrained region
/// reports its own width via a MediaQuery override so `SafeArea`, layout, and
/// keyboard insets all behave correctly.
class _Responsive extends StatelessWidget {
  final Widget child;
  const _Responsive({required this.child});

  static const double _phoneMax = 448;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Narrow (real phone) → fill the screen.
    if (mq.size.width <= _phoneMax + 40) return child;

    // Wide → centre a phone-width panel on the app background, with a hairline
    // edge to make the framing feel intentional.
    return ColoredBox(
      color: C.bodyBg,
      child: Center(
        child: Container(
          width: _phoneMax,
          decoration: const BoxDecoration(
            color: C.screenBg,
            border: Border(
              left: BorderSide(color: C.line),
              right: BorderSide(color: C.line),
            ),
          ),
          child: MediaQuery(
            data: mq.copyWith(size: Size(_phoneMax, mq.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Onboarding gate — shows the onboarding flow on first launch, then the shell.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final done = context.select<AppState, bool>((a) => a.onboardingDone);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: done ? const _Shell() : const OnboardingScreen(),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell();

  @override
  Widget build(BuildContext context) {
    final tab = context.select<AppState, PulseTab>((a) => a.tab);
    return Scaffold(
      backgroundColor: C.screenBg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tab.index,
          children: const [
            HomeScreen(),
            CoachScreen(),
            ScoreScreen(),
            InsightsScreen(),
            BodyScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const PulseBottomNav(),
    );
  }
}
