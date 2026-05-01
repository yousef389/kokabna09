import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/content_service.dart';
import '../widgets/love_widgets.dart';

class MemoriesScreen extends StatelessWidget {
  static const route = '/memories';
  const MemoriesScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final title  = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('ذكرى جديدة ✨'),
      content: TextField(
        controller: title,
        textDirection: ui.TextDirection.rtl,
        decoration: const InputDecoration(labelText: 'عنوان الذكرى'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        FilledButton(onPressed: () => Navigator.pop(context, true),  child: const Text('حفظ')),
      ],
    ));
    if (ok == true && title.text.trim().isNotEmpty) {
      await ContentService.instance.createMemory(title: title.text, favorite: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'ذكرياتنا 🌟',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('ذكرى جديدة'),
      ),
      body: StreamBuilder(
        stream: ContentService.instance.memories(),
        builder: (_, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline,
              title: 'لا توجد ذكريات بعد',
              subtitle: 'أضيفوا أجمل لحظاتكم معًا ❤️',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final date = d['createdAt']?.toDate() as DateTime?;
              final fav  = d['favorite'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LoveCard(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // صورة أو أيقونة
                    if (d['mediaUrl'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(imageUrl: d['mediaUrl'], width: 80, height: 80, fit: BoxFit.cover),
                      )
                    else
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(fav ? Icons.favorite : Icons.auto_awesome,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d['title'] ?? 'ذكرى',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (date != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMMM yyyy', 'ar').format(date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(d['source'] ?? 'يدوي',
                          style: Theme.of(context).textTheme.bodySmall),
                    ])),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
