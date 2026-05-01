import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/content_service.dart';
import '../widgets/love_widgets.dart';

class StoriesScreen extends StatefulWidget {
  static const route = '/stories';
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  Future<void> addTextStory() async {
    final c = TextEditingController();
    final text = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('قصة نصية'),
      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'نص القصة')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('نشر'))],
    ));
    if (text != null && text.trim().isNotEmpty) await ContentService.instance.createStory(type: 'text', text: text);
  }

  Future<void> addMediaStory(bool video) async {
    final picker = ImagePicker();
    final picked = video ? await picker.pickVideo(source: ImageSource.gallery) : await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked == null) return;
    await ContentService.instance.createStory(type: video ? 'video' : 'image', media: File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'القصص',
      actions: [
        IconButton(icon: const Icon(Icons.text_fields), onPressed: addTextStory),
        IconButton(icon: const Icon(Icons.image), onPressed: () => addMediaStory(false)),
        IconButton(icon: const Icon(Icons.videocam), onPressed: () => addMediaStory(true)),
      ],
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ContentService.instance.stories(),
        builder: (_, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const EmptyState(icon: Icons.auto_stories, title: 'لا توجد قصص نشطة', subtitle: 'بحبك يا هدهدتي');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final type = d['type'] ?? 'text';
              return LoveCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (type == 'image' && d['mediaUrl'] != null) ClipRRect(borderRadius: BorderRadius.circular(18), child: CachedNetworkImage(imageUrl: d['mediaUrl'])),
                  if (type == 'video') Row(children: const [Icon(Icons.play_circle), SizedBox(width: 8), Text('قصة فيديو')]),
                  if ((d['caption'] ?? '').toString().isNotEmpty) Text(d['caption'], style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('شاهده ${(d['seenBy'] as List?)?.length ?? 0}'),
                  Wrap(spacing: 8, children: ['❤️', '😘', '🥰', '✨'].map((e) => ActionChip(label: Text(e), onPressed: () {})).toList()),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
