import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';

import '../models/models.dart';
import 'storage_service.dart';

class PageService {
  PageService._();
  static final instance = PageService._();

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String get uid => auth.currentUser!.uid;

  Stream<List<PageProject>> pages(String search) {
    return db
        .collection('pages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
      final items = s.docs.map(PageProject.fromDoc).toList();
      if (search.trim().isEmpty) return items;
      final q = search.toLowerCase();
      return items
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<String> createPage({
    required String title,
    required String description,
  }) async {
    final doc = await db.collection('pages').add({
      'title': title.trim(),
      'description': description.trim(),
      'createdBy': uid,
      'reactions': {},
      'comments': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> uploadPageFile(String pageId, File file) async {
    final uploaded = await StorageService.instance.uploadFile(
      file: file,
      folder: 'pages/$pageId',
    );
    final safeName =
        StorageService.instance.sanitizeFileName(uploaded.name);
    await db.collection('page_files').add({
      'pageId': pageId,
      'name': safeName,
      'storagePath': uploaded.path,
      'downloadUrl': uploaded.url,
      'type': lookupMimeType(file.path) ?? uploaded.type,
      'size': uploaded.size,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await db
        .collection('pages')
        .doc(pageId)
        .update({'updatedAt': FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pageFiles(String pageId) {
    return db
        .collection('page_files')
        .where('pageId', isEqualTo: pageId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deletePage(String pageId) async {
    await db.collection('pages').doc(pageId).delete();
    final files = await db
        .collection('page_files')
        .where('pageId', isEqualTo: pageId)
        .get();
    for (final doc in files.docs) {
      await doc.reference.delete();
    }
  }

  Future<String> buildPreviewHtml(String pageId) async {
    final files = await db
        .collection('page_files')
        .where('pageId', isEqualTo: pageId)
        .get();

    final byName = {
      for (final d in files.docs)
        (d.data()['name'] ?? '').toString(): d.data()
    };

    Map<String, dynamic>? index;
    for (final item in byName.values) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      if (name == 'index.html' ||
          (index == null && name.endsWith('.html'))) {
        index = item;
      }
    }

    if (index == null) {
      return _safeShell(
        '<h1>لم يتم رفع index.html</h1>'
        '<p>ارفع index.html و style.css و script.js.</p>',
      );
    }

    final htmlBytes = await StorageService.instance.downloadBytes(
      index['storagePath'],
      maxSize: 4 * 1024 * 1024,
    );
    var html = utf8.decode(htmlBytes ?? []);
    html = _removeDangerousTags(html);

    for (final entry in byName.entries) {
      final name = entry.key;
      final data = entry.value;

      if (name.endsWith('.css')) {
        final bytes = await StorageService.instance.downloadBytes(
          data['storagePath'],
          maxSize: 1024 * 1024,
        );
        final css = utf8.decode(bytes ?? []);
        html = html.replaceAll(
          RegExp(
            '<link[^>]+href=["\\\']${RegExp.escape(name)}["\\\'][^>]*>',
            caseSensitive: false,
          ),
          '<style>$css</style>',
        );
      } else if (name.endsWith('.js')) {
        final bytes = await StorageService.instance.downloadBytes(
          data['storagePath'],
          maxSize: 1024 * 1024,
        );
        final js = utf8.decode(bytes ?? []);
        html = html.replaceAll(
          RegExp(
            '<script[^>]+src=["\\\']${RegExp.escape(name)}["\\\'][^>]*>\\s*</script>',
            caseSensitive: false,
          ),
          '<script>$js</script>',
        );
      } else if (_isLikelyAsset(name)) {
        final url = data['downloadUrl'];
        if (url != null) html = html.replaceAll(name, url);
      }
    }

    return _safeShell(html);
  }

  bool _isLikelyAsset(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.svg') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.woff') ||
        lower.endsWith('.woff2');
  }

  String _removeDangerousTags(String html) {
    return html
        .replaceAll(
          RegExp(r'<iframe[\s\S]*?</iframe>', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'<object[\s\S]*?</object>', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'<embed[\s\S]*?</embed>', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'<meta[^>]+http-equiv=[^>]*>', caseSensitive: false),
          '',
        );
  }

  String _safeShell(String body) {
    return '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<style>
  body {
    margin: 0;
    padding: 16px;
    font-family: system-ui, -apple-system, sans-serif;
    background: #fff7fb;
    color: #2b1520;
  }
  img, video {
    max-width: 100%;
    border-radius: 16px;
  }
  button, input, textarea {
    border-radius: 12px;
    padding: 10px;
  }
</style>
</head>
<body>
$body
<script>
  window.open = function(){ return null; };
</script>
</body>
</html>
''';
  }
}
