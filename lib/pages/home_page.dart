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
  void notesDialogBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                //Text Input
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        firestoreService.addGoal(textController.text);
                      } else {
                        firestoreService.updateGoals(
                            docID, textController.text);
                      }

                      textController.clear(); // Clear text field after saving

                      Navigator.pop(context); // Close dialog box
                    },
                    child: const Text("Add Goal"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goals',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        
        actions: <Widget>[
          IconButton(
            onPressed: notesDialogBox, 
            icon: const Icon(Icons.add),
            color: Colors.white,
          )
        ],
        backgroundColor: Colors.orangeAccent,
        shape:  const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25)
          )
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getGoalsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List goalsList = snapshot.data!.docs;

              return ListView.separated(
                itemCount: goalsList.length,
                itemBuilder: (context, index) {
                  //Get individual goal from database
                  DocumentSnapshot document = goalsList[index];
                  String docID = document.id;

                  //Get goal each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String goalText = data['goal'];

                  // Display
                  return Padding ( 
                    padding: const EdgeInsets.all(8.0), // Add padding here
                    child: ListTile(
                      title: Text(
                        goalText,
                        style: TextStyle(color: Colors.white)
                      ),
                      tileColor: Colors.deepPurpleAccent,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => notesDialogBox(docID: docID),
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                          ),
                          IconButton(
                            onPressed: () => firestoreService.deleteGoals(docID),
                            icon: const Icon(Icons.delete),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              );
            }
            else {
              return const Text('No goals yet...');
            }
          }
        ),
    );
  }
}
