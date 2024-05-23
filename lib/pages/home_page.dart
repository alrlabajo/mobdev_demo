import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goals_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Firestore File
  final FirestoreService firestoreService = FirestoreService();

  //Text Controller
  final TextEditingController textController = TextEditingController();

  //Dialog Box
  void notesDialogBox ({String? docID}){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        content: TextField( //Text Input
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if(docID == null) {
                firestoreService.addGoal(textController.text);
              }

              else {
                firestoreService.updateGoals(docID, textController.text);
              }

              textController.clear(); // Clear text field after saving

              Navigator.pop(context); // Close dialog box
            }, 
            child: const Text("Add Goal")
            )
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: notesDialogBox,
        child: const Icon(Icons.add)
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getGoalsStream(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              List goalsList = snapshot.data!.docs;

              return ListView.builder (
                itemCount: goalsList.length,
                itemBuilder: (context, index) {
                  //Get individual goal from database
                  DocumentSnapshot document = goalsList[index];
                  String docID = document.id;

                  //Get goal each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String goalText = data['goal'];

                  //Display
                  return ListTile (
                    title: Text(goalText),
                    trailing: Row (
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: ()=> notesDialogBox(docID: docID ),
                          icon: const Icon(Icons.keyboard_control_key_rounded),
                        ),
                        
                        IconButton(
                          onPressed: ()=> firestoreService.deleteGoals(docID),
                          icon: const Icon(Icons.delete),
                        )
                      ],
                    )
                  );
                },
              );
            }
            else {
              return const Text("You haven't set your goals");
            }
          }
        ),
    );
  }
}