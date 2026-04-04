import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // ================= USER =================
  Future<void> createUser(Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data);
  }

  Future<DocumentSnapshot> getUser() async {
    return await _db.collection('users').doc(userId).get();
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // ================= DAILY NUMBERS =================
  Stream<DocumentSnapshot> getTodayLuckyNumbers() {
    final today = DateTime.now().toIso8601String().split("T")[0];
    final docId = "${userId}_$today";

    return _db.collection('dailyLuckyNumbers').doc(docId).snapshots();
  }

  // ================= LOTTERY HISTORY =================
  Future<void> addLotteryEntry(Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('lotteryHistory')
        .add(data);
  }

  Stream<QuerySnapshot> getLotteryHistory() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('lotteryHistory')
        .orderBy('drawDate', descending: true)
        .limit(20)
        .snapshots();
  }

  // ================= PATTERN ANALYSIS =================
  Stream<QuerySnapshot> getPatternAnalysis() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('patternAnalysis')
        .orderBy('analysisDate', descending: true)
        .snapshots();
  }
}