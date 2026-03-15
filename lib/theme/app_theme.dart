import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════
//  THEME IDS
// ══════════════════════════════════════════
enum AppThemeId { golden, rose, ocean, forest, lavender, sunset }

class AppThemeData {
  final AppThemeId id;
  final String nameAr;
  final String descAr;
  final String emoji;
  final Color primary;
  final Color bg;
  final Color surface1;
  final Color surface2;
  final Color surface3;

  const AppThemeData({
    required this.id,
    required this.nameAr,
    required this.descAr,
    required this.emoji,
    required this.primary,
    required this.bg,
    required this.surface1,
    required this.surface2,
    required this.surface3,
  });

  Color get primaryDim => primary.withOpacity(0.15);
  Color get primaryMini => primary.withOpacity(0.07);
  Color get border => primary.withOpacity(0.18);
}

// ══════════════════════════════════════════
//  ALL THEMES
// ══════════════════════════════════════════
const Map<AppThemeId, AppThemeData> appThemes = {
  AppThemeId.golden: AppThemeData(
    id: AppThemeId.golden,
    nameAr: 'ذهبي دافئ',
    descAr: 'الكلاسيكي الرومانسي',
    emoji: '✨',
    primary: Color(0xFFC9A84C),
    bg: Color(0xFF0E0D12),
    surface1: Color(0xFF16141C),
    surface2: Color(0xFF1E1B27),
    surface3: Color(0xFF272330),
  ),
  AppThemeId.rose: AppThemeData(
    id: AppThemeId.rose,
    nameAr: 'ورد صيفي',
    descAr: 'لمسة وردية ناعمة',
    emoji: '🌹',
    primary: Color(0xFFE07A8E),
    bg: Color(0xFF120A0D),
    surface1: Color(0xFF1C1014),
    surface2: Color(0xFF26161B),
    surface3: Color(0xFF301C22),
  ),
  AppThemeId.ocean: AppThemeData(
    id: AppThemeId.ocean,
    nameAr: 'بحر هادئ',
    descAr: 'أزرق محيطي',
    emoji: '🌊',
    primary: Color(0xFF4FC3F7),
    bg: Color(0xFF050E18),
    surface1: Color(0xFF0A1525),
    surface2: Color(0xFF101D30),
    surface3: Color(0xFF18263B),
  ),
  AppThemeId.forest: AppThemeData(
    id: AppThemeId.forest,
    nameAr: 'غابة خضراء',
    descAr: 'طبيعة وهدوء',
    emoji: '🌿',
    primary: Color(0xFF81C784),
    bg: Color(0xFF071009),
    surface1: Color(0xFF0D1A0F),
    surface2: Color(0xFF132216),
    surface3: Color(0xFF1B2D1E),
  ),
  AppThemeId.lavender: AppThemeData(
    id: AppThemeId.lavender,
    nameAr: 'بنفسجي لطيف',
    descAr: 'حالم وعاطفي',
    emoji: '💜',
    primary: Color(0xFFCE93D8),
    bg: Color(0xFF0D0912),
    surface1: Color(0xFF150F1C),
    surface2: Color(0xFF1D1426),
    surface3: Color(0xFF261A30),
  ),
  AppThemeId.sunset: AppThemeData(
    id: AppThemeId.sunset,
    nameAr: 'غروب ذهبي',
    descAr: 'دفء وحنان',
    emoji: '🌅',
    primary: Color(0xFFFFB347),
    bg: Color(0xFF120A02),
    surface1: Color(0xFF1C1105),
    surface2: Color(0xFF261808),
    surface3: Color(0xFF30200C),
  ),
};

// ══════════════════════════════════════════
//  FIGHT THEME OVERRIDE
// ══════════════════════════════════════════
const AppThemeData fightTheme = AppThemeData(
  id: AppThemeId.golden,
  nameAr: 'وضع المشاجرة',
  descAr: '',
  emoji: '😤',
  primary: Color(0xFFE05555),
  bg: Color(0xFF120608),
  surface1: Color(0xFF1A080C),
  surface2: Color(0xFF220D12),
  surface3: Color(0xFF2D1118),
);

// ══════════════════════════════════════════
//  FLUTTER THEMEDATA BUILDER
// ══════════════════════════════════════════
ThemeData buildFlutterTheme(AppThemeData t) {
  final textTheme = GoogleFonts.tajawalTextTheme().apply(
    bodyColor: const Color(0xFFF0ECE2),
    displayColor: const Color(0xFFF0ECE2),
  );
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: t.bg,
    primaryColor: t.primary,
    colorScheme: ColorScheme.dark(
      primary: t.primary,
      secondary: const Color(0xFFE07A8E),
      surface: t.surface1,
      background: t.bg,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: t.surface1,
      elevation: 0,
      titleTextStyle: GoogleFonts.tajawal(
        color: const Color(0xFFF0ECE2),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: t.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: t.border, width: 1),
      ),
    ),
  );
}
