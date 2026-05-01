import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../services/chat_service.dart';
import '../widgets/love_widgets.dart';

class ChatScreen extends StatefulWidget {
  static const route = '/chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final text = TextEditingController();
  double uploadProgress = 0;

  @override
  void dispose() { text.dispose(); super.dispose(); }

  Future<void> send() async {
    if (text.text.trim().isEmpty) return;
    await ChatService.instance.sendText(text.text);
    text.clear();
  }

  Future<void> _pickImage(ImageSource src) async {
    final img = await ImagePicker().pickImage(source: src, imageQuality: 82);
    if (img == null) return;
    await ChatService.instance.sendFile(File(img.path), 'chat_media', 'image',
        onProgress: (p) => setState(() => uploadProgress = p));
    setState(() => uploadProgress = 0);
  }

  Future<void> _pickVideo() async {
    final v = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (v == null) return;
    await ChatService.instance.sendFile(File(v.path), 'chat_media', 'video',
        onProgress: (p) => setState(() => uploadProgress = p));
    setState(() => uploadProgress = 0);
  }

  Future<void> _pickAudio() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = r?.files.single.path; if (path == null) return;
    await ChatService.instance.sendFile(File(path), 'audio', 'audio',
        onProgress: (p) => setState(() => uploadProgress = p));
    setState(() => uploadProgress = 0);
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles();
    final path = r?.files.single.path; if (path == null) return;
    await ChatService.instance.sendFile(File(path), 'chat_media', 'file',
        onProgress: (p) => setState(() => uploadProgress = p));
    setState(() => uploadProgress = 0);
  }

  Future<void> _stickers() async {
    final s = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('الملصقات', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: ['💖','💋','🌹','🧸','💍','🥰','✨','💕','🫶','🐣','😘','🌙','⭐','🎁','🌺']
                .map((e) => ActionChip(label: Text(e, style: const TextStyle(fontSize: 28)),
                    onPressed: () => Navigator.pop(context, e)))
                .toList(),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
    if (s != null) await ChatService.instance.sendSticker(s);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.watch<AppState>().user?.uid;
    return LoveScaffold(
      title: 'دردشتنا 💬',
      actions: [
        IconButton(icon: const Icon(Icons.image),           onPressed: () => _pickImage(ImageSource.gallery)),
        IconButton(icon: const Icon(Icons.videocam),        onPressed: _pickVideo),
        IconButton(icon: const Icon(Icons.mic),             onPressed: _pickAudio),
        IconButton(icon: const Icon(Icons.emoji_emotions),  onPressed: _stickers),
        IconButton(icon: const Icon(Icons.attach_file),     onPressed: _pickFile),
      ],
      body: Column(children: [
        if (uploadProgress > 0)
          LinearProgressIndicator(value: uploadProgress),
        Expanded(
          child: StreamBuilder<List<MessageItem>>(
            stream: ChatService.instance.messages(),
            builder: (context, snapshot) {
              final msgs = snapshot.data ?? [];
              if (msgs.isEmpty) {
                return const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'بحبك يا هدهدتي ❤️',
                  subtitle: 'أرسل أول رسالة.',
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: msgs.length,
                itemBuilder: (_, i) =>
                    _MsgBubble(message: msgs[i], mine: msgs[i].senderId == myUid),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.camera_alt), onPressed: () => _pickImage(ImageSource.camera)),
              Expanded(
                child: TextField(
                  controller: text,
                  minLines: 1, maxLines: 5,
                  textDirection: ui.TextDirection.rtl,
                  decoration: const InputDecoration(hintText: 'اكتب رسالتك... ❤️'),
                  onSubmitted: (_) => send(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(onPressed: send, child: const Icon(Icons.send)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  فقاعة الرسالة
// ─────────────────────────────────────────────
class _MsgBubble extends StatelessWidget {
  final MessageItem message;
  final bool mine;
  const _MsgBubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timeStr = message.createdAt == null
        ? ''
        : DateFormat('hh:mm a', 'ar').format(message.createdAt!);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Card(
          color: mine ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.pinned)
                  const Row(mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.push_pin, size: 14), SizedBox(width: 4), Text('مثبّت')]),
                _content(context),
                const SizedBox(height: 4),
                // وقت + حالة التعديل
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if (message.edited)
                    Text('تم التعديل • ', style: Theme.of(context).textTheme.labelSmall),
                  Text(timeStr, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                ]),
                // ردود الفعل
                Wrap(spacing: 4, children: ['❤️','😂','🥺','😮','😘','💍']
                    .map((r) => InkWell(
                        onTap: () => ChatService.instance.react(message.id, r),
                        child: Text('$r${message.reactions[r]?.isNotEmpty == true ? message.reactions[r]!.length.toString() : ''}')))
                    .toList()),
                // أزرار الإجراءات
                Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: mine ? () => _edit(context) : null),
                  IconButton(icon: Icon(message.pinned ? Icons.push_pin : Icons.push_pin_outlined, size: 16),
                      onPressed: () => ChatService.instance.togglePin(message.id, !message.pinned)),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 16),
                      onPressed: () => ChatService.instance.deleteMessage(message.id)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    switch (message.type) {
      case 'image':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: message.mediaUrl ?? '', fit: BoxFit.cover)),
          if ((message.fileName ?? '').isNotEmpty) Text(message.fileName!),
        ]);
      case 'video':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.play_circle), const SizedBox(width: 8),
          Flexible(child: Text(message.fileName ?? 'فيديو')),
        ]);
      case 'audio':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.audiotrack), const SizedBox(width: 8),
          Flexible(child: Text(message.fileName ?? 'صوت')),
        ]);
      case 'sticker':
        return Text(message.text, style: const TextStyle(fontSize: 52));
      case 'file':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.insert_drive_file), const SizedBox(width: 8),
          Flexible(child: Text(message.fileName ?? 'ملف')),
        ]);
      default:
        return Text(message.text, style: Theme.of(context).textTheme.bodyLarge);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final c = TextEditingController(text: message.text);
    final val = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل الرسالة'),
        content: TextField(controller: c, maxLines: 4, textDirection: ui.TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('حفظ')),
        ],
      ),
    );
    if (val != null && val.trim().isNotEmpty) await ChatService.instance.editMessage(message.id, val);
  }
}
