import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> createAdmin({
    required String email,
    required String password,
    required String nickname,
    required String coupleName,
  }) async {
    // ① أنشئ الحساب أولاً — بعدها نقدر نقرأ Firestore بصلاحيات
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;

    // ② اتحقق إن المساحة مش موجودة بعد ما نكون logged in
    DocumentSnapshot<Map<String, dynamic>>? existing;
    try {
      existing = await _db.doc('couple/main').get();
    } catch (_) {
      existing = null;
    }

    if (existing != null && existing.exists) {
      // المساحة موجودة — احذف الحساب اللي أنشأناه وارمي exception
      try { await cred.user?.delete(); } catch (_) {}
      await _auth.signOut();
      throw Exception('المساحة موجودة بالفعل. استخدم تسجيل الدخول.');
    }

    // ③ أنشئ المساحة وملف المستخدم في batch واحد
    final batch = _db.batch();
    batch.set(_db.doc('couple/main'), {
      'coupleName': coupleName.trim().isEmpty ? 'Our Planet' : coupleName.trim(),
      'adminUid': uid,
      'partnerUid': null,
      'memberUids': [uid],
      'allowPartnerUploads': true,
      'theme': 'pink',
      'inviteCode': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.doc('users/$uid'), {
      'email': email.trim(),
      'nickname': nickname.trim().isEmpty ? 'الإدارة' : nickname.trim(),
      'role': 'admin',
      'photoUrl': null,
      'fcmTokens': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<String> createInviteCode() async {
    final code = _randomCode();
    await _db.doc('couple/main').update({
      'inviteCode': code,
      'inviteCreatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return code;
  }

  Future<void> joinAsPartner({
    required String email,
    required String password,
    required String nickname,
    required String inviteCode,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('joinPartner');
      await callable.call({
        'email': email.trim(),
        'nickname': nickname.trim().isEmpty ? 'الشريك' : nickname.trim(),
        'inviteCode': inviteCode.trim(),
      });
    } catch (e) {
      try { await cred.user?.delete(); } catch (_) {}
      await _auth.signOut();
      throw Exception(e.toString());
    }
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
