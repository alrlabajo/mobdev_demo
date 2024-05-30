import 'package:flutter/material.dart';
import 'package:goals_app/models/category.dart';
import 'package:goals_app/models/frequency.dart';
import 'package:goals_app/models/goals.dart';
import 'package:goals_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore File
  final FirestoreService firestoreService = FirestoreService();

  // Sorting
  bool _isSortedAscending = true;

  void toggleSortOrder() {
    setState(() {
      _isSortedAscending = !_isSortedAscending;
    });
  }

  // Dialog Box
  void notesDialogBox({String? docID, Goals? existingGoal}) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: existingGoal?.name ?? '');
    final TextEditingController priceController =
        TextEditingController(text: existingGoal?.price.toString() ?? '');
    Category selectedCategory = existingGoal?.category ?? Category.personal;
    Frequency selectedFrequency = existingGoal?.frequency ?? Frequency.daily;
    DateTime selectedTargetDate = existingGoal?.targetDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: Category.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
                DropdownButtonFormField<Frequency>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: Frequency.values.map((frequency) {
                    return DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedFrequency = value!;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedTargetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null &&
                        pickedDate != selectedTargetDate) {
                      selectedTargetDate = pickedDate;
                    }
                  },
                  child: const Text('Select Target Date'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Goals newGoal = Goals(
                  id: docID,
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  category: selectedCategory,
                  frequency: selectedFrequency,
                  targetDate: selectedTargetDate,
                );

                if (docID == null) {
                  firestoreService.addGoal(newGoal);
                } else {
                  firestoreService.updateGoals(docID, newGoal);
                }

                nameController.clear();
                priceController.clear();

                Navigator.pop(context);
              }
            },
            child: const Text("Save Goal"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/welcomepage');
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: const Text(
          'Goals',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: toggleSortOrder,
            icon: const Icon(Icons.sort),
            color: Colors.white,
          ),
        ],
        backgroundColor: Colors.grey,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Goals>>(
        stream: firestoreService.getGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No goals yet',
                    style: TextStyle(color: Colors.white, fontSize: 18)));
          } else {
            List<Goals> goalsList = snapshot.data!;

            // Sort goalsList alphabetically based on the goal name
            goalsList.sort((a, b) {
              return _isSortedAscending
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name);
            });

            return ListView.separated(
              itemCount: goalsList.length,
              itemBuilder: (context, index) {
                // Get individual goal from the list
                Goals goal = goalsList[index];
                String? docID = goal.id;

                // Display
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(
                      goal.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Price: \₱${goal.price}\nTarget Date: ${goal.targetDate.toLocal().toIso8601String().substring(0, 10)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    tileColor: Colors.grey,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              notesDialogBox(docID: docID, existingGoal: goal),
                          icon: const Icon(Icons.edit),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () => firestoreService.deleteGoals(docID!),
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
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: notesDialogBox,
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
