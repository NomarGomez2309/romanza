import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../features/couple/data/couple_model.dart';

class CoupleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<CoupleModel?> createCouple() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final code = generateCode();
    final docRef = _db.collection('couples').doc();

    final couple = CoupleModel(
      id: docRef.id,
      user1Id: user.uid,
      user2Id: "",
      startDate: DateTime.now(),
      inviteCode: code,
    );

    await docRef.set(couple.toMap());

    return couple;
  }

  Future<bool> joinCouple(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final query = await _db
        .collection('couples')
        .where('inviteCode', isEqualTo: code)
        .get();

    if (query.docs.isEmpty) return false;

    final doc = query.docs.first;

    await doc.reference.update({
      'user2Id': user.uid,
    });

    return true;
  }

  Future<Map<String, dynamic>?> getMyCouple(String uid) async {
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