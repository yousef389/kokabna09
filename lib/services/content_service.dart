import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'storage_service.dart';

class ContentService {
  ContentService._();
  static final instance = ContentService._();

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String get uid => auth.currentUser!.uid;

  Stream<List<NoteItem>> notes(String search) {
    return db.collection('notes').orderBy('pinned', descending: true).orderBy('createdAt', descending: true).snapshots().map((s) {
      final items = s.docs.map(NoteItem.fromDoc).toList();
      if (search.trim().isEmpty) return items;
      final q = search.toLowerCase();
      return items.where((n) => n.title.toLowerCase().contains(q) || n.text.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> saveNote({String? id, required String title, required String text, bool pinned = false, File? media}) async {
    String? mediaUrl;
    if (media != null) {
      mediaUrl = (await StorageService.instance.uploadFile(file: media, folder: 'notes')).url;
    }
    final data = {
      'title': title.trim(),
      'text': text.trim(),
      'pinned': pinned,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'createdBy': uid,
      'date': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (id == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await db.collection('notes').add(data);
    } else {
      await db.collection('notes').doc(id).update(data);
    }
  }

  Future<void> deleteNote(String id) => db.collection('notes').doc(id).delete();

  Stream<List<AlbumItem>> albums() {
    return db.collection('albums').orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(AlbumItem.fromDoc).toList());
  }

  Future<String> createAlbum(String title, String description, DateTime? date) async {
    final doc = await db.collection('albums').add({
      'title': title.trim(),
      'description': description.trim(),
      'coverUrl': null,
      'date': date == null ? null : Timestamp.fromDate(date),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> albumItems(String albumId) {
    return db.collection('album_items').where('albumId', isEqualTo: albumId).orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addAlbumMedia(String albumId, File file, String caption, String mediaType) async {
    final uploaded = await StorageService.instance.uploadFile(file: file, folder: 'albums/$albumId');
    final data = {
      'albumId': albumId,
      'createdBy': uid,
      'caption': caption.trim(),
      'mediaType': mediaType,
      'mediaUrl': uploaded.url,
      'storagePath': uploaded.path,
      'reactions': {},
      'comments': [],
      'createdAt': FieldValue.serverTimestamp(),
    };
    await db.collection('album_items').add(data);
    final album = await db.collection('albums').doc(albumId).get();
    if ((album.data()?['coverUrl']) == null) {
      await db.collection('albums').doc(albumId).update({'coverUrl': uploaded.url});
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> stories() {
    final cutoff = Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));
    return db.collection('stories').where('createdAt', isGreaterThan: cutoff).orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createStory({required String type, String text = '', File? media, bool saveAsMemory = false}) async {
    String? mediaUrl;
    if (media != null) mediaUrl = (await StorageService.instance.uploadFile(file: media, folder: 'stories')).url;
    final doc = await db.collection('stories').add({
      'type': type,
      'caption': text.trim(),
      'mediaUrl': mediaUrl,
      'createdBy': uid,
      'seenBy': [uid],
      'reactions': {},
      'saveAsMemory': saveAsMemory,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (saveAsMemory) {
      await db.collection('memories').add({
        'source': 'story',
        'sourceId': doc.id,
        'title': text.trim().isEmpty ? 'ذكرى من قصة' : text.trim(),
        'mediaUrl': mediaUrl,
        'favorite': false,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> markStorySeen(String id) => db.collection('stories').doc(id).update({'seenBy': FieldValue.arrayUnion([uid])});

  Stream<List<PrivateFileItem>> files(String search) {
    return db.collection('files').orderBy('createdAt', descending: true).snapshots().map((s) {
      final items = s.docs.map(PrivateFileItem.fromDoc).toList();
      if (search.trim().isEmpty) return items;
      final q = search.toLowerCase();
      return items.where((f) => f.name.toLowerCase().contains(q) || f.folder.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> uploadCloudFile(File file, String folder, {void Function(double progress)? onProgress}) async {
    final uploaded = await StorageService.instance.uploadFile(file: file, folder: 'cloud/$folder', onProgress: onProgress);
    await db.collection('files').add({
      'name': uploaded.name,
      'type': uploaded.type,
      'folder': folder.trim().isEmpty ? '/' : folder.trim(),
      'storagePath': uploaded.path,
      'downloadUrl': uploaded.url,
      'size': uploaded.size,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> memories() {
    return db.collection('memories').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createMemory({required String title, String? mediaUrl, bool favorite = false}) async {
    await db.collection('memories').add({
      'title': title.trim(),
      'mediaUrl': mediaUrl,
      'favorite': favorite,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
