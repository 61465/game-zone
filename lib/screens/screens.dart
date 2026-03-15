import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

// ══════════════════════════════════════════
//  CHAT SCREEN
// ══════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send(AppProvider p) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    p.sendMessage(text);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: p.messages.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) return _DateSeparator(label: 'اليوم · ١٥ مارس');
              return _buildBubble(p.messages[i - 1], p, t, context);
            },
          ),
        ),
        _buildInputBar(p, t, context),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg, AppProvider p, AppThemeData t, BuildContext ctx) {
    if (msg.type == MessageType.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: t.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border),
            ),
            child: Text(msg.content, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
          ),
        ),
      );
    }
    if (msg.type == MessageType.scheduledLetter) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isMe) ...[UserAvatar(initial: p.partnerInitial, isMe: false, size: 28), const SizedBox(width: 6)],
            GestureDetector(
              onTap: () {
                if (!msg.isLocked) p.openLetter(msg.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: const BoxConstraints(maxWidth: 260),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.primaryDim,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.primary.withOpacity(0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Text(msg.isLocked ? '🔒' : '💌', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(msg.letterTitle ?? 'رسالة مؤجلة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.primary)),
                    ]),
                    const SizedBox(height: 4),
                    if (msg.isLocked)
                      Text(
                        'تُفتح عند: ${_formatTime(msg.openAt!)} ⏰',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199)),
                      )
                    else
                      Text(msg.content, style: const TextStyle(fontSize: 14, height: 1.6)),
                  ],
                ),
              ),
            ),
            if (msg.isMe) ...[const SizedBox(width: 6), UserAvatar(initial: p.myInitial, isMe: true, size: 28)],
          ],
        ),
      );
    }

    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[UserAvatar(initial: p.partnerInitial, isMe: false, size: 28), const SizedBox(width: 6)],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isMe ? LinearGradient(colors: [t.primary.withOpacity(0.22), const Color(0xFFC06B4B).withOpacity(0.18)]) : null,
                    color: isMe ? null : t.surface2,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(17),
                      topRight: const Radius.circular(17),
                      bottomLeft: Radius.circular(isMe ? 17 : 3),
                      bottomRight: Radius.circular(isMe ? 3 : 17),
                    ),
                    border: Border.all(color: isMe ? t.primary.withOpacity(0.22) : t.border),
                  ),
                  child: Text(msg.content, style: const TextStyle(fontSize: 14, height: 1.6)),
                ),
              ),
              if (isMe) ...[const SizedBox(width: 6), UserAvatar(initial: p.myInitial, isMe: true, size: 28)],
            ],
          ),
          if (msg.reactions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4, right: isMe ? 44 : 0, left: isMe ? 0 : 44),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: msg.reactions.map((r) => Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: t.surface3,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.border),
                  ),
                  child: Text('$r ${msg.reactions.length}', style: const TextStyle(fontSize: 12)),
                )).toList(),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: 3, right: isMe ? 44 : 0, left: isMe ? 0 : 44),
            child: Text(_formatTime(msg.sentAt), style: const TextStyle(fontSize: 10, color: Color(0xFF9B9199))),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppProvider p, AppThemeData t, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: t.surface1,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _IconBtn(icon: '😊', onTap: () {}),
              const SizedBox(width: 6),
              _IconBtn(icon: '💌', onTap: () => Navigator.pushNamed(ctx, '/letter')),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14, color: Color(0xFFF0ECE2)),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: const TextStyle(color: Color(0xFF9B9199)),
                    filled: true, fillColor: t.surface2,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.primary.withOpacity(.5))),
                  ),
                  onSubmitted: (_) => _send(p),
                ),
              ),
              const SizedBox(width: 6),
              _IconBtn(icon: '🎙️', onTap: () {}),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _send(p),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [t.primary, Color.lerp(t.primary, Colors.brown, .35)!]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('➤', style: TextStyle(color: t.bg, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                _HintChip('💌 رسالة مؤجلة', () => Navigator.pushNamed(ctx, '/letter')),
                const SizedBox(width: 6),
                _HintChip('🌡️ حالتي', () => _showMoodSheet(ctx, p, t)),
                const SizedBox(width: 6),
                _HintChip('😤 أنا زعلان', () => p.activateFightMode()),
                const SizedBox(width: 6),
                _HintChip('🎮 العب', () => Navigator.pushNamed(ctx, '/games')),
                const SizedBox(width: 6),
                _HintChip('🎨 ارسم', () => Navigator.pushNamed(ctx, '/draw')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoodSheet(BuildContext ctx, AppProvider p, AppThemeData t) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: t.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MoodEditSheet(provider: p, theme: t),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h < 12 ? 'ص' : 'م';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(child: Divider(color: const Color(0xFFC9A84C).withOpacity(.15), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
        ),
        Expanded(child: Divider(color: const Color(0xFFC9A84C).withOpacity(.15), thickness: 1)),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: t.surface2, borderRadius: BorderRadius.circular(11)),
        alignment: Alignment.center,
        child: Text(icon, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HintChip(this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
      ),
    );
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
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.primary.withOpacity(.5))),
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(label: 'حفظ وإرسال', onTap: () {
          widget.provider.setMyMood(selectedEmoji, selectedLabel, msgCtrl.text.isEmpty ? selectedLabel : msgCtrl.text);
          Navigator.pop(context);
        }),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  SCHEDULED LETTERS SCREEN
// ══════════════════════════════════════════
class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key});
  @override State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedTime = '1h';

  final Map<String, String> _timeLabels = {
    '1h': 'بعد ساعة',
    '3h': 'بعد ٣ ساعات',
    'tonight': 'الليلة',
    'tomorrow': 'غداً',
    'week': 'بعد أسبوع',
    'anniv': 'عيد الزواج 💍',
  };

  DateTime _computeOpenAt() {
    final now = DateTime.now();
    switch (_selectedTime) {
      case '1h': return now.add(const Duration(hours: 1));
      case '3h': return now.add(const Duration(hours: 3));
      case 'tonight': return DateTime(now.year, now.month, now.day, 22, 0);
      case 'tomorrow': return now.add(const Duration(days: 1));
      case 'week': return now.add(const Duration(days: 7));
      case 'anniv': return DateTime(now.year + 1, 5, 1);
      default: return now.add(const Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    final letters = p.messages.where((m) => m.type == MessageType.scheduledLetter && m.isMe).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('💌 الرسائل المؤجلة'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('✍️ اكتب رسالة تُفتح في وقت محدد',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.primary)),
              const SizedBox(height: 12),
              _buildInput(t, _titleCtrl, 'عنوان الرسالة (اختياري)...'),
              const SizedBox(height: 8),
              _buildInput(t, _contentCtrl, 'اكتب رسالتك هنا... 🔒', maxLines: 4),
              const SizedBox(height: 12),
              const Text('تُفتح بعد:', style: TextStyle(fontSize: 12, color: Color(0xFF9B9199))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: _timeLabels.entries.map((e) => PillButton(
                  label: e.value,
                  selected: _selectedTime == e.key,
                  onTap: () => setState(() => _selectedTime = e.key),
                )).toList(),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'أرسل الرسالة المشفّرة',
                leadingEmoji: '🔒',
                onTap: () {
                  if (_contentCtrl.text.trim().isEmpty) return;
                  p.sendScheduledLetter(
                    _titleCtrl.text.trim(),
                    _contentCtrl.text.trim(),
                    _computeOpenAt(),
                  );
                  _titleCtrl.clear(); _contentCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم إرسال الرسالة المشفّرة 🔒'),
                      backgroundColor: t.surface2,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ]),
          ),
          const SizedBox(height: 18),
          Text('📬 الرسائل المرسلة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 10),
          ...letters.map((m) => _LetterCard(letter: m, theme: t)),
        ],
      ),
    );
  }

  Widget _buildInput(AppThemeData t, TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFFF0ECE2)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9B9199)),
        filled: true, fillColor: t.surface3,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.primary.withOpacity(.5))),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final ChatMessage letter;
  final AppThemeData theme;
  const _LetterCard({required this.letter, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isReady = !letter.isLocked;
    final t = theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isReady
                    ? [const Color(0xFF4ADE80), const Color(0xFF16A34A)]
                    : [const Color(0xFFFFB347), const Color(0xFFE65100)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Text(isReady ? '💌' : '🔒', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 7),
                Text(letter.letterTitle ?? 'رسالة مؤجلة', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 3),
              Text(
                isReady ? 'فُتحت ✓' : 'تُفتح ${letter.openAt != null ? _fmtDate(letter.openAt!) : "لاحقاً"}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199)),
              ),
              const SizedBox(height: 4),
              Text(
                letter.content.length > 60 ? '${letter.content.substring(0, 60)}...' : letter.content,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9B9199)),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isReady ? const Color(0xFF4ADE80).withOpacity(.12) : const Color(0xFFFFB347).withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isReady ? const Color(0xFF4ADE80).withOpacity(.3) : const Color(0xFFFFB347).withOpacity(.3)),
            ),
            child: Text(
              isReady ? 'مفتوحة' : 'معلّقة',
              style: TextStyle(fontSize: 10, color: isReady ? const Color(0xFF4ADE80) : const Color(0xFFFFB347)),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ══════════════════════════════════════════
//  MOOD SCREEN
// ══════════════════════════════════════════
class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});
  @override State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final _msgCtrl = TextEditingController();
  String _selectedEmoji = '😊';
  String _selectedLabel = 'سعيد';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('🌡️ المزاج المشترك'),
          const SizedBox(height: 12),
          _SharedMoodCard(p: p, t: t),
          const SizedBox(height: 16),
          Text('اختر حالتك الآن', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.1,
            children: moodOptions.map((m) {
              final sel = _selectedEmoji == m['e'];
              return GestureDetector(
                onTap: () => setState(() { _selectedEmoji = m['e']!; _selectedLabel = m['l']!; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: sel ? t.primaryDim : t.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? t.primary.withOpacity(.5) : t.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(m['e']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(m['l']!, style: TextStyle(fontSize: 11, color: sel ? t.primary : const Color(0xFF9B9199))),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📨 أرسل رسالة مزاجية', style: TextStyle(fontSize: 13, color: t.primary.withOpacity(.7))),
              const SizedBox(height: 8),
              TextField(
                controller: _msgCtrl,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 14, color: Color(0xFFF0ECE2)),
                decoration: InputDecoration(
                  hintText: 'كيف حالك؟ أخبر شريكك...',
                  hintStyle: const TextStyle(color: Color(0xFF9B9199)),
                  filled: true, fillColor: t.surface3,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.primary.withOpacity(.5))),
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'إرسال للشريك 💛',
                onTap: () {
                  p.setMyMood(_selectedEmoji, _selectedLabel, _msgCtrl.text.isEmpty ? _selectedLabel : _msgCtrl.text);
                  p.sendMessage('🌡️ حالتي الآن: $_selectedEmoji · ${_msgCtrl.text.isEmpty ? _selectedLabel : _msgCtrl.text}');
                  _msgCtrl.clear();
                  Navigator.pop(context);
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text('📊 مزاجكما هذا الأسبوع', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                ['الأحد','😊','😍'], ['الاثنين','🤩','😂'], ['الثلاثاء','😴','😴'], ['اليوم', p.myMood.emoji, p.herMood.emoji],
              ].map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  SizedBox(width: 55, child: Text(row[0], style: const TextStyle(fontSize: 12, color: Color(0xFF9B9199)))),
                  Text(row[1], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  const Text('أنت', style: TextStyle(fontSize: 10, color: Color(0xFF9B9199))),
                  const Spacer(),
                  Text(row[2], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  const Text('سارة', style: TextStyle(fontSize: 10, color: Color(0xFF9B9199))),
                  if (row[1] == row[2]) ...[const SizedBox(width: 8), const Text('💞 منسجمان', style: TextStyle(fontSize: 10, color: Color(0xFFC9A84C)))],
                ]),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedMoodCard extends StatelessWidget {
  final AppProvider p;
  final AppThemeData t;
  const _SharedMoodCard({required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [t.surface2, t.surface3]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.primary.withOpacity(.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                UserAvatar(initial: p.myInitial, isMe: true, size: 44),
                const SizedBox(height: 6),
                Text(p.myMood.emoji, style: const TextStyle(fontSize: 26)),
                Text('أنت', style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
              ]),
              Column(children: [
                Text(p.moodCompatEmoji, style: const TextStyle(fontSize: 28)),
                Text(p.moodCompatLabel, style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w600)),
              ]),
              Column(children: [
                UserAvatar(initial: p.partnerInitial, isMe: false, size: 44),
                const SizedBox(height: 6),
                Text(p.herMood.emoji, style: const TextStyle(fontSize: 26)),
                Text(p.partnerName.split(' ').first, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  FIGHT SCREEN
// ══════════════════════════════════════════
class FightScreen extends StatefulWidget {
  const FightScreen({super.key});
  @override State<FightScreen> createState() => _FightScreenState();
}

class _FightScreenState extends State<FightScreen> {
  String _who = 'me';
  final _reasonCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    const redColor = Color(0xFFFF8080);
    const redDim = Color(0xFFE05555);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('😤 وضع المشاجرة'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: redDim.withOpacity(.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: redDim.withOpacity(.25)),
            ),
            child: Column(
              children: [
                Text(p.isFightMode ? '😤' : '😊', style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  p.isFightMode ? 'وضع المشاجرة مفعّل' : 'كلشي بخير 💚',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.isFightMode ? redColor : const Color(0xFF4ADE80)),
                ),
                const SizedBox(height: 4),
                const Text('يمكن لأي طرف تفعيل هذا الوضع', style: TextStyle(fontSize: 12, color: Color(0xFF9B9199))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('من الزعلان؟', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 8),
          Row(
            children: [
              _FightWhoBtn(label: '😤 أنا زعلان', value: 'me', selected: _who == 'me', onTap: () => setState(() => _who = 'me')),
              const SizedBox(width: 8),
              _FightWhoBtn(label: '😢 هي زعلانة', value: 'her', selected: _who == 'her', onTap: () => setState(() => _who = 'her')),
              const SizedBox(width: 8),
              _FightWhoBtn(label: '💥 كلانا', value: 'both', selected: _who == 'both', onTap: () => setState(() => _who = 'both')),
            ],
          ),
          const SizedBox(height: 14),
          Text('سبب الزعل (اختياري)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonCtrl,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 14, color: Color(0xFFF0ECE2)),
            decoration: InputDecoration(
              hintText: 'ما الذي حدث؟',
              hintStyle: const TextStyle(color: Color(0xFF9B9199)),
              filled: true, fillColor: t.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: redDim.withOpacity(.4))),
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            borderColor: const Color(0xFFC9A84C).withOpacity(.2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('💡 نصيحة للتهدئة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.primary)),
              const SizedBox(height: 6),
              const Text(
                'خذوا وقتاً للتنفس قبل الرد. تذكروا أنكما فريق واحد. المشاجرة ليست حرباً، بل هي طريق للتفاهم 💙',
                style: TextStyle(fontSize: 13, color: Color(0xFF9B9199), height: 1.6),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Text('أرسل رسالة تهدئة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 8),
          ...[
            '🤍 أنا آسف، ما كان قصدي يجرحك',
            '💙 نحتاج نتكلم بهدوء',
            '🌹 بحبك حتى لما نختلف',
            '⏰ خليني أهدأ شوي ثم نتكلم',
          ].map((msg) => _PeaceMsgTile(msg: msg, p: p, t: t)),
          const SizedBox(height: 14),
          if (!p.isFightMode)
            PrimaryButton(
              label: 'تفعيل وضع المشاجرة',
              leadingEmoji: '😤',
              onTap: () => p.activateFightMode(who: _who, reason: _reasonCtrl.text),
            )
          else
            GestureDetector(
              onTap: () => _showPeaceDialog(context, p),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF16A34A)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('🤝 صلح وعودة للحب', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
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
          const Text('هل أنتما مستعدان؟', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9B9199), fontSize: 14)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ليس الآن', style: TextStyle(color: Color(0xFF9B9199)))),
          ElevatedButton(
            onPressed: () { p.makePeace(); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('نعم ❤️'),
          ),
        ],
      ),
    );
  }
}

class _FightWhoBtn extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _FightWhoBtn({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext ctx) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE05555).withOpacity(.12) : const Color(0xFF1E1B27),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? const Color(0xFFE05555).withOpacity(.4) : const Color(0xFFE05555).withOpacity(.15)),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 12, color: selected ? const Color(0xFFFF8080) : const Color(0xFF9B9199)), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _PeaceMsgTile extends StatelessWidget {
  final String msg;
  final AppProvider p;
  final AppThemeData t;
  const _PeaceMsgTile({required this.msg, required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        p.sendMessage(msg);
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE05555).withOpacity(.18)),
        ),
        child: Text(msg, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  GAMES SCREEN
// ══════════════════════════════════════════
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  @override State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  GameCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    final games = _filter == null ? allGames : allGames.where((g) => g.category == _filter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('🎮 ألعاب معاً (${allGames.length} لعبة)'),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: [
                    PillButton(label: 'الكل', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                    const SizedBox(width: 6),
                    ...GameCategory.values.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: PillButton(
                        label: c.nameAr, emoji: c.emoji,
                        selected: _filter == c,
                        onTap: () => setState(() => _filter = c),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (p.activeGame != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: _ActiveGameCard(game: p.activeGame!, p: p, t: t),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            itemCount: games.length,
            itemBuilder: (_, i) => _GameCard(game: games[i], p: p, t: t),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameModel game;
  final AppProvider p;
  final AppThemeData t;
  const _GameCard({required this.game, required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    final isActive = p.activeGame?.id == game.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? t.primary.withOpacity(.5) : t.border, width: isActive ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(game.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(game.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(game.description, style: const TextStyle(fontSize: 12, color: Color(0xFF9B9199))),
          ])),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: game.category.color.withOpacity(.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: game.category.color.withOpacity(.3)),
            ),
            child: Text('${game.category.emoji} ${game.category.nameAr}', style: TextStyle(fontSize: 11, color: game.category.color)),
          ),
          const SizedBox(width: 8),
          const Text('👥 اثنان', style: TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
          const Spacer(),
          GestureDetector(
            onTap: () => p.startGame(game),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: t.primaryDim,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('▶ العب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.primary)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _ActiveGameCard extends StatelessWidget {
  final GameModel game;
  final AppProvider p;
  final AppThemeData t;
  const _ActiveGameCard({required this.game, required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [t.surface2, t.surface3]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.primary.withOpacity(.35), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(game.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Text(game.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.primary)),
          const Spacer(),
          GestureDetector(
            onTap: () => p.closeGame(),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: t.surface3, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('✕', style: TextStyle(fontSize: 14, color: Color(0xFF9B9199))),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        if (p.gameStep < game.steps.length) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: t.surface3, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('الخطوة ${p.gameStep + 1}/${game.steps.length}', style: TextStyle(fontSize: 11, color: t.primary.withOpacity(.7))),
              const SizedBox(height: 4),
              Text(game.steps[p.gameStep], style: const TextStyle(fontSize: 14, height: 1.6)),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: t.surface3, borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                const Text('أنت', style: TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
                Text('${p.myScore}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: t.primary)),
              ]),
            ),
            const Expanded(child: SizedBox.shrink()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: t.surface3, borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                const Text('سارة', style: TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
                Text('${p.herScore}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: t.primary)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => p.addMyScore(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: t.primaryDim, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.border)),
                alignment: Alignment.center,
                child: Text('✅ نقطة لي', style: TextStyle(fontSize: 13, color: t.primary, fontWeight: FontWeight.w600)),
              ),
            )),
            const SizedBox(width: 8),
            Expanded(child: GestureDetector(
              onTap: () => p.addHerScore(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: t.surface3, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.border)),
                alignment: Alignment.center,
                child: const Text('✅ نقطة لسارة', style: TextStyle(fontSize: 13, color: Color(0xFF9B9199), fontWeight: FontWeight.w600)),
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => p.nextGameStep(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [t.primary, Color.lerp(t.primary, Colors.brown, .35)!]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('▶️ التالي', style: TextStyle(fontSize: 13, color: t.bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ] else ...[
          Center(child: Column(children: [
            const Text('🏆', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Text('اللعبة انتهت!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.primary)),
            const SizedBox(height: 6),
            Text(p.myScore > p.herScore ? 'فزت أنت! 🥳' : p.herScore > p.myScore ? 'فازت سارة! 🥳' : 'تعادل! 🤝', style: const TextStyle(fontSize: 14)),
          ])),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  DISCUSSION SCREEN
// ══════════════════════════════════════════
class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('🗣️ وقت النقاش'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: DiscMood.values.map((m) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: PillButton(
                  label: m.nameAr, emoji: m.emoji,
                  selected: p.discMood == m,
                  onTap: () => p.setDiscMood(m),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: AppCard(
              key: ValueKey(p.currentQuestion),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.currentQuestion, style: const TextStyle(fontSize: 15, height: 1.6)),
                const SizedBox(height: 12),
                Row(children: [
                  GestureDetector(
                    onTap: () {
                      p.sendMessage('🗣️ سؤال النقاش:\n${p.currentQuestion}');
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(color: t.primaryDim, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
                      child: Text('💬 أرسل للمحادثة', style: TextStyle(fontSize: 12, color: t.primary)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'سؤال جديد 🔀', onTap: () => p.nextQuestion()),
          const SizedBox(height: 16),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📝 سجّل إجاباتكم', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.primary)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.surface3,
                  borderRadius: BorderRadius.circular(9),
                  border: Border(right: BorderSide(color: const Color(0xFFE07A8E), width: 3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('سارة قالت:', style: TextStyle(fontSize: 12, color: Color(0xFFE07A8E))),
                  const SizedBox(height: 4),
                  const Text('"كنتو تسافرون لكيوتو في اليابان 🇯🇵"', style: TextStyle(fontSize: 13, color: Color(0xFF9B9199))),
                ]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.surface3,
                  borderRadius: BorderRadius.circular(9),
                  border: Border(right: BorderSide(color: t.primary, width: 3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('أنت قلت:', style: TextStyle(fontSize: 12, color: t.primary)),
                  const SizedBox(height: 4),
                  const Text('"البندقية إيطاليا في الشتاء 🇮🇹❄️"', style: TextStyle(fontSize: 13, color: Color(0xFF9B9199))),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  IDEAS SCREEN
// ══════════════════════════════════════════
class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});
  @override State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  void _showAddDialog(BuildContext ctx, AppProvider p, AppThemeData t) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    IdeaCategory selected = IdeaCategory.travel;
    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(builder: (ctx2, setSt) => AlertDialog(
        backgroundColor: t.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('💡 فكرة جديدة', style: TextStyle(color: t.primary)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogInput(t, titleCtrl, 'عنوان الفكرة...'),
            const SizedBox(height: 8),
            _dialogInput(t, descCtrl, 'اشرح الفكرة باختصار...', maxLines: 3),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: IdeaCategory.values.map((c) => GestureDetector(
                onTap: () => setSt(() => selected = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected == c ? c.color.withOpacity(.12) : t.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected == c ? c.color.withOpacity(.5) : t.border),
                  ),
                  child: Text('${c.emoji} ${c.nameAr}', style: TextStyle(fontSize: 12, color: selected == c ? c.color : const Color(0xFF9B9199))),
                ),
              )).toList(),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('إلغاء', style: TextStyle(color: Color(0xFF9B9199)))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              p.addIdea(titleCtrl.text.trim(), descCtrl.text.trim(), selected);
              Navigator.pop(ctx2);
            },
            style: ElevatedButton.styleFrom(backgroundColor: t.primary, foregroundColor: t.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('حفظ'),
          ),
        ],
      )),
    );
  }

  Widget _dialogInput(AppThemeData t, TextEditingController c, String hint, {int maxLines = 1}) => TextField(
    controller: c, textAlign: TextAlign.right, textDirection: TextDirection.rtl, maxLines: maxLines,
    style: const TextStyle(fontSize: 14, color: Color(0xFFF0ECE2)),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: Color(0xFF9B9199)),
      filled: true, fillColor: t.surface2,
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.primary.withOpacity(.5))),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                SectionTitle('💡 قائمة أفكارنا'),
                const Spacer(),
                Text('${p.ideas.length} أفكار', style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
              ]),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: [
                    PillButton(label: 'الكل', selected: p.ideaFilter == null, onTap: () => p.setIdeaFilter(null)),
                    const SizedBox(width: 6),
                    ...IdeaCategory.values.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: PillButton(label: c.nameAr, emoji: c.emoji, selected: p.ideaFilter == c, onTap: () => p.setIdeaFilter(c)),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
            itemCount: p.filteredIdeas.length,
            itemBuilder: (_, i) => _IdeaCard(idea: p.filteredIdeas[i], p: p, t: t),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: GestureDetector(
            onTap: () => _showAddDialog(context, p, t),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.primary.withOpacity(.3), style: BorderStyle.solid, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('✨', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('أضف فكرة جديدة', style: TextStyle(fontSize: 14, color: t.primary, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final Idea idea;
  final AppProvider p;
  final AppThemeData t;
  const _IdeaCard({required this.idea, required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 52, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [idea.category.color, idea.category.color.withOpacity(.4)]),
          )),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(idea.category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: Text(idea.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 4),
            Text(idea.description, style: const TextStyle(fontSize: 12, color: Color(0xFF9B9199))),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: idea.category.color.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: idea.category.color.withOpacity(.3)),
                ),
                child: Text('${idea.category.emoji} ${idea.category.nameAr}', style: TextStyle(fontSize: 10, color: idea.category.color)),
              ),
              const SizedBox(width: 8),
              Text('💬 ${idea.addedBy}', style: const TextStyle(fontSize: 10, color: Color(0xFF9B9199))),
              const Spacer(),
              GestureDetector(
                onTap: () => p.toggleIdeaLike(idea.id),
                child: Text(idea.liked ? '❤️' : '🤍', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 4),
              Text('${idea.likes}', style: const TextStyle(fontSize: 12, color: Color(0xFF9B9199))),
            ]),
          ])),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  TODO SCREEN
// ══════════════════════════════════════════
class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('📋 أهدافنا وقائمتنا'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [t.primary.withOpacity(.1), const Color(0xFFE07A8E).withOpacity(.08)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.primary.withOpacity(.25)),
            ),
            child: Column(children: [
              const Text('💍', style: TextStyle(fontSize: 38)),
              const SizedBox(height: 6),
              Text('47', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: t.primary)),
              const Text('يوماً على عيد زواجكما', style: TextStyle(fontSize: 12, color: Color(0xFF9B9199))),
              const SizedBox(height: 8),
              const Text('١ مايو ٢٠٢٦ · الذكرى الثالثة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 16),
          Text('🛒 قائمة المشتريات', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.primary.withOpacity(.7))),
          const SizedBox(height: 8),
          ...p.todos.map((todo) => _TodoTile(todo: todo, p: p, t: t)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _addTodoDialog(context, p, t),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: t.primary.withOpacity(.3), style: BorderStyle.solid),
              ),
              alignment: Alignment.center,
              child: Text('+ أضف عنصر جديد', style: TextStyle(fontSize: 13, color: t.primary)),
            ),
          ),
        ],
      ),
    );
  }

  void _addTodoDialog(BuildContext ctx, AppProvider p, AppThemeData t) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: t.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('أضف عنصر', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
          autofocus: true,
          style: const TextStyle(color: Color(0xFFF0ECE2)),
          decoration: InputDecoration(
            hintText: 'العنصر...', hintStyle: const TextStyle(color: Color(0xFF9B9199)),
            filled: true, fillColor: t.surface2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Color(0xFF9B9199)))),
          ElevatedButton(
            onPressed: () { if (ctrl.text.trim().isNotEmpty) { p.addTodo(ctrl.text.trim()); Navigator.pop(ctx); } },
            style: ElevatedButton.styleFrom(backgroundColor: t.primary, foregroundColor: t.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final TodoItem todo;
  final AppProvider p;
  final AppThemeData t;
  const _TodoTile({required this.todo, required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => p.toggleTodo(todo.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: todo.isDone ? t.primary : Colors.transparent,
              border: Border.all(color: todo.isDone ? t.primary : t.primary.withOpacity(.3), width: 2),
            ),
            alignment: Alignment.center,
            child: todo.isDone ? Text('✓', style: TextStyle(color: t.bg, fontSize: 12, fontWeight: FontWeight.w700)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(
            todo.title,
            style: TextStyle(
              fontSize: 13,
              color: todo.isDone ? const Color(0xFF9B9199) : const Color(0xFFF0ECE2),
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
            ),
          )),
          Text(todo.assignedTo, style: const TextStyle(fontSize: 11, color: Color(0xFFE07A8E))),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  THEMES SCREEN
// ══════════════════════════════════════════
class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('🎨 سمات التطبيق'),
          const SizedBox(height: 6),
          Text('اختر سمة تناسب مزاجكما اليوم', style: TextStyle(fontSize: 13, color: t.primary.withOpacity(.6))),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
            children: appThemes.entries.map((entry) {
              final theme = entry.value;
              final isSel = p.themeId == theme.id;
              return GestureDetector(
                onTap: () => p.setTheme(theme.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSel ? theme.primary : theme.primary.withOpacity(.15), width: isSel ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSel)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(8)),
                            child: Text('✓ مفعّل', style: TextStyle(fontSize: 9, color: theme.bg, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      Text(theme.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(theme.nameAr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.primary)),
                      const SizedBox(height: 2),
                      Text(theme.descAr, style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🌙 مزاجنا اليوم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.primary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['💕 رومانسي', '😊 سعيد', '😴 مرتاح', '🔥 متحمسين', '🌧️ حنين', '✨ مميز'].map((m) {
                  return PillButton(label: m, selected: false, onTap: () {});
                }).toList(),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  DRAWING SCREEN
// ══════════════════════════════════════════
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});
  @override State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final List<_Stroke> _strokes = [];
  final List<_Stroke> _undoStack = [];
  _Stroke? _current;

  Color _color = const Color(0xFFC9A84C);
  double _strokeWidth = 4.0;
  bool _isEraser = false;

  final List<Color> _palette = [
    const Color(0xFFC9A84C),
    const Color(0xFFE07A8E),
    const Color(0xFF4FC3F7),
    const Color(0xFF81C784),
    const Color(0xFFCE93D8),
    const Color(0xFFFFB347),
    const Color(0xFFFF6B6B),
    const Color(0xFFF0ECE2),
  ];

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _current = _Stroke(
        color: _isEraser ? const Color(0xFF1E1B27) : _color,
        width: _isEraser ? _strokeWidth * 4 : _strokeWidth,
        points: [d.localPosition],
      );
      _undoStack.clear();
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _current!.points.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      if (_current != null) _strokes.add(_current!);
      _current = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _undoStack.add(_strokes.removeLast()));
  }

  void _redo() {
    if (_undoStack.isEmpty) return;
    setState(() => _strokes.add(_undoStack.removeLast()));
  }

  void _clear() {
    setState(() { _strokes.clear(); _undoStack.clear(); });
  }

  void _send(BuildContext ctx, AppProvider p) {
    // In a real app, convert canvas to image bytes and send
    // Here we simulate sending as a sticker message
    p.sendMessage('🎨 أرسل لك رسمة! [صورة الرسم]', type: MessageType.image);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text('تم إرسال الرسمة! 🎨'),
        backgroundColor: p.currentTheme.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;

    return Column(
      children: [
        // ── Top toolbar ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: t.surface1,
          child: Row(
            children: [
              // Undo
              _ToolBtn(icon: '↩️', onTap: _undo, enabled: _strokes.isNotEmpty),
              const SizedBox(width: 6),
              // Redo
              _ToolBtn(icon: '↪️', onTap: _redo, enabled: _undoStack.isNotEmpty),
              const SizedBox(width: 6),
              // Clear
              _ToolBtn(icon: '🗑️', onTap: _clear, enabled: _strokes.isNotEmpty),
              const Spacer(),
              // Eraser toggle
              GestureDetector(
                onTap: () => setState(() => _isEraser = !_isEraser),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isEraser ? t.primaryDim : t.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _isEraser ? t.primary.withOpacity(.5) : t.border),
                  ),
                  child: Text('🧹 ممحاة',
                      style: TextStyle(fontSize: 12, color: _isEraser ? t.primary : const Color(0xFF9B9199))),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              GestureDetector(
                onTap: () => _send(context, p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [t.primary, Color.lerp(t.primary, Colors.brown, .35)!]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('إرسال ➤',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.bg)),
                ),
              ),
            ],
          ),
        ),

        // ── Canvas ──
        Expanded(
          child: Container(
            color: const Color(0xFF1E1B27),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _CanvasPainter(strokes: _strokes, current: _current),
                child: Container(),
              ),
            ),
          ),
        ),

        // ── Bottom palette ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: t.surface1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color palette
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _palette.map((c) {
                  final sel = _color == c && !_isEraser;
                  return GestureDetector(
                    onTap: () => setState(() { _color = c; _isEraser = false; }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: sel ? 36 : 28,
                      height: sel ? 36 : 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(color: c.withOpacity(.5), blurRadius: 8)]
                            : [],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Stroke width slider
              Row(
                children: [
                  Text('✏️', style: const TextStyle(fontSize: 14)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbColor: t.primary,
                        activeTrackColor: t.primary,
                        inactiveTrackColor: t.surface3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: _strokeWidth,
                        min: 2,
                        max: 20,
                        onChanged: (v) => setState(() => _strokeWidth = v),
                      ),
                    ),
                  ),
                  Container(
                    width: _strokeWidth.clamp(6, 20),
                    height: _strokeWidth.clamp(6, 20),
                    decoration: BoxDecoration(
                      color: _isEraser ? const Color(0xFF9B9199) : _color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stroke model ──
class _Stroke {
  final Color color;
  final double width;
  final List<Offset> points;
  _Stroke({required this.color, required this.width, required this.points});
}

// ── Canvas painter ──
class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? current;
  _CanvasPainter({required this.strokes, this.current});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, if (current != null) current!]) {
      if (stroke.points.length < 2) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          Paint()..color = stroke.color..strokeCap = StrokeCap.round,
        );
        continue;
      }
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length - 1; i++) {
        final mid = Offset(
          (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
          (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
        );
        path.quadraticBezierTo(
          stroke.points[i].dx, stroke.points[i].dy, mid.dx, mid.dy,
        );
      }
      path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}

// ── Tool button ──
class _ToolBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final bool enabled;
  const _ToolBtn({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().currentTheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border),
        ),
        alignment: Alignment.center,
        child: Text(icon,
            style: TextStyle(fontSize: 16, color: enabled ? null : const Color(0xFF9B9199))),
      ),
    );
  }
}
