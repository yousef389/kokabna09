import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallService {
  CallService._();
  static final instance = CallService._();

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> calls() {
    return db.collection('calls').orderBy('createdAt', descending: true).limit(50).snapshots();
  }

  Future<String> startCall(String kind) async {
    final doc = await db.collection('calls').add({
      'kind': kind,
      'status': 'ringing',
      'createdBy': auth.currentUser!.uid,
      'participants': [auth.currentUser!.uid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'webrtc': {
        'offer': null,
        'answer': null,
        'iceCandidates': [],
        'notes': 'جهّز هنا ربط WebRTC مع خادم STUN/TURN عند تفعيل المكالمات الحقيقية.',
      },
    });
    return doc.id;
  }

  Future<void> updateStatus(String callId, String status) async {
    await db.collection('calls').doc(callId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      if (status == 'ended' || status == 'missed') 'endedAt': FieldValue.serverTimestamp(),
    });
  }
}
