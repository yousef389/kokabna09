import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/love_widgets.dart';

class SettingsScreen extends StatelessWidget {
  static const route = '/settings';
  const SettingsScreen({super.key});

  String _roleName(String? role) {
    switch (role) {
      case 'admin':   return 'الأدمن 👑';
      case 'partner': return 'الشريك 💕';
      default:        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return LoveScaffold(
      title: 'الإعدادات ⚙️',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ═══ الملف الشخصي ═══
          LoveCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('الملف الشخصي', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _InfoRow(Icons.person, 'الاسم',   state.profile?.nickname ?? '—'),
            _InfoRow(Icons.email,  'البريد',  state.profile?.email    ?? '—'),
            _InfoRow(Icons.badge,  'الدور',   _roleName(state.profile?.role)),
          ])),

          // ═══ الثنائي ═══
          const SectionTitle('معلومات الثنائي', icon: Icons.favorite),
          LoveCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _InfoRow(Icons.home, 'اسم المنزل', state.couple?.coupleName ?? '—'),
            const SizedBox(height: 12),
            PartnerBadge(partnerUid: state.couple?.partnerUid),
          ])),

          // ═══ تاريخ البداية ═══
          const SectionTitle('تاريخ بدايتكم', icon: Icons.calendar_today),
          LoveCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(state.couple?.startDate == null
                  ? 'لم يُحدَّد بعد'
                  : _fmtDate(state.couple!.startDate!)),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.edit_calendar),
                label: const Text('تعديل التاريخ'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.couple?.startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    helpText: 'متى بدأت قصتكم؟',
                    locale: const Locale('ar'),
                  );
                  if (picked != null) await state.setStartDate(picked);
                },
              ),
            ]),
          ),

          // ═══ الثيم ═══
          const SectionTitle('الثيم', icon: Icons.palette),
          ...[
            (AppTheme.pink,   'وردي رومانسي 🌸',  Icons.favorite),
            (AppTheme.dark,   'داكن رومانسي 🌙',   Icons.nightlight),
            (AppTheme.purple, 'بنفسجي ليلي 💜',   Icons.auto_awesome),
            (AppTheme.white,  'أبيض بسيط 🤍',     Icons.circle_outlined),
            (AppTheme.gold,   'ذهبي فاخر ✨',      Icons.star),
            (AppTheme.teal,   'تيل هادئ 🌿',       Icons.spa),
          ].map((t) => RadioListTile<String>(
            value: t.$1,
            groupValue: state.themeName,
            title: Row(children: [Icon(t.$3, size: 18), const SizedBox(width: 8), Text(t.$2)]),
            onChanged: (v) => v == null ? null : state.setTheme(v),
          )),

          // ═══ الخصوصية ═══
          const SectionTitle('الخصوصية', icon: Icons.lock),
          const LoveCard(child: Text(
            'البيانات لا يقرأها أو يكتبها إلا الحسابان الموجودان في Our Planet.\n'
            'لا منشورات عامة · لا بحث · لا إعلانات.',
          )),

          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () => state.signOut().then(
              (_) => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day} / ${d.month} / ${d.year}';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
