import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/common_widgets.dart';
import 'screens/screens.dart';
import 'screens/auth_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const AlamnaApp(),
    ),
  );
}

class AlamnaApp extends StatelessWidget {
  const AlamnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return MaterialApp(
      title: 'عالمنا الخاص 💞',
      debugShowCheckedModeBanner: false,
      theme: buildFlutterTheme(p.currentTheme),
      locale: const Locale('ar'),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snap.data == null) {
            return const AuthScreen();
          }
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseService.myProfileStream(),
            builder: (ctx2, profileSnap) {
              if (!profileSnap.hasData) return const _SplashScreen();
              final data = profileSnap.data!.data() as Map<String, dynamic>?;
              final partnerId = data?['partnerId'] ?? '';
              if (partnerId.isEmpty) {
                return const LinkPartnerScreen();
              }
              return const HomeShell();
            },
          );
        },
      ),
      routes: {
        '/letter': (_) => const _SubScreen(title: '💌 الرسائل المؤجلة', child: LetterScreen()),
        '/games': (_) => const _SubScreen(title: '🎮 ألعاب معاً', child: GamesScreen()),
        '/discussion': (_) => const _SubScreen(title: '🗣️ وقت النقاش', child: DiscussionScreen()),
        '/fight': (_) => const _SubScreen(title: '😤 وضع المشاجرة', child: FightScreen()),
        '/mood': (_) => const _SubScreen(title: '🌡️ المزاج المشترك', child: MoodScreen()),
        '/ideas': (_) => const _SubScreen(title: '💡 قائمة أفكارنا', child: IdeasScreen()),
        '/themes': (_) => const _SubScreen(title: '🎨 السمات', child: ThemesScreen()),
        '/todo': (_) => const _SubScreen(title: '📋 أهدافنا', child: TodoScreen()),
        '/draw': (_) => const _SubScreen(title: '🎨 ارسم لشريكك', child: DrawingScreen()),
      },
    );
  }
}

// ══════════════════════════════════════════
//  SPLASH SCREEN
// ══════════════════════════════════════════
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0E0D12),
      body: Center(
        child: Text('💞', style: TextStyle(fontSize: 60)),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  SUB SCREEN WRAPPER
// ══════════════════════════════════════════
class _SubScreen extends StatelessWidget {
  final String title;
  final Widget child;
  const _SubScreen({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.surface1,
        elevation: 0,
        title: Text(title, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 16, color: t.primary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: t.primary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(color: t.border, height: 1)),
      ),
      body: StarBackground(
        child: Column(children: [
          const LowNetBanner(),
          const FightBanner(),
          Expanded(child: child),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  HOME SHELL
// ══════════════════════════════════════════
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  static const _screens = [ChatScreen(), MoodScreen(), IdeasScreen(), TodoScreen()];
  static const _labels  = ['المحادثة', 'المزاج', 'أفكارنا', 'أهدافنا'];
  static const _icons   = ['💬', '🌡️', '💡', '📋'];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final t = p.currentTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: _buildAppBar(context, p, t),
      body: StarBackground(
        child: Column(children: [
          const LowNetBanner(),
          const FightBanner(),
          const MoodWindowBar(),
          Expanded(child: _screens[_idx]),
        ]),
      ),
      bottomNavigationBar: _buildBottomNav(t),
      floatingActionButton: _idx == 0 ? _buildFAB(context, p, t) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext ctx, AppProvider p, AppThemeData t) {
    return AppBar(
      backgroundColor: t.surface1,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          UserAvatar(initial: p.partnerInitial, isMe: false, size: 40, showOnline: true),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.partnerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF0ECE2))),
              Text(
                p.isFightMode ? '😤 وضع المشاجرة مفعّل' : p.lowNet ? '📶 نت ضعيف' : 'متصلة الآن',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9B9199)),
              ),
            ],
          )),
        ]),
      ),
      actions: [
        IconButton(icon: Text(p.lowNet ? '📵' : '📶', style: const TextStyle(fontSize: 18)), onPressed: () => p.toggleLowNet()),
        IconButton(
          icon: Text(p.isFightMode ? '💚' : '😤', style: const TextStyle(fontSize: 18)),
          onPressed: () => p.isFightMode
              ? showDialog(context: ctx, builder: (_) => _PeaceDialog(p: p, t: t))
              : p.activateFightMode(),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: t.primary.withValues(alpha: 0.7)),
          color: t.surface2,
          onSelected: (v) {
            if (v == 'logout') {
              FirebaseService.logout();
            } else {
              Navigator.pushNamed(ctx, '/$v');
            }
          },
          itemBuilder: (_) => [
            _menuItem('games', '🎮 ألعاب معاً'),
            _menuItem('discussion', '🗣️ وقت النقاش'),
            _menuItem('letter', '💌 رسائل مؤجلة'),
            _menuItem('themes', '🎨 السمات'),
            _menuItem('fight', '😤 وضع المشاجرة'),
            _menuItem('draw', '🎨 ارسم لشريكك'),
            const PopupMenuDivider(),
            _menuItem('logout', '🚪 تسجيل خروج'),
          ],
        ),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(color: t.border, height: 1)),
    );
  }

  PopupMenuItem<String> _menuItem(String v, String label) => PopupMenuItem(
    value: v,
    child: Text(label, style: const TextStyle(fontSize: 14, fontFamily: 'Tajawal')),
  );

  Widget _buildBottomNav(AppThemeData t) {
    return Container(
      decoration: BoxDecoration(color: t.surface1, border: Border(top: BorderSide(color: t.border))),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_screens.length, (i) {
              final sel = _idx == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _idx = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: sel ? 44 : 40, height: sel ? 44 : 40,
                        decoration: BoxDecoration(
                          color: sel ? t.primaryDim : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(_icons[i], style: TextStyle(fontSize: sel ? 22 : 20)),
                      ),
                      const SizedBox(height: 2),
                      Text(_labels[i], style: TextStyle(fontSize: 10, color: sel ? t.primary : const Color(0xFF9B9199), fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext ctx, AppProvider p, AppThemeData t) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      FloatingActionButton.small(heroTag: 'game', backgroundColor: t.surface2, onPressed: () => Navigator.pushNamed(ctx, '/games'), child: const Text('🎮', style: TextStyle(fontSize: 18))),
      const SizedBox(height: 8),
      FloatingActionButton.small(heroTag: 'disc', backgroundColor: t.surface2, onPressed: () => Navigator.pushNamed(ctx, '/discussion'), child: const Text('🗣️', style: TextStyle(fontSize: 18))),
      const SizedBox(height: 8),
      FloatingActionButton(heroTag: 'letter', backgroundColor: t.primary, onPressed: () => Navigator.pushNamed(ctx, '/letter'), child: Text('💌', style: TextStyle(fontSize: 22, color: t.bg))),
      const SizedBox(height: 8),
      FloatingActionButton.small(heroTag: 'draw', backgroundColor: t.surface2, onPressed: () => Navigator.pushNamed(ctx, '/draw'), child: const Text('🎨', style: TextStyle(fontSize: 18))),
    ]);
  }
}

class _PeaceDialog extends StatelessWidget {
  final AppProvider p;
  final AppThemeData t;
  const _PeaceDialog({required this.p, required this.t});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: t.surface1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('🕊️ وقت الصلح', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4ADE80), fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🤝💕', style: TextStyle(fontSize: 52), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('هل أنتما مستعدان للصلح؟', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9B9199), fontSize: 14)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ليس الآن', style: TextStyle(color: Color(0xFF9B9199)))),
        ElevatedButton(
          onPressed: () { p.makePeace(); Navigator.pop(context); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('نعم، نحن بخير ❤️'),
        ),
      ],
    );
  }
}
