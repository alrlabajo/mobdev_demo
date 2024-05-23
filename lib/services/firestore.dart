import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //Get List of Goals
  final CollectionReference goals = FirebaseFirestore.instance.collection("goals");

  //Create: Add new goal to database
  Future<void> addGoal(String goal) {
    return goals.add({
      'goal': goal,
      'timestamp': Timestamp.now(),
    });
  }

  //Read: Get goal/s in database
  Stream<QuerySnapshot> getGoalsStream() {
    return goals.orderBy('timestamp', descending: true).snapshots();
  }

  //Update: Update goals written
  Future<void> updateGoals(String docID, String newGoals) {
    return goals.doc(docID).update({
      'goal': newGoals,
      'timestamp': Timestamp.now(),
    });
  }

  //Delete: Delete goals
  Future<void> deleteGoals(String docID) {
    return goals.doc(docID).delete();
  }
}
