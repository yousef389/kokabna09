import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? tsToDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime)  return value;
  return null;
}

// ────────────────────────────────────────────
//  ملف المستخدم
// ────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String email;
  final String nickname;
  final String role;
  final String? photoUrl;
  final List<String> fcmTokens;

  UserProfile({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.role,
    this.photoUrl,
    this.fcmTokens = const [],
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProfile(
      uid:       doc.id,
      email:     d['email']    ?? '',
      nickname:  d['nickname'] ?? 'حبيبي',
      role:      d['role']     ?? 'partner',
      photoUrl:  d['photoUrl'],
      fcmTokens: List<String>.from(d['fcmTokens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'email':     email,
    'nickname':  nickname,
    'role':      role,
    'photoUrl':  photoUrl,
    'fcmTokens': fcmTokens,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

// ────────────────────────────────────────────
//  معلومات الثنائي
// ────────────────────────────────────────────
class CoupleInfo {
  final String id;
  final String coupleName;
  final String adminUid;
  final String? partnerUid;
  final List<String> memberUids;
  final bool allowPartnerUploads;
  final String theme;
  final String? inviteCode;
  final DateTime? startDate;   // ← تاريخ بداية العلاقة

  CoupleInfo({
    required this.id,
    required this.coupleName,
    required this.adminUid,
    required this.memberUids,
    this.partnerUid,
    this.allowPartnerUploads = true,
    this.theme  = 'pink',
    this.inviteCode,
    this.startDate,
  });

  bool get isComplete => partnerUid != null && memberUids.length == 2;

  factory CoupleInfo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CoupleInfo(
      id:                   doc.id,
      coupleName:           d['coupleName']           ?? 'Our Planet',
      adminUid:             d['adminUid']             ?? '',
      partnerUid:           d['partnerUid'],
      memberUids:           List<String>.from(d['memberUids'] ?? []),
      allowPartnerUploads:  d['allowPartnerUploads']  ?? true,
      theme:                d['theme']                ?? 'pink',
      inviteCode:           d['inviteCode'],
      startDate:            tsToDate(d['startDate']),
    );
  }
}

// ────────────────────────────────────────────
//  رسالة
// ────────────────────────────────────────────
class MessageItem {
  final String id;
  final String senderId;
  final String type;
  final String text;
  final String? mediaUrl;
  final String? fileName;
  final String? replyTo;
  final bool pinned;
  final bool edited;
  final DateTime? createdAt;
  final Map<String, List<String>> reactions;
  final List<String> seenBy;

  MessageItem({
    required this.id,
    required this.senderId,
    required this.type,
    required this.text,
    this.mediaUrl,
    this.fileName,
    this.replyTo,
    this.pinned   = false,
    this.edited   = false,
    this.createdAt,
    this.reactions = const {},
    this.seenBy    = const [],
  });

  factory MessageItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d   = doc.data() ?? {};
    final raw = Map<String, dynamic>.from(d['reactions'] ?? {});
    return MessageItem(
      id:        doc.id,
      senderId:  d['senderId'] ?? '',
      type:      d['type']     ?? 'text',
      text:      d['text']     ?? '',
      mediaUrl:  d['mediaUrl'],
      fileName:  d['fileName'],
      replyTo:   d['replyTo'],
      pinned:    d['pinned']   ?? false,
      edited:    d['edited']   ?? false,
      createdAt: tsToDate(d['createdAt']),
      reactions: raw.map((k, v) => MapEntry(k, List<String>.from(v ?? []))),
      seenBy:    List<String>.from(d['seenBy'] ?? []),
    );
  }
}

// ────────────────────────────────────────────
//  ملاحظة
// ────────────────────────────────────────────
class NoteItem {
  final String  id;
  final String  title;
  final String  text;
  final String  createdBy;
  final bool    pinned;
  final String? mediaUrl;
  final DateTime? date;

  NoteItem({
    required this.id,
    required this.title,
    required this.text,
    required this.createdBy,
    this.pinned = false,
    this.mediaUrl,
    this.date,
  });

  factory NoteItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return NoteItem(
      id:        doc.id,
      title:     d['title']     ?? '',
      text:      d['text']      ?? '',
      createdBy: d['createdBy'] ?? '',
      pinned:    d['pinned']    ?? false,
      mediaUrl:  d['mediaUrl'],
      date:      tsToDate(d['date'] ?? d['createdAt']),
    );
  }
}

// ────────────────────────────────────────────
//  ألبوم
// ────────────────────────────────────────────
class AlbumItem {
  final String  id;
  final String  title;
  final String  description;
  final String? coverUrl;
  final DateTime? date;

  AlbumItem({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl,
    this.date,
  });

  factory AlbumItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AlbumItem(
      id:          doc.id,
      title:       d['title']       ?? '',
      description: d['description'] ?? '',
      coverUrl:    d['coverUrl'],
      date:        tsToDate(d['date'] ?? d['createdAt']),
    );
  }
}

// ────────────────────────────────────────────
//  ملف خاص
// ────────────────────────────────────────────
class PrivateFileItem {
  final String  id;
  final String  name;
  final String  type;
  final String  folder;
  final String  storagePath;
  final String? downloadUrl;
  final int     size;
  final DateTime? createdAt;

  PrivateFileItem({
    required this.id,
    required this.name,
    required this.type,
    required this.folder,
    required this.storagePath,
    this.downloadUrl,
    this.size = 0,
    this.createdAt,
  });

  factory PrivateFileItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PrivateFileItem(
      id:          doc.id,
      name:        d['name']        ?? '',
      type:        d['type']        ?? 'file',
      folder:      d['folder']      ?? '/',
      storagePath: d['storagePath'] ?? '',
      downloadUrl: d['downloadUrl'],
      size:        d['size']        ?? 0,
      createdAt:   tsToDate(d['createdAt']),
    );
  }
}

// ────────────────────────────────────────────
//  صفحة خاصة
// ────────────────────────────────────────────
class PageProject {
  final String  id;
  final String  title;
  final String  description;
  final String  createdBy;
  final DateTime? createdAt;

  PageProject({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.createdAt,
  });

  factory PageProject.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PageProject(
      id:          doc.id,
      title:       d['title']       ?? '',
      description: d['description'] ?? '',
      createdBy:   d['createdBy']   ?? '',
      createdAt:   tsToDate(d['createdAt']),
    );
  }
}
