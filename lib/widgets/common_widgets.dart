import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ══════════════════════════════════════════
//  STAR BACKGROUND
// ══════════════════════════════════════════
class StarBackground extends StatelessWidget {
  final Widget child;
  const StarBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _StarPainter(t.primary))),
      child,
    ]);
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.45);
    final pts = [
      Offset(size.width*.08, size.height*.15), Offset(size.width*.22, size.height*.68),
      Offset(size.width*.55, size.height*.08), Offset(size.width*.78, size.height*.45),
      Offset(size.width*.91, size.height*.78), Offset(size.width*.43, size.height*.42),
      Offset(size.width*.15, size.height*.88), Offset(size.width*.67, size.height*.28),
      Offset(size.width*.35, size.height*.55), Offset(size.width*.60, size.height*.70),
    ];
    for (final p in pts) { canvas.drawCircle(p, 1.2, paint); }
    final dim = Paint()..color = Colors.white.withOpacity(0.15);
    final pts2 = [
      Offset(size.width*.30, size.height*.30), Offset(size.width*.70, size.height*.60),
      Offset(size.width*.50, size.height*.20), Offset(size.width*.85, size.height*.35),
    ];
    for (final p in pts2) { canvas.drawCircle(p, 1.0, dim); }
  }
  @override bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════
//  APP CARD
// ══════════════════════════════════════════
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.radius = 14,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    final card = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? t.border, width: 1),
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ══════════════════════════════════════════
//  PILL BUTTON
// ══════════════════════════════════════════
class PillButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  const PillButton({super.key, required this.label, required this.selected, required this.onTap, this.emoji});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? t.primaryDim : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? t.primary.withOpacity(0.5) : t.border,
          ),
        ),
        child: Text(
          emoji != null ? '$emoji $label' : label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? t.primary : const Color(0xFF9B9199),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  AVATAR
// ══════════════════════════════════════════
class UserAvatar extends StatelessWidget {
  final String initial;
  final bool isMe;
  final double size;
  final bool showOnline;

  const UserAvatar({
    super.key,
    required this.initial,
    required this.isMe,
    this.size = 36,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return Stack(
      children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isMe
                  ? [t.primary, const Color(0xFFC4813A)]
                  : [const Color(0xFFE07A8E), t.primary],
            ),
          ),
          alignment: Alignment.center,
          child: Text(initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
              )),
        ),
        if (showOnline)
          Positioned(
            bottom: 1, right: 1,
            child: Container(
              width: size * 0.28, height: size * 0.28,
              decoration: BoxDecoration(
                color: context.watch<AppProvider>().isFightMode
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF4ADE80),
                shape: BoxShape.circle,
                border: Border.all(color: t.surface1, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════
//  SECTION TITLE
// ══════════════════════════════════════════
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: t.primary,
          )),
    );
  }
}

// ══════════════════════════════════════════
//  PRIMARY ACTION BUTTON
// ══════════════════════════════════════════
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? leadingEmoji;

  const PrimaryButton({super.key, required this.label, required this.onTap, this.leadingEmoji});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [t.primary, Color.lerp(t.primary, Colors.brown, 0.35)!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          leadingEmoji != null ? '$leadingEmoji $label' : label,
          style: TextStyle(
            color: t.bg,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  MOOD WINDOW (always visible top bar)
// ══════════════════════════════════════════
class MoodWindowBar extends StatelessWidget {
  const MoodWindowBar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.surface1,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          // My side
          _MoodSide(
            initial: p.myInitial,
            isMe: true,
            emoji: p.myMood.emoji,
            name: 'أنت',
            message: p.myMood.message,
          ),
          const Spacer(),
          // Center hearts
          GestureDetector(
            onTap: () => _showMoodEditSheet(context, p, t),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.moodCompatEmoji, style: const TextStyle(fontSize: 20)),
                Text(p.moodCompatLabel,
                    style: TextStyle(fontSize: 10, color: t.primary)),
              ],
            ),
          ),
          const Spacer(),
          // Partner side
          _MoodSide(
            initial: p.partnerInitial,
            isMe: false,
            emoji: p.herMood.emoji,
            name: p.partnerName.split(' ').first,
            message: p.herMood.message,
            reversed: true,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _showMoodEditSheet(context, p, t),
            child: Text('✏️', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showMoodEditSheet(BuildContext ctx, AppProvider p, AppThemeData t) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: t.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MoodEditSheet(provider: p, theme: t),
    );
  }
}

class _MoodSide extends StatelessWidget {
  final String initial;
  final bool isMe;
  final String emoji;
  final String name;
  final String message;
  final bool reversed;

  const _MoodSide({
    required this.initial, required this.isMe, required this.emoji,
    required this.name, required this.message, this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: reversed
          ? [
              Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                Text(name, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
                Text(emoji, style: const TextStyle(fontSize: 18)),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(message, style: const TextStyle(fontSize: 11, color: Color(0xFFF0ECE2)), overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
                ),
              ]),
              const SizedBox(width: 8),
              UserAvatar(initial: initial, isMe: isMe, size: 34, showOnline: true),
            ]
          : [
              UserAvatar(initial: initial, isMe: isMe, size: 34, showOnline: true),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(name, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
                Text(emoji, style: const TextStyle(fontSize: 18)),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(message, style: const TextStyle(fontSize: 11, color: Color(0xFFF0ECE2)), overflow: TextOverflow.ellipsis),
                ),
              ]),
            ],
    );
    return content;
  }
}

class _MoodEditSheet extends StatefulWidget {
  final AppProvider provider;
  final AppThemeData theme;
  const _MoodEditSheet({required this.provider, required this.theme});
  @override State<_MoodEditSheet> createState() => _MoodEditSheetState();
}

class _MoodEditSheetState extends State<_MoodEditSheet> {
  String selectedEmoji = '😊';
  String selectedLabel = 'سعيد';
  final msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedEmoji = widget.provider.myMood.emoji;
    selectedLabel = widget.provider.myMood.label;
    msgCtrl.text = widget.provider.myMood.message;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌡️ حالتك الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.primary)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: moodOptions.map((m) {
              final sel = selectedEmoji == m['e'];
              return GestureDetector(
                onTap: () => setState(() { selectedEmoji = m['e']!; selectedLabel = m['l']!; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? t.primaryDim : t.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? t.primary.withOpacity(.5) : t.border),
                  ),
                  child: Text('${m['e']} ${m['l']}', style: TextStyle(fontSize: 13, color: sel ? t.primary : const Color(0xFF9B9199))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: msgCtrl,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Color(0xFFF0ECE2)),
            decoration: InputDecoration(
              hintText: 'رسالة قصيرة لشريكك...',
              hintStyle: const TextStyle(color: Color(0xFF9B9199)),
              filled: true, fillColor: t.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.primary.withOpacity(.5))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'حفظ وإرسال',
            onTap: () {
              widget.provider.setMyMood(selectedEmoji, selectedLabel, msgCtrl.text.isEmpty ? selectedLabel : msgCtrl.text);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  LOW-NET BANNER
// ══════════════════════════════════════════
class LowNetBanner extends StatelessWidget {
  const LowNetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    if (!p.lowNet) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFFFB347).withOpacity(0.12),
      child: Row(
        children: [
          const Text('📶', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('وضع النت الضعيف مفعّل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFFB347))),
              Text('الصور والفيديو معطّلة', style: TextStyle(fontSize: 11, color: Color(0xFFFFB347))),
            ]),
          ),
          GestureDetector(
            onTap: () => p.toggleLowNet(),
            child: const Text('✕', style: TextStyle(color: Color(0xFFFFB347), fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  FIGHT MODE BANNER
// ══════════════════════════════════════════
class FightBanner extends StatelessWidget {
  const FightBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    if (!p.isFightMode) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE05555).withOpacity(0.12),
        border: Border(bottom: BorderSide(color: const Color(0xFFE05555).withOpacity(0.3))),
      ),
      child: Row(
        children: [
          const Text('😤', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('وضع المشاجرة مفعّل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF8080))),
              Text('خذوا وقتاً للتهدئة 💙', style: TextStyle(fontSize: 11, color: Color(0xFFFF8080))),
            ]),
          ),
          GestureDetector(
            onTap: () => _showPeaceDialog(context, p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A84C).withOpacity(.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('🕊️ صلح', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPeaceDialog(BuildContext ctx, AppProvider p) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: p.currentTheme.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🕊️ وقت الصلح', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4ADE80), fontSize: 18)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🤝💕', style: TextStyle(fontSize: 52), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('هل أنتما مستعدان للصلح؟', textAlign: TextAlign.center, style: TextStyle(color: p.currentTheme.primary.withOpacity(.7), fontSize: 14)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ليس الآن', style: TextStyle(color: Color(0xFF9B9199)))),
          ElevatedButton(
            onPressed: () { p.makePeace(); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('نعم، نحن بخير ❤️'),
          ),
        ],
      ),
    );
  }
}
