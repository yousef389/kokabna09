import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class AppState extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _coupleSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  bool bootstrapped = false;
  User? user;
  UserProfile? profile;
  CoupleInfo? couple;
  bool coupleLoaded = false;
  bool profileLoaded = false;
  String themeName = 'pink';

  bool get signedIn => user != null;
  bool get isAdmin => user != null && couple?.adminUid == user!.uid;
  bool get isMember => user != null && (couple?.memberUids.contains(user!.uid) ?? false);

  void bootstrap() {
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((u) {
      user = u;
      bootstrapped = true;
      _listenCouple();
      _listenProfile();
      notifyListeners();
    });
  }

  void _listenCouple() {
    _coupleSub?.cancel();
    if (user == null) {
      couple = null;
      coupleLoaded = true;
      return;
    }
    coupleLoaded = false;
    _coupleSub = db.doc('couple/main').snapshots().listen((snap) {
      couple = snap.exists ? CoupleInfo.fromDoc(snap) : null;
      coupleLoaded = true;
      themeName = couple?.theme ?? 'pink';
      notifyListeners();
    }, onError: (_) {
      couple = null;
      coupleLoaded = true;
      notifyListeners();
    });
  }

  void _listenProfile() {
    _profileSub?.cancel();
    if (user == null) {
      profile = null;
      profileLoaded = true;
      return;
    }
    profileLoaded = false;
    _profileSub = db.doc('users/${user!.uid}').snapshots().listen((snap) {
      profile = snap.exists ? UserProfile.fromDoc(snap) : null;
      profileLoaded = true;
      notifyListeners();
    }, onError: (_) {
      profile = null;
      profileLoaded = true;
      notifyListeners();
    });
  }

  Future<void> setTheme(String value) async {
    themeName = value;
    notifyListeners();
    if (isMember) {
      await db.doc('couple/main').update({'theme': value, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  /// تحديث تاريخ بداية العلاقة
  Future<void> setStartDate(DateTime date) async {
    if (!isMember) return;
    await db.doc('couple/main').update({
      'startDate': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() => auth.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    _coupleSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
