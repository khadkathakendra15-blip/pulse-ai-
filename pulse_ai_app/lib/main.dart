import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/body_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
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
        home: const _Shell(),
      ),
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
