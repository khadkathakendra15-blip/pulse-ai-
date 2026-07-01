import 'package:flutter/material.dart';

/// A single bar in a 7-day mini trend chart.
class Bar {
  final double heightPct; // 0..100
  final Color color;
  const Bar(this.heightPct, this.color);
}

class Vital {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String delta;
  final Color deltaColor;
  final String arrow; // ↑ ↓ ·
  final String avg;
  final String baseline;
  final int conf;
  final String interp;
  final List<Bar> bars;
  const Vital({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.delta,
    required this.deltaColor,
    required this.arrow,
    required this.avg,
    required this.baseline,
    required this.conf,
    required this.interp,
    required this.bars,
  });
}

class Mission {
  final String label;
  final String reason;
  final String prog;
  final bool done;
  const Mission(this.label, this.reason, this.prog, this.done);
}

class ScoreComponent {
  final String label;
  final String detail;
  final int score;
  final Color color;
  final String dval;
  final Color dcolor;
  final int conf;
  final int baseline;
  const ScoreComponent({
    required this.label,
    required this.detail,
    required this.score,
    required this.color,
    required this.dval,
    required this.dcolor,
    required this.conf,
    required this.baseline,
  });
}

class EnergySlot {
  final String time;
  final String label;
  final int pct;
  final Color color;
  const EnergySlot(this.time, this.label, this.pct, this.color);
}

class CalDay {
  final int n;
  final Color bg;
  final Color fg;
  const CalDay(this.n, this.bg, this.fg);
}

class Highlight {
  final String icon;
  final Color iconBg;
  final String title;
  final String sub;
  final String val;
  final Color valColor;
  const Highlight(this.icon, this.iconBg, this.title, this.sub, this.val, this.valColor);
}

class Achievement {
  final String icon;
  final String title;
  final String desc;
  final Color bg;
  final Color border;
  final Color iconBg;
  final Color titleColor;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  const Achievement({
    required this.icon,
    required this.title,
    required this.desc,
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.titleColor,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });
}

class FutureMod {
  final String icon;
  final String label;
  final String desc;
  final Color color;
  const FutureMod(this.icon, this.label, this.desc, this.color);
}

class AnalysisChip {
  final String l;
  final String v;
  final String arrow; // ↑ ↓
  final Color color;
  const AnalysisChip(this.l, this.v, this.arrow, this.color);
}

enum MsgKind { userText, aiText, aiAnalysis }

class ChatMessage {
  final MsgKind kind;
  // text for userText / aiText
  final String text;
  // analysis fields
  final String title;
  final String rec;
  final int conf;
  final String outcome;
  final List<AnalysisChip> chips;
  const ChatMessage.user(this.text)
      : kind = MsgKind.userText,
        title = '',
        rec = '',
        conf = 0,
        outcome = '',
        chips = const [];
  const ChatMessage.aiText(this.text)
      : kind = MsgKind.aiText,
        title = '',
        rec = '',
        conf = 0,
        outcome = '',
        chips = const [];
  const ChatMessage.analysis({
    required this.title,
    required this.rec,
    required this.conf,
    required this.outcome,
    required this.chips,
  })  : kind = MsgKind.aiAnalysis,
        text = '';
}

/// Quick-prompt chip in the Coach composer.
class QuickPrompt {
  final String label;
  final String cannedKey; // 'recovery' | 'plan' | 'workout'
  final String npQuestion;
  final String enQuestion;
  const QuickPrompt(this.label, this.cannedKey, this.npQuestion, this.enQuestion);
}
