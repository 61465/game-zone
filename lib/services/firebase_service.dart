import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

// ══════════════════════════════════════════
//  FIREBASE SERVICE
// ══════════════════════════════════════════
class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // ── Current user ──
  static User? get currentUser => _auth.currentUser;
  static String get uid => _auth.currentUser?.uid ?? '';

  // ══════════════════════════════════════════
  //  AUTH
  // ══════════════════════════════════════════

  // تسجيل حساب جديد
  static Future<UserCredential?> register(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      // إنشاء بروفايل في Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email.trim(),
        'initial': name.isNotEmpty ? name[0] : '?',
        'createdAt': FieldValue.serverTimestamp(),
        'partnerId': '',
        'mood': {'emoji': '😊', 'label': 'سعيد', 'message': ''},
      });
      return cred;
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }

  // تسجيل دخول
  static Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  // تسجيل خروج
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ══════════════════════════════════════════
  //  PARTNER LINKING
  // ══════════════════════════════════════════

  // ربط الشريك عبر الإيميل
  static Future<bool> linkPartner(String partnerEmail) async {
    try {
      final query = await _db.collection('users')
          .where('email', isEqualTo: partnerEmail.trim())
          .get();
      if (query.docs.isEmpty) return false;
      final partnerId = query.docs.first.id;
      // ربط الطرفين
      await _db.collection('users').doc(uid).update({'partnerId': partnerId});
      await _db.collection('users').doc(partnerId).update({'partnerId': uid});
      return true;
    } catch (e) {
      debugPrint('Link partner error: $e');
      return false;
    }
  }

  // جلب بيانات الشريك
  static Stream<DocumentSnapshot> partnerStream(String partnerId) {
    return _db.collection('users').doc(partnerId).snapshots();
  }

  // جلب بيانات المستخدم الحالي
  static Stream<DocumentSnapshot> myProfileStream() {
    return _db.collection('users').doc(uid).snapshots();
  }

  // ══════════════════════════════════════════
  //  MESSAGES
  // ══════════════════════════════════════════

  static String _chatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  // إرسال رسالة
  static Future<void> sendMessage({
    required String partnerId,
    required String content,
    required String type,
    String? letterTitle,
    DateTime? openAt,
  }) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'content': content,
      'senderId': uid,
      'type': type,
      'reactions': [],
      'sentAt': FieldValue.serverTimestamp(),
      'letterTitle': letterTitle,
      'openAt': openAt != null ? Timestamp.fromDate(openAt) : null,
      'isOpened': false,
    });
    // تحديث آخر رسالة
    await _db.collection('chats').doc(chatId).set({
      'lastMessage': content,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'participants': [uid, partnerId],
    }, SetOptions(merge: true));
  }

  // جلب الرسائل
  static Stream<QuerySnapshot> messagesStream(String partnerId) {
    final chatId = _chatId(uid, partnerId);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  // حذف رسالة
  static Future<void> deleteMessage(String partnerId, String messageId) async {
    final chatId = _chatId(uid, partnerId);
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // إضافة ردود فعل
  static Future<void> addReaction(String partnerId, String messageId, String emoji) async {
    final chatId = _chatId(uid, partnerId);
    final ref = _db.collection('chats').doc(chatId).collection('messages').doc(messageId);
    final doc = await ref.get();
    final reactions = List<String>.from(doc['reactions'] ?? []);
    if (reactions.contains(emoji)) reactions.remove(emoji);
    else reactions.add(emoji);
    await ref.update({'reactions': reactions});
  }

  // فتح رسالة مؤجلة
  static Future<void> openLetter(String partnerId, String messageId) async {
    final chatId = _chatId(uid, partnerId);
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isOpened': true});
  }

  // ══════════════════════════════════════════
  //  MOOD
  // ══════════════════════════════════════════

  static Future<void> updateMood(String emoji, String label, String message) async {
    await _db.collection('users').doc(uid).update({
      'mood': {
        'emoji': emoji,
        'label': label,
        'message': message,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    });
  }

  // ══════════════════════════════════════════
  //  IDEAS
  // ══════════════════════════════════════════

  static Future<void> addIdea(String partnerId, String title, String desc, String category) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('shared').doc(chatId).collection('ideas').add({
      'title': title,
      'description': desc,
      'category': category,
      'addedBy': uid,
      'likes': 0,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> ideasStream(String partnerId) {
    final chatId = _chatId(uid, partnerId);
    return _db
        .collection('shared')
        .doc(chatId)
        .collection('ideas')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> toggleIdeaLike(String partnerId, String ideaId, bool currentlyLiked) async {
    final chatId = _chatId(uid, partnerId);
    final ref = _db.collection('shared').doc(chatId).collection('ideas').doc(ideaId);
    if (currentlyLiked) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  static Future<void> deleteIdea(String partnerId, String ideaId) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('shared').doc(chatId).collection('ideas').doc(ideaId).delete();
  }

  // ══════════════════════════════════════════
  //  TODOS
  // ══════════════════════════════════════════

  static Future<void> addTodo(String partnerId, String title) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('shared').doc(chatId).collection('todos').add({
      'title': title,
      'isDone': false,
      'assignedTo': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> todosStream(String partnerId) {
    final chatId = _chatId(uid, partnerId);
    return _db
        .collection('shared')
        .doc(chatId)
        .collection('todos')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static Future<void> toggleTodo(String partnerId, String todoId, bool isDone) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('shared').doc(chatId).collection('todos').doc(todoId).update({
      'isDone': !isDone,
    });
  }

  static Future<void> deleteTodo(String partnerId, String todoId) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('shared').doc(chatId).collection('todos').doc(todoId).delete();
  }

  // ══════════════════════════════════════════
  //  FIGHT MODE
  // ══════════════════════════════════════════

  static Future<void> setFightMode(String partnerId, bool active, String who) async {
    final chatId = _chatId(uid, partnerId);
    await _db.collection('shared').doc(chatId).set({
      'fightMode': active,
      'fightWho': who,
      'fightUpdatedBy': uid,
      'fightAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<DocumentSnapshot> sharedStateStream(String partnerId) {
    final chatId = _chatId(uid, partnerId);
    return _db.collection('shared').doc(chatId).snapshots();
  }

  // ══════════════════════════════════════════
  //  PROFILE UPDATE
  // ══════════════════════════════════════════

  static Future<void> updateProfile(String name) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'initial': name.isNotEmpty ? name[0] : '?',
    });
    await _auth.currentUser?.updateDisplayName(name);
  }
}
