import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/content_service.dart';
import '../widgets/love_widgets.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  static const route = '/notes';
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'الملاحظات',
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, NoteEditorScreen.route), child: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث في الملاحظات'), onChanged: (_) => setState(() {}))),
          Expanded(
            child: StreamBuilder<List<NoteItem>>(
              stream: ContentService.instance.notes(search.text),
              builder: (_, snapshot) {
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) return const EmptyState(icon: Icons.note_alt, title: 'بحبك يا هدهدتي', subtitle: 'اكتب حاجة تستاهل تتحفظ.');
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (_, i) => LoveCard(
                    onTap: () => Navigator.pushNamed(context, NoteEditorScreen.route, arguments: notes[i]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [if (notes[i].pinned) const Icon(Icons.push_pin, size: 18), Expanded(child: Text(notes[i].title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)))]),
                      const SizedBox(height: 6),
                      Text(notes[i].text, maxLines: 3, overflow: TextOverflow.ellipsis),
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
