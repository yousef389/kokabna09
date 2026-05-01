import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'storage_service.dart';

class ChatService {
  ChatService._();
  static final instance = ChatService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _messages => _db.collection('chats/main/messages');

  Stream<List<MessageItem>> messages() {
    return _messages.orderBy('createdAt', descending: true).limit(200).snapshots().map((s) => s.docs.map(MessageItem.fromDoc).toList());
  }

  Future<void> sendText(String text, {String? replyTo}) async {
    final uid = _auth.currentUser!.uid;
    await _messages.add({
      'senderId': uid,
      'type': 'text',
      'text': text.trim(),
      'replyTo': replyTo,
      'pinned': false,
      'edited': false,
      'reactions': {},
      'seenBy': [uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendFile(File file, String folder, String type, {void Function(double progress)? onProgress}) async {
    final uid = _auth.currentUser!.uid;
    final uploaded = await StorageService.instance.uploadFile(file: file, folder: folder, onProgress: onProgress);
    await _messages.add({
      'senderId': uid,
      'type': type,
      'text': '',
      'mediaUrl': uploaded.url,
      'storagePath': uploaded.path,
      'fileName': uploaded.name,
      'mimeType': uploaded.type,
      'size': uploaded.size,
      'pinned': false,
      'edited': false,
      'reactions': {},
      'seenBy': [uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  Future<void> sendSticker(String sticker) async {
    final uid = _auth.currentUser!.uid;
    await _messages.add({
      'senderId': uid,
      'type': 'sticker',
      'text': sticker,
      'pinned': false,
      'edited': false,
      'reactions': {},
      'seenBy': [uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> react(String messageId, String reaction) async {
    final uid = _auth.currentUser!.uid;
    final ref = _messages.doc(messageId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
      for (final key in reactions.keys.toList()) {
        final list = List<String>.from(reactions[key] ?? []);
        list.remove(uid);
        reactions[key] = list;
      }
      final selected = List<String>.from(reactions[reaction] ?? []);
      if (!selected.contains(uid)) selected.add(uid);
      reactions[reaction] = selected;
      tx.update(ref, {'reactions': reactions, 'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> markSeen(String messageId) async {
    final uid = _auth.currentUser!.uid;
    await _messages.doc(messageId).update({'seenBy': FieldValue.arrayUnion([uid])});
  }

  Future<void> editMessage(String messageId, String text) async {
    await _messages.doc(messageId).update({'text': text.trim(), 'edited': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteMessage(String messageId) async => _messages.doc(messageId).delete();

  Future<void> togglePin(String messageId, bool value) async => _messages.doc(messageId).update({'pinned': value});
}
