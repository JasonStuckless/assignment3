import 'package:flutter/material.dart';
import 'db_helper.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  // Controllers for the new order plan
  TextEditingController _targetCostController = TextEditingController();
  DateTime? _selectedDate;

  // Selected food items
  String? _selectedBreakfast;
  String? _selectedLunch;
  String? _selectedDinner;

  // List of food items retrieved from the database
  List<Map<String, dynamic>> _foodItems = [];

  // Method to fetch food items from the database
  Future<void> _fetchFoodItems() async {
    DBHelper dbHelper = DBHelper();
    var foodItems = await dbHelper.getAllFoodItems();
    setState(() {
      _foodItems = foodItems;
    });
  }

  // Method to calculate total cost of selected items
  double _calculateTotalCost() {
    double totalCost = 0.0;
    if (_selectedBreakfast != null) {
      totalCost += double.tryParse(
          _foodItems.firstWhere((item) => item['name'] == _selectedBreakfast)['cost'].toString()) ??
          0.0;
    }
    if (_selectedLunch != null) {
      totalCost += double.tryParse(
          _foodItems.firstWhere((item) => item['name'] == _selectedLunch)['cost'].toString()) ??
          0.0;
    }
    if (_selectedDinner != null) {
      totalCost += double.tryParse(
          _foodItems.firstWhere((item) => item['name'] == _selectedDinner)['cost'].toString()) ??
          0.0;
    }
    return totalCost;
  }

  // Method to create the order plan and navigate back to Home
  Future<void> _createOrderPlan() async {
    final String date = _selectedDate?.toIso8601String() ?? '';
    final double totalCost = _calculateTotalCost();
    final double targetCost = double.tryParse(_targetCostController.text) ?? 0.0;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (_selectedBreakfast == null || _selectedLunch == null || _selectedDinner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select food items for all meals')),
      );
      return;
    }

    if (targetCost <= totalCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target cost must be greater than the total cost of selected items')),
      );
      return;
    }

    // Save the order plan to the database
    DBHelper dbHelper = DBHelper();
    await dbHelper.addOrderPlan(
      _selectedDate!,
      _selectedBreakfast!,
      _selectedLunch!,
      _selectedDinner!,
      targetCost,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan created successfully')),
    );

    // Go back to the home screen and refresh the order plan list
    Navigator.pop(context, true); // Passing true to signal that data should be refreshed
  }

  @override
  void initState() {
    super.initState();
    _fetchFoodItems(); // Fetch the food items when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date Picker for selecting the date
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
            ),
            const SizedBox(height: 16),

            // Dropdowns for selecting food items for Breakfast, Lunch, and Dinner
            DropdownButton<String>(
              value: _selectedBreakfast,
              hint: const Text('Select Breakfast'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBreakfast = newValue;
                });
              },
              items: _foodItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text('${item['name']} - \$${item['cost']}'), // Name and Cost
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedLunch,
              hint: const Text('Select Lunch'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLunch = newValue;
                });
              },
              items: _foodItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text('${item['name']} - \$${item['cost']}'), // Name and Cost
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedDinner,
              hint: const Text('Select Dinner'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDinner = newValue;
                });
              },
              items: _foodItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text('${item['name']} - \$${item['cost']}'), // Name and Cost
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Text field for target cost
            TextField(
              controller: _targetCostController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Create Order Plan Button
            ElevatedButton(
              onPressed: _createOrderPlan,
              child: const Text('Create Order Plan'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xff91ff9e)),
            ),
          ],
        ),
      ),
    );
  }
}
