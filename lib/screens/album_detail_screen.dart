import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/content_service.dart';
import '../widgets/love_widgets.dart';

class AlbumDetailScreen extends StatelessWidget {
  static const route = '/album-detail';
  const AlbumDetailScreen({super.key});

  Future<void> addMedia(BuildContext context, String albumId, bool video) async {
    final picked = video ? await ImagePicker().pickVideo(source: ImageSource.gallery) : await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked == null) return;
    await ContentService.instance.addAlbumMedia(albumId, File(picked.path), '', video ? 'video' : 'image');
  }

  @override
  Widget build(BuildContext context) {
    final album = ModalRoute.of(context)!.settings.arguments as AlbumItem;
    return LoveScaffold(
      title: album.title,
      actions: [
        IconButton(icon: const Icon(Icons.image), onPressed: () => addMedia(context, album.id, false)),
        IconButton(icon: const Icon(Icons.videocam), onPressed: () => addMedia(context, album.id, true)),
      ],
      body: StreamBuilder(
        stream: ContentService.instance.albumItems(album.id),
        builder: (_, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const EmptyState(icon: Icons.photo, title: 'الألبوم فاضي', subtitle: 'بحبك يا هدهدتي');
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final isVideo = d['mediaType'] == 'video';
              return InkWell(
                onTap: () => showDialog(context: context, builder: (_) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: isVideo
                        ? Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.play_circle, size: 72), Text(d['caption'] ?? 'فيديو')])
                        : CachedNetworkImage(imageUrl: d['mediaUrl'] ?? ''),
                  ),
                )),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(fit: StackFit.expand, children: [
                    if (isVideo) Container(color: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.play_circle)) else CachedNetworkImage(imageUrl: d['mediaUrl'] ?? '', fit: BoxFit.cover),
                    Positioned(bottom: 4, right: 4, child: Icon(isVideo ? Icons.videocam : Icons.image, color: Colors.white)),
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
