import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/content_service.dart';
import '../widgets/love_widgets.dart';
import 'file_preview_screen.dart';

class CloudFilesScreen extends StatefulWidget {
  static const route = '/cloud';
  const CloudFilesScreen({super.key});

  @override
  State<CloudFilesScreen> createState() => _CloudFilesScreenState();
}

class _CloudFilesScreenState extends State<CloudFilesScreen> {
  final search = TextEditingController();
  double progress = 0;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> upload() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;
    final folder = await _folderDialog();
    await ContentService.instance.uploadCloudFile(File(path), folder ?? '/', onProgress: (p) => setState(() => progress = p));
    setState(() => progress = 0);
  }

  Future<String?> _folderDialog() async {
    final c = TextEditingController(text: '/');
    return showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('المجلد'),
      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'مسار المجلد')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('رفع'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'الملفات المشتركة',
      floatingActionButton: FloatingActionButton(onPressed: upload, child: const Icon(Icons.upload_file)),
      body: Column(
        children: [
          if (progress > 0) LinearProgressIndicator(value: progress),
          Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث في الملفات'), onChanged: (_) => setState(() {}))),
          Expanded(
            child: StreamBuilder<List<PrivateFileItem>>(
              stream: ContentService.instance.files(search.text),
              builder: (_, snapshot) {
                final files = snapshot.data ?? [];
                if (files.isEmpty) return const EmptyState(icon: Icons.cloud, title: 'لا توجد ملفات', subtitle: 'بحبك يا هدهدتي');
                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(files[i].name),
                    subtitle: Text('${files[i].folder} • ${files[i].type}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, FilePreviewScreen.route, arguments: files[i]),
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
