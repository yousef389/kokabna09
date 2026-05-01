import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/admin_dashboard_screen.dart';
import 'screens/album_detail_screen.dart';
import 'screens/albums_screen.dart';
import 'screens/calls_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/cloud_files_screen.dart';
import 'screens/file_preview_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/memories_screen.dart';
import 'screens/note_editor_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/page_editor_screen.dart';
import 'screens/pages_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/webview_preview_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

class KokabnaApp extends StatelessWidget {
  const KokabnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Our Planet',
      // ══════════════════════════════
      //  اللغة العربية + RTL كاملة
      // ══════════════════════════════
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.themeFor(state.themeName),
      home: const SplashScreen(),
      routes: {
        LoginScreen.route:         (_) => const LoginScreen(),
        HomeScreen.route:          (_) => const HomeScreen(),
        ChatScreen.route:          (_) => const ChatScreen(),
        CallsScreen.route:         (_) => const CallsScreen(),
        StoriesScreen.route:       (_) => const StoriesScreen(),
        AlbumsScreen.route:        (_) => const AlbumsScreen(),
        AlbumDetailScreen.route:   (_) => const AlbumDetailScreen(),
        NotesScreen.route:         (_) => const NotesScreen(),
        NoteEditorScreen.route:    (_) => const NoteEditorScreen(),
        CloudFilesScreen.route:    (_) => const CloudFilesScreen(),
        FilePreviewScreen.route:   (_) => const FilePreviewScreen(),
        PagesScreen.route:         (_) => const PagesScreen(),
        PageEditorScreen.route:    (_) => const PageEditorScreen(),
        WebViewPreviewScreen.route:(_) => const WebViewPreviewScreen(),
        MemoriesScreen.route:      (_) => const MemoriesScreen(),
        SettingsScreen.route:      (_) => const SettingsScreen(),
        AdminDashboardScreen.route:(_) => const AdminDashboardScreen(),
      },
    );
  }
}
