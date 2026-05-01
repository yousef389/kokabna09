import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/content_service.dart';
import '../widgets/love_widgets.dart';
import 'album_detail_screen.dart';

class AlbumsScreen extends StatelessWidget {
  static const route = '/albums';
  const AlbumsScreen({super.key});

  Future<void> createAlbum(BuildContext context) async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('ألبوم جديد'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'العنوان')),
        const SizedBox(height: 10),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'الوصف')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إنشاء'))],
    ));
    if (ok == true && title.text.trim().isNotEmpty) await ContentService.instance.createAlbum(title.text, desc.text, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return LoveScaffold(
      title: 'الألبومات',
      floatingActionButton: FloatingActionButton(onPressed: () => createAlbum(context), child: const Icon(Icons.add)),
      body: StreamBuilder<List<AlbumItem>>(
        stream: ContentService.instance.albums(),
        builder: (_, snapshot) {
          final albums = snapshot.data ?? [];
          if (albums.isEmpty) return const EmptyState(icon: Icons.photo_album, title: 'لا توجد ألبومات بعد', subtitle: 'بحبك يا هدهدتي');
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .82, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: albums.length,
            itemBuilder: (_, i) {
              final album = albums[i];
              return LoveCard(
                onTap: () => Navigator.pushNamed(context, AlbumDetailScreen.route, arguments: album),
                padding: EdgeInsets.zero,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: album.coverUrl == null ? Container(color: Theme.of(context).colorScheme.primaryContainer, child: const Center(child: Icon(Icons.favorite))) : CachedNetworkImage(imageUrl: album.coverUrl!, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(album.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  )
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
