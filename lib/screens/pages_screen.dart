import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/page_service.dart';
import '../widgets/love_widgets.dart';
import 'page_editor_screen.dart';
import 'webview_preview_screen.dart';

class PagesScreen extends StatefulWidget {
  static const route = '/pages';
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> createPage() async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('صفحة خاصة جديدة'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان المشروع')),
        const SizedBox(height: 10),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'الوصف')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إنشاء'))],
    ));
    if (ok == true && title.text.trim().isNotEmpty) {
      final id = await PageService.instance.createPage(title: title.text, description: desc.text);
      if (mounted) Navigator.pushNamed(context, PageEditorScreen.route, arguments: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'الصفحات الخاصة',
      floatingActionButton: FloatingActionButton(onPressed: createPage, child: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث في الصفحات'), onChanged: (_) => setState(() {}))),
          Expanded(
            child: StreamBuilder<List<PageProject>>(
              stream: PageService.instance.pages(search.text),
              builder: (_, snapshot) {
                final pages = snapshot.data ?? [];
                if (pages.isEmpty) return const EmptyState(icon: Icons.web_asset, title: 'لا توجد صفحات خاصة بعد', subtitle: 'بحبك يا هدهدتي');
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pages.length,
                  itemBuilder: (_, i) => LoveCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pages[i].title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(pages[i].description),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, children: [
                        FilledButton.icon(onPressed: () => Navigator.pushNamed(context, WebViewPreviewScreen.route, arguments: pages[i].id), icon: const Icon(Icons.visibility), label: const Text('معاينة')),
                        OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, PageEditorScreen.route, arguments: pages[i].id), icon: const Icon(Icons.edit), label: const Text('تعديل الملفات')),
                        IconButton(onPressed: () => PageService.instance.deletePage(pages[i].id), icon: const Icon(Icons.delete_outline)),
                      ])
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
