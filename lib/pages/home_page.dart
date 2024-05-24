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

  //Sorting
  bool _isSortedAscending = true;

  void toggleSortOrder() {
    setState(() {
      _isSortedAscending = !_isSortedAscending;
    });
  }

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
                        firestoreService
                            .addGoal(textController.text); //from firestore file
                      } else {
                        firestoreService.updateGoals(
                            // from firestore file
                            docID,
                            textController.text);
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
        leading: IconButton(
          onPressed: toggleSortOrder,
          icon: const Icon(Icons.sort),
          color: Colors.white,
        ),
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
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

            // Sort goalsList alphabetically based on the goal text
            goalsList.sort((a, b) {
              var aData = a.data() as Map<String, dynamic>;
              var bData = b.data() as Map<String, dynamic>;

              return _isSortedAscending
                  ? aData['goal'].compareTo(bData['goal'])
                  : bData['goal'].compareTo(aData['goal']);
            });

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
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    title:
                        Text(goalText, style: TextStyle(color: Colors.white)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                    tileColor: Colors.lightBlueAccent,
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
              // Separator for list
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
            );
          } else {
            return ListView(children: const [
              ListTile(
                title: Text('No goals yet...'),
              ),
            ]);
          }
        },
      ),
    );
  }
}
