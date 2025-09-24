// lib/services/db_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentReference> addComplaint(Map<String, dynamic> data) {
    return _db.collection('complaints').add(data);
  }

  Stream<QuerySnapshot> complaintsStreamForUser(String uid) {
    return _db
        .collection('complaints')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> allComplaintsStream() {
    return _db.collection('complaints').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateComplaint(String id, Map<String, dynamic> data) {
    return _db.collection('complaints').doc(id).update(data);
  }
}
