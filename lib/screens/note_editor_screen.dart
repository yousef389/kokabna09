import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/content_service.dart';
import '../widgets/love_widgets.dart';

class NoteEditorScreen extends StatefulWidget {
  static const route = '/note-editor';
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final title = TextEditingController();
  final text = TextEditingController();
  bool pinned = false;
  bool initialized = false;
  bool busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final note = ModalRoute.of(context)?.settings.arguments as NoteItem?;
    if (note != null) {
      title.text = note.title;
      text.text = note.text;
      pinned = note.pinned;
    }
    initialized = true;
  }

  @override
  void dispose() {
    title.dispose();
    text.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final note = ModalRoute.of(context)?.settings.arguments as NoteItem?;
    setState(() => busy = true);
    await ContentService.instance.saveNote(id: note?.id, title: title.text, text: text.text, pinned: pinned);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'محرر الملاحظات',
      actions: [IconButton(icon: const Icon(Icons.check), onPressed: busy ? null : save)],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'العنوان')),
          const SizedBox(height: 12),
          TextField(controller: text, minLines: 8, maxLines: 18, decoration: const InputDecoration(labelText: 'النص', hintText: 'بحبك يا هدهدتي')),
          SwitchListTile(value: pinned, onChanged: (v) => setState(() => pinned = v), title: const Text('تثبيت كملاحظة مفضلة')),
          ProgressButton(busy: busy, label: 'حفظ الملاحظة', icon: Icons.save, onPressed: save),
        ],
      ),
    );
  }
}
