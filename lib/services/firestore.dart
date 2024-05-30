import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goals_app/models/goals.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of goals from Firestore
  Stream<List<Goals>> getGoalsStream() {
    return _db
        .collection('goals')
        .withConverter<Goals>(
          fromFirestore: (snapshot, _) => Goals.fromJson(snapshot.data()!),
          toFirestore: (goal, _) => goal.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Goals goal = doc.data();
              goal.id = doc.id;
              return goal;
            }).toList());
  }

  // Add a new goal to Firestore
  Future<void> addGoal(Goals goal) {
    return _db.collection('goals').add(goal.toJson());
  }

  // Update an existing goal in Firestore
  Future<void> updateGoals(String id, Goals goal) {
    return _db.collection('goals').doc(id).set(goal.toJson());
  }

  // Delete a goal from Firestore
  Future<void> deleteGoals(String id) {
    return _db.collection('goals').doc(id).delete();
  }
}
