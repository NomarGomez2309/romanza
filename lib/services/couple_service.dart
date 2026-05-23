import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../features/couple/data/couple_model.dart';

class CoupleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(
      6,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Future<CoupleModel?> createCouple() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final code = generateCode();
    final docRef = _db.collection('couples').doc();
    final userRef = _db.collection('users').doc(user.uid);

    final couple = CoupleModel(
      id: docRef.id,
      user1Id: user.uid,
      user2Id: "",
      startDate: DateTime.now(),
      inviteCode: code,
    );

    final created = await _db.runTransaction<bool>((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCoupleId = userSnapshot.data()?['coupleId'];

      if (currentCoupleId is String && currentCoupleId.isNotEmpty) {
        return false;
      }

      transaction.set(docRef, {...couple.toMap(), 'partnerId': null});
      transaction.set(userRef, {
        'uid': user.uid,
        'name': user.displayName ?? user.email?.split('@').first ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'partnerId': null,
        'coupleId': docRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });

    if (!created) return null;

    return couple;
  }

  Future<bool> joinCouple(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final query = await _db
        .collection('couples')
        .where('inviteCode', isEqualTo: code)
        .where('status', isEqualTo: 'pending')
        .get();

    if (query.docs.isEmpty) return false;

    final coupleRef = query.docs.first.reference;
    final userRef = _db.collection('users').doc(user.uid);

    return _db.runTransaction<bool>((transaction) async {
      final coupleSnapshot = await transaction.get(coupleRef);
      final userSnapshot = await transaction.get(userRef);

      if (!coupleSnapshot.exists) return false;

      final couple = coupleSnapshot.data() ?? <String, dynamic>{};
      final members = List<String>.from(couple['members'] as List? ?? []);
      final ownerId = couple['user1Id'] as String? ?? '';
      final userCoupleId = userSnapshot.data()?['coupleId'];

      if (ownerId.isEmpty || ownerId == user.uid) return false;
      if (members.length >= 2) return false;
      if (userCoupleId is String && userCoupleId.isNotEmpty) return false;

      final ownerRef = _db.collection('users').doc(ownerId);
      final ownerSnapshot = await transaction.get(ownerRef);
      final ownerCoupleId = ownerSnapshot.data()?['coupleId'];

      if (ownerCoupleId is String &&
          ownerCoupleId.isNotEmpty &&
          ownerCoupleId != coupleRef.id) {
        return false;
      }

      transaction.update(coupleRef, {
        'user2Id': user.uid,
        'members': [ownerId, user.uid],
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(ownerRef, {
        'partnerId': user.uid,
        'coupleId': coupleRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(userRef, {
        'uid': user.uid,
        'name': user.displayName ?? user.email?.split('@').first ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'partnerId': ownerId,
        'coupleId': coupleRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });
  }

  Future<Map<String, dynamic>?> getMyCouple(String uid) async {
    final userSnapshot = await _db.collection('users').doc(uid).get();
    final coupleId = userSnapshot.data()?['coupleId'];

    if (coupleId is String && coupleId.isNotEmpty) {
      final coupleSnapshot = await _db
          .collection('couples')
          .doc(coupleId)
          .get();
      return coupleSnapshot.data();
    }

    final query = await _db
        .collection('couples')
        .where('user1Id', isEqualTo: uid)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }

    final query2 = await _db
        .collection('couples')
        .where('user2Id', isEqualTo: uid)
        .get();

    if (query2.docs.isNotEmpty) {
      return query2.docs.first.data();
    }

    return null;
  }
}
