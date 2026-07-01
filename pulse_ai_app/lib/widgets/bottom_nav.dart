import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class PulseBottomNav extends StatelessWidget {
  const PulseBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xF206090D),
            border: Border(top: BorderSide(color: C.line)),
          ),
          padding: EdgeInsets.only(top: 13, bottom: MediaQuery.of(context).padding.bottom > 0 ? 0 : 10),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(children: [
                _item(app, PulseTab.home, Icons.home_outlined, 'Today'),
                _item(app, PulseTab.coach, Icons.chat_bubble_outline_rounded, 'Coach'),
                _item(app, PulseTab.score, Icons.track_changes_rounded, 'Score'),
                _item(app, PulseTab.insights, Icons.show_chart_rounded, 'Insights'),
                _item(app, PulseTab.body, Icons.person_outline_rounded, 'Body'),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(AppState app, PulseTab tab, IconData icon, String label) {
    final active = app.tab == tab;
    final color = active ? C.accent : C.dim7;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => app.go(tab),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 5),
          Text(label, style: F.display(size: 10, weight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}
