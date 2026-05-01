import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class UploadedFileResult {
  final String path;
  final String url;
  final String name;
  final String type;
  final int size;

  UploadedFileResult({required this.path, required this.url, required this.name, required this.type, required this.size});
}

class StorageService {
  StorageService._();
  static final instance = StorageService._();
  final _storage = FirebaseStorage.instance;

  Future<UploadedFileResult> uploadFile({required File file, required String folder, String? fileName, void Function(double progress)? onProgress}) async {
    final cleanName = sanitizeFileName(fileName ?? p.basename(file.path));
    final cleanFolder = sanitizeFolderPath(folder);
    final id = const Uuid().v4();
    final storagePath = 'main/$cleanFolder/$id-$cleanName';
    final ref = _storage.ref(storagePath);
    final contentType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final task = ref.putFile(file, SettableMetadata(contentType: contentType, customMetadata: {'originalName': cleanName}));
    task.snapshotEvents.listen((event) {
      final total = event.totalBytes;
      if (total > 0) onProgress?.call(event.bytesTransferred / total);
    });
    final snap = await task;
    final url = await snap.ref.getDownloadURL();
    return UploadedFileResult(path: storagePath, url: url, name: cleanName, type: contentType, size: snap.totalBytes);
  }

  Future<String> uploadBytes({required Uint8List bytes, required String folder, required String fileName, String contentType = 'application/octet-stream'}) async {
    final cleanName = sanitizeFileName(fileName);
    final cleanFolder = sanitizeFolderPath(folder);
    final storagePath = 'main/$cleanFolder/${const Uuid().v4()}-$cleanName';
    final ref = _storage.ref(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: contentType, customMetadata: {'originalName': cleanName}));
    return ref.getDownloadURL();
  }

  Future<Uint8List?> downloadBytes(String storagePath, {int maxSize = 10 * 1024 * 1024}) {
    return _storage.ref(storagePath).getData(maxSize);
  }

  String sanitizeFolderPath(String input) {
    final parts = input
        .replaceAll('\\', '/')
        .split('/')
        .map((part) => sanitizeFileName(part))
        .where((part) => part.isNotEmpty && part != '.')
        .toList();
    return parts.isEmpty ? 'uploads' : parts.join('/');
  }

  String sanitizeFileName(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[\\/]+'), '_')
        .replaceAll('..', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9._\- أ-ي]'), '_')
        .trim();
    return cleaned.isEmpty ? 'file' : cleaned;
  }
}
