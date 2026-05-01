import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../widgets/love_widgets.dart';
import 'albums_screen.dart';
import 'cloud_files_screen.dart';
import 'notes_screen.dart';
import 'pages_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const route = '/admin';
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? invite;
  bool busy = false;

  Future<void> _createInvite() async {
    setState(() => busy = true);
    final code = await AuthService.instance.createInviteCode();
    setState(() { invite = code; busy = false; });
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    if (!state.isAdmin) {
      return const LoveScaffold(
        title: 'الإدارة',
        body: EmptyState(icon: Icons.lock, title: 'للأدمن فقط 🔒', subtitle: 'بحبك يا هدهدتي'),
      );
    }

    return LoveScaffold(
      title: 'لوحة الإدارة 👑',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ═══ دعوة الشريك ═══
          LoveCard(
            color: scheme.primaryContainer,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('دعوة الشريك', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              PartnerBadge(partnerUid: state.couple?.partnerUid),
              const SizedBox(height: 12),
              ProgressButton(busy: busy, label: 'توليد كود دعوة جديد', icon: Icons.mail_lock, onPressed: _createInvite),
              if (invite != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('شارك هذا الكود مع شريكك:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    CopyableText(
                      invite!,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('اضغط مطولاً للنسخ 📋', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ),
              ],
            ]),
          ),

          // ═══ إدارة المحتوى ═══
          const SectionTitle('إدارة المحتوى', icon: Icons.folder),
          _AdminTile('الملفات السحابية',  Icons.cloud,         CloudFilesScreen.route),
          _AdminTile('الألبومات',          Icons.photo_album,   AlbumsScreen.route),
          _AdminTile('القصص',              Icons.auto_stories,  StoriesScreen.route),
          _AdminTile('الملاحظات',          Icons.note_alt,      NotesScreen.route),
          _AdminTile('الصفحات الخاصة',    Icons.web_asset,     PagesScreen.route),
          _AdminTile('الثيم والإعدادات',  Icons.settings,      SettingsScreen.route),

          // ═══ التخزين ═══
          const SectionTitle('التخزين', icon: Icons.storage),
          const LoveCard(child: Text(
            'تفاصيل استخدام التخزين متاحة في Firebase Console.\n'
            'أضف دالة سحابية لاحقًا لعرض الاستهلاك الدقيق هنا.',
          )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  const _AdminTile(this.title, this.icon, this.route);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
