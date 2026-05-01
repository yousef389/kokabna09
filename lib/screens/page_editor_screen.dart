import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/page_service.dart';
import '../widgets/love_widgets.dart';
import 'webview_preview_screen.dart';

class PageEditorScreen extends StatelessWidget {
  static const route = '/page-editor';
  const PageEditorScreen({super.key});

  Future<void> upload(BuildContext context, String pageId) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final files = result?.files ?? [];
    for (final item in files) {
      if (item.path != null) await PageService.instance.uploadPageFile(pageId, File(item.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageId = ModalRoute.of(context)!.settings.arguments as String;
    return LoveScaffold(
      title: 'مشروع الصفحة',
      actions: [
        IconButton(icon: const Icon(Icons.preview), onPressed: () => Navigator.pushNamed(context, WebViewPreviewScreen.route, arguments: pageId)),
        IconButton(icon: const Icon(Icons.upload_file), onPressed: () => upload(context, pageId)),
      ],
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: LoveCard(child: Text('ارفع ملفات الصفحة: index.html و style.css و script.js مع الصور والخطوط. أسماء الملفات يتم تنظيفها تلقائيًا قبل الرفع.')),
          ),
          Expanded(
            child: StreamBuilder(
              stream: PageService.instance.pageFiles(pageId),
              builder: (_, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.upload_file, title: 'لا توجد ملفات للصفحة', subtitle: 'بحبك يا هدهدتي');
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data();
                    return ListTile(
                      leading: Icon(_iconFor((d['name'] ?? '').toString())),
                      title: Text(d['name'] ?? ''),
                      subtitle: Text('${d['type'] ?? ''} • ${d['size'] ?? 0} بايت'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => upload(context, pageId), icon: const Icon(Icons.upload_file), label: const Text('رفع')),
    );
  }

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.html')) return Icons.code;
    if (n.endsWith('.css')) return Icons.code;
    if (n.endsWith('.js')) return Icons.code;
    if (n.endsWith('.png') || n.endsWith('.jpg') || n.endsWith('.webp')) return Icons.image;
    return Icons.insert_drive_file;
  }
}
