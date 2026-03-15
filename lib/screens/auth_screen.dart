import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';

// ══════════════════════════════════════════
//  AUTH SCREEN  (Login + Register)
// ══════════════════════════════════════════
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loading = false;
  bool _obscure = true;

  final _loginEmailCtrl    = TextEditingController();
  final _loginPassCtrl     = TextEditingController();
  final _regNameCtrl       = TextEditingController();
  final _regEmailCtrl      = TextEditingController();
  final _regPassCtrl       = TextEditingController();

  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final result = await FirebaseService.login(
      _loginEmailCtrl.text,
      _loginPassCtrl.text,
    );
    setState(() => _loading = false);
    if (result == null) {
      setState(() => _error = 'البريد أو كلمة المرور غير صحيحة');
    }
  }

  Future<void> _register() async {
    if (_regNameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل اسمك');
      return;
    }
    if (_regPassCtrl.text.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await FirebaseService.register(
      _regEmailCtrl.text,
      _regPassCtrl.text,
      _regNameCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (result == null) {
      setState(() => _error = 'حدث خطأ، تأكد من البريد الإلكتروني');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0D12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC9A84C), Color(0xFFE07A8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text('💞', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              Text('عالمنا الخاص',
                style: GoogleFonts.tajawal(
                  fontSize: 26, fontWeight: FontWeight.w700,
                  color: const Color(0xFFC9A84C),
                )),
              const SizedBox(height: 6),
              Text('مساحتك الخاصة معها',
                style: GoogleFonts.tajawal(
                  fontSize: 14, color: const Color(0xFF9B9199),
                )),
              const SizedBox(height: 36),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16141C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.15)),
                ),
                child: TabBar(
                  controller: _tab,
                  labelColor: const Color(0xFFC9A84C),
                  unselectedLabelColor: const Color(0xFF9B9199),
                  indicator: BoxDecoration(
                    color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: 'تسجيل الدخول'), Tab(text: 'حساب جديد')],
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE05555).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE05555).withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8080), fontSize: 13)),
                ),
              if (_error != null) const SizedBox(height: 16),

              // Tab content
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    // ── Login ──
                    Column(children: [
                      _buildInput(_loginEmailCtrl, 'البريد الإلكتروني', Icons.email_outlined, isEmail: true),
                      const SizedBox(height: 12),
                      _buildInput(_loginPassCtrl, 'كلمة المرور', Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 24),
                      _buildBtn('دخول 💞', _login),
                    ]),
                    // ── Register ──
                    Column(children: [
                      _buildInput(_regNameCtrl, 'اسمك', Icons.person_outline),
                      const SizedBox(height: 12),
                      _buildInput(_regEmailCtrl, 'البريد الإلكتروني', Icons.email_outlined, isEmail: true),
                      const SizedBox(height: 12),
                      _buildInput(_regPassCtrl, 'كلمة المرور (٦ أحرف+)', Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 24),
                      _buildBtn('إنشاء الحساب ✨', _register),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon,
      {bool isPassword = false, bool isEmail = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && _obscure,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: Color(0xFFF0ECE2), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9B9199), fontSize: 13),
        prefixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF9B9199), size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        suffixIcon: Icon(icon, color: const Color(0xFFC9A84C).withValues(alpha: 0.5), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E1B27),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A84C), Color(0xFF9A6E2A)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: _loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: const TextStyle(
                  color: Color(0xFF0E0D12),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  LINK PARTNER SCREEN
// ══════════════════════════════════════════
class LinkPartnerScreen extends StatefulWidget {
  const LinkPartnerScreen({super.key});
  @override State<LinkPartnerScreen> createState() => _LinkPartnerScreenState();
}

class _LinkPartnerScreenState extends State<LinkPartnerScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;

  Future<void> _link() async {
    setState(() { _loading = true; _error = null; });
    final ok = await FirebaseService.linkPartner(_emailCtrl.text);
    setState(() { _loading = false; _success = ok; });
    if (!ok) setState(() => _error = 'لم يتم إيجاد هذا الحساب، تأكد من الإيميل');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0D12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💞', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('ربط الحسابات',
                style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFFC9A84C))),
              const SizedBox(height: 8),
              Text('أدخل إيميل شريكتك لربط الحسابين معاً',
                style: GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF9B9199)),
                textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (_success)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.3)),
                  ),
                  child: Column(children: [
                    const Text('🎉', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('تم الربط بنجاح!', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4ADE80))),
                    Text('الآن يمكنكما التواصل', style: GoogleFonts.tajawal(fontSize: 13, color: const Color(0xFF9B9199))),
                  ]),
                )
              else ...[
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05555).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE05555).withValues(alpha: 0.3)),
                    ),
                    child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8080), fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Color(0xFFF0ECE2), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'إيميل شريكتك',
                    hintStyle: const TextStyle(color: Color(0xFF9B9199)),
                    filled: true, fillColor: const Color(0xFF1E1B27),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.15))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.15))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.5))),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _loading ? null : _link,
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFF9A6E2A)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('ربط الحساب 💞', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0E0D12))),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => FirebaseService.logout(),
                child: Text('تسجيل خروج', style: GoogleFonts.tajawal(color: const Color(0xFF9B9199), fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
