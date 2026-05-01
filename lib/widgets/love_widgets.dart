import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  Scaffold الرئيسي مع تدرّج خلفية جميل
// ─────────────────────────────────────────────
class LoveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  const LoveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withOpacity(0.54),
            scheme.surface,
            scheme.secondaryContainer.withOpacity(0.35),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  بطاقة قابلة للضغط
// ─────────────────────────────────────────────
class LoveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const LoveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: card);
  }
}

// ─────────────────────────────────────────────
//  حالة فارغة جميلة
// ─────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  زر مع مؤشر تحميل
// ─────────────────────────────────────────────
class ProgressButton extends StatelessWidget {
  final bool busy;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const ProgressButton({
    super.key,
    required this.busy,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon),
      label: Text(label),
    );
  }
}

// ─────────────────────────────────────────────
//  عنوان قسم
// ─────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  const SectionTitle(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  بطاقة عداد الأيام معًا 💕
// ─────────────────────────────────────────────
class DaysTogetherCard extends StatelessWidget {
  final DateTime? startDate;
  const DaysTogetherCard({super.key, this.startDate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = startDate == null
        ? null
        : DateTime.now().difference(startDate!).inDays;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: scheme.primary, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days == null ? '—' : '$days يوم معًا',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  startDate == null
                      ? 'حدّد تاريخ بدايتكم في الإعدادات'
                      : 'منذ ${_formatDate(startDate!)}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: scheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ─────────────────────────────────────────────
//  شريط نسخ النص
// ─────────────────────────────────────────────
class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const CopyableText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم النسخ ✅')));
      },
      child: SelectableText(text, style: style),
    );
  }
}

// ─────────────────────────────────────────────
//  شارة حالة الشريك
// ─────────────────────────────────────────────
class PartnerBadge extends StatelessWidget {
  final String? partnerUid;
  const PartnerBadge({super.key, this.partnerUid});

  @override
  Widget build(BuildContext context) {
    final joined = partnerUid != null;
    final color = joined ? Colors.green : Colors.orange;
    return Chip(
      avatar: Icon(joined ? Icons.check_circle : Icons.hourglass_empty, color: color, size: 18),
      label: Text(joined ? 'الشريك انضم ✅' : 'في انتظار الشريك…', style: GoogleFonts.cairo()),
      backgroundColor: color.withOpacity(0.12),
    );
  }
}

// ─────────────────────────────────────────────
//  تحية بحسب الوقت
// ─────────────────────────────────────────────
String timeGreeting() {
  final h = DateTime.now().hour;
  if (h < 5)  return 'طبتِ ليلاً 🌙';
  if (h < 12) return 'صباح النور ☀️';
  if (h < 17) return 'مساء الخير 🌤️';
  if (h < 21) return 'مساء النور 🌅';
  return 'طبتِ ليلاً 🌙';
}
