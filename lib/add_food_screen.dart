import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // Controllers for text fields
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  // A method to add food item to the database
  Future<void> _addFoodItem() async {
    final String name = _foodNameController.text;
    final double? cost = double.tryParse(_costController.text);

    if (name.isEmpty || cost == null) {
      // Show an error message if input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid food name and cost')),
      );
      return;
    }

    // Use DBHelper to insert food item into the database
    DBHelper dbHelper = DBHelper();
    await dbHelper.addFoodItem(name, cost);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food item added successfully!')),
    );

    // Clear the text fields
    _foodNameController.clear();
    _costController.clear();

    // Navigate back to the home screen after adding food item
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text Field for food name
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Text Field for food cost
            TextField(
              controller: _costController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Add Food button
            ElevatedButton(
              onPressed: _addFoodItem,
              child: const Text('Add Food Item'),
            ),
            const SizedBox(height: 16),

            // Back button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);  // Go back to Home screen
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
