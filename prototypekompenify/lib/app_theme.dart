import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// KOMPENIFY — Design System
// ─────────────────────────────────────────

class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryDark = Color(0xFF3730A3); // indigo-800
  static const Color accent = Color(0xFF7C3AED); // violet-600

  // Background
  static const Color bgPage = Color(0xFFF4F6FB);
  static const Color bgCard = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status pills
  static const Color redBg = Color(0xFFFEE2E2);
  static const Color redText = Color(0xFFB91C1C);

  static const Color yellowBg = Color(0xFFFEF3C7);
  static const Color yellowText = Color(0xFF92400E);

  static const Color blueBg = Color(0xFFDBEAFE);
  static const Color blueText = Color(0xFF1D4ED8);

  static const Color greenBg = Color(0xFFDCFCE7);
  static const Color greenText = Color(0xFF166534);

  // Avatar palette
  static const List<Color> avatarColors = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
  ];

  // Menu icon colors
  static const Color menuIndigoBg = Color(0xFFEEF2FF);
  static const Color menuIndigoFg = Color(0xFF6366F1);
  static const Color menuGreenBg = Color(0xFFF0FDF4);
  static const Color menuGreenFg = Color(0xFF16A34A);
  static const Color menuAmberBg = Color(0xFFFFFBEB);
  static const Color menuAmberFg = Color(0xFFD97706);
  static const Color menuPinkBg = Color(0xFFFDF2F8);
  static const Color menuPinkFg = Color(0xFFDB2777);
}

class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 32;
  static const double pill = 100;
}

class AppTextStyle {
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

// ─── Reusable Widgets ───────────────────────────────────────────────────────

// Status pill
class StatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const StatusPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

// Gradient header container used on multiple pages
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double bottomPadding;
  const GradientHeader({
    super.key,
    required this.child,
    this.bottomPadding = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _circle(200)),
          Positioned(bottom: -40, left: -40, child: _circle(160)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 56, 20, bottomPadding),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.06),
    ),
  );
}

// Section header row
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyle.h3),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

// Bottom nav bar — shared across pages
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Beranda'),
    (Icons.assignment_rounded, Icons.assignment_outlined, 'Tugas'),
    (Icons.notifications_rounded, Icons.notifications_outlined, 'Notif'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.07))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? item.$1 : item.$2,
                        color: active ? AppColors.primary : AppColors.textHint,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active ? 20 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
