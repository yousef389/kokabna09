import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/chat_service.dart';
import '../widgets/love_widgets.dart';
import 'admin_dashboard_screen.dart';
import 'albums_screen.dart';
import 'calls_screen.dart';
import 'chat_screen.dart';
import 'cloud_files_screen.dart';
import 'memories_screen.dart';
import 'notes_screen.dart';
import 'pages_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    _HomePage(),
    ChatScreen(),
    AlbumsScreen(),
    MemoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        backgroundColor: scheme.surface.withOpacity(0.95),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'الشات'),
          NavigationDestination(icon: Icon(Icons.photo_album_outlined), selectedIcon: Icon(Icons.photo_album), label: 'الألبومات'),
          NavigationDestination(icon: Icon(Icons.timeline_outlined), selectedIcon: Icon(Icons.timeline), label: 'الذكريات'),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final coupleName = state.couple?.coupleName ?? 'Our Planet';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.54),
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.35),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(coupleName),
          actions: [
            if (state.isAdmin)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () => Navigator.pushNamed(context, AdminDashboardScreen.route),
              ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ══ تحية الوقت ══
              LoveCard(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(timeGreeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('بحبك يا هدهدتي 💕'),
                  const SizedBox(height: 6),
                  Text(state.isAdmin ? 'لوحة الإدارة جاهزة.' : 'عالمكم الخاص جاهز. لا منشورات عامة ولا غرباء.'),
                ]),
              ),

              const SizedBox(height: 12),

              // ══ عداد الأيام ══
              DaysTogetherCard(startDate: state.couple?.startDate),

              // ══ آخر رسالة ══
              const SectionTitle('آخر رسالة', icon: Icons.chat_bubble_outline),
              StreamBuilder(
                stream: ChatService.instance.messages(),
                builder: (context, snapshot) {
                  final data  = snapshot.data ?? [];
                  final latest = data.isEmpty ? null : data.first;
                  return LoveCard(
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                    child: Text(latest == null
                        ? 'لا توجد رسائل بعد ❤️'
                        : (latest.type == 'text'
                            ? latest.text
                            : '📎 ملف: ${latest.fileName ?? ''}')),
                  );
                },
              ),

              // ══ اختصارات ══
              const SectionTitle('اختصارات سريعة', icon: Icons.grid_view),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _Tile('المكالمات',  Icons.video_call,   CallsScreen.route),
                  _Tile('القصص',     Icons.auto_stories,  StoriesScreen.route),
                  _Tile('الملاحظات', Icons.note_alt,      NotesScreen.route),
                  _Tile('الملفات',   Icons.cloud,         CloudFilesScreen.route),
                  _Tile('الصفحات',   Icons.web_asset,     PagesScreen.route),
                  _Tile('إعدادات',   Icons.settings,      SettingsScreen.route),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  const _Tile(this.title, this.icon, this.route);

  @override
  Widget build(BuildContext context) {
    return LoveCard(
      padding: const EdgeInsets.all(8),
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
