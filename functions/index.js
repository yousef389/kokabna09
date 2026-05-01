const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();

async function sendToOtherUser(senderId, title, body, data = {}) {
  const coupleSnap = await db.doc('couple/main').get();
  if (!coupleSnap.exists) return;
  const memberUids = coupleSnap.data().memberUids || [];
  const recipients = memberUids.filter((uid) => uid !== senderId);
  if (!recipients.length) return;

  const userSnaps = await Promise.all(recipients.map((uid) => db.doc(`users/${uid}`).get()));
  const tokens = [];
  for (const snap of userSnaps) {
    const userTokens = snap.exists ? (snap.data().fcmTokens || []) : [];
    tokens.push(...userTokens.filter(Boolean));
  }
  if (!tokens.length) return;

  await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
    android: {
      priority: 'high',
      notification: { channelId: 'kokabna_channel', defaultSound: true }
    }
  });
}


exports.joinPartner = onCall(async (request) => {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError('unauthenticated', 'سجّل الدخول أولًا.');
  }
  const uid = request.auth.uid;
  const inviteCode = String(request.data.inviteCode || '').trim();
  const email = String(request.data.email || request.auth.token.email || '').trim();
  const nickname = String(request.data.nickname || 'الشريك').trim();

  if (!inviteCode) throw new HttpsError('invalid-argument', 'كود الدعوة مطلوب.');

  const coupleRef = db.doc('couple/main');
  await db.runTransaction(async (tx) => {
    const coupleSnap = await tx.get(coupleRef);
    if (!coupleSnap.exists) throw new HttpsError('failed-precondition', 'الأدمن لم ينشئ المساحة الخاصة بعد.');
    const couple = coupleSnap.data();
    if (couple.partnerUid) throw new HttpsError('already-exists', 'حساب الشريك موجود بالفعل.');
    if (String(couple.inviteCode || '').trim() !== inviteCode) throw new HttpsError('permission-denied', 'كود الدعوة غير صحيح.');

    const memberUids = Array.from(new Set([...(couple.memberUids || []), uid]));
    if (memberUids.length > 2) throw new HttpsError('failed-precondition', 'هذا التطبيق يدعم حسابين فقط.');

    tx.update(coupleRef, {
      partnerUid: uid,
      memberUids,
      inviteCode: null,
      updatedAt: new Date(),
    });

    tx.set(db.doc(`users/${uid}`), {
      email,
      nickname: nickname || 'الشريك',
      role: 'partner',
      photoUrl: null,
      fcmTokens: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    }, { merge: true });
  });

  return { ok: true };
});

exports.onMessageCreated = onDocumentCreated('chats/{chatId}/messages/{messageId}', async (event) => {
  const msg = event.data.data();
  const body = msg.type === 'text' ? (msg.text || 'رسالة جديدة') : `ملف جديد`;
  await sendToOtherUser(msg.senderId, 'كوكبنا', body, { type: 'message', chatId: event.params.chatId });
});

exports.onNoteCreated = onDocumentCreated('notes/{noteId}', async (event) => {
  const note = event.data.data();
  await sendToOtherUser(note.createdBy, 'ملاحظة جديدة', note.title || 'تمت إضافة ملاحظة خاصة', { type: 'note', noteId: event.params.noteId });
});

exports.onStoryCreated = onDocumentCreated('stories/{storyId}', async (event) => {
  const story = event.data.data();
  await sendToOtherUser(story.createdBy, 'قصة جديدة', story.caption || 'تمت إضافة قصة خاصة', { type: 'story', storyId: event.params.storyId });
});

exports.onAlbumItemCreated = onDocumentCreated('album_items/{itemId}', async (event) => {
  const item = event.data.data();
  await sendToOtherUser(item.createdBy, 'ذكرى ألبوم جديدة', item.caption || 'تمت إضافة عنصر جديد للألبوم', { type: 'album', albumId: item.albumId });
});

exports.onPageCreated = onDocumentCreated('pages/{pageId}', async (event) => {
  const page = event.data.data();
  await sendToOtherUser(page.createdBy, 'صفحة خاصة جديدة', page.title || 'تم رفع صفحة خاصة', { type: 'page', pageId: event.params.pageId });
});

exports.onCallCreated = onDocumentCreated('calls/{callId}', async (event) => {
  const call = event.data.data();
  await sendToOtherUser(call.createdBy, call.kind === 'video' ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة', 'اضغط لفتح كوكبنا', { type: 'call', callId: event.params.callId });
});
