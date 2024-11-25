import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditOrderPlanScreen extends StatefulWidget {
  final int orderId;
  final String initialDate;
  final String initialBreakfast;
  final String initialLunch;
  final String initialDinner;
  final double initialTargetCost;

  const EditOrderPlanScreen({
    Key? key,
    required this.orderId,
    required this.initialDate,
    required this.initialBreakfast,
    required this.initialLunch,
    required this.initialDinner,
    required this.initialTargetCost,
  }) : super(key: key);

  @override
  _EditOrderPlanScreenState createState() => _EditOrderPlanScreenState();
}

class _EditOrderPlanScreenState extends State<EditOrderPlanScreen> {
  late TextEditingController _dateController;
  late TextEditingController _targetCostController;
  late String _breakfast;
  late String _lunch;
  late String _dinner;

  List<Map<String, dynamic>> foodItems = []; // List to hold food items fetched from the database
  DateTime? _selectedDate; // To store the selected date

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.initialDate);
    _targetCostController = TextEditingController(text: widget.initialTargetCost.toString());

    // Fetch food items from the database
    _fetchFoodItems();

    // Initialize the selected date
    _selectedDate = DateTime.tryParse(widget.initialDate);
  }

  // Fetch food items from the database
  Future<void> _fetchFoodItems() async {
    DBHelper dbHelper = DBHelper();
    List<Map<String, dynamic>> foodItemData = await dbHelper.getAllFoodItems();

    // Map the fetched data to a list of food items including name and cost
    setState(() {
      foodItems = foodItemData;

      // Ensure the initial values exist in the foodItems list
      _breakfast = foodItems.any((item) => item['name'] == widget.initialBreakfast)
          ? widget.initialBreakfast
          : foodItems.first['name'];
      _lunch = foodItems.any((item) => item['name'] == widget.initialLunch)
          ? widget.initialLunch
          : foodItems.first['name'];
      _dinner = foodItems.any((item) => item['name'] == widget.initialDinner)
          ? widget.initialDinner
          : foodItems.first['name'];
    });
  }

  // Update the order plan in the database
  Future<void> _updateOrderPlan() async {
    final String date = _selectedDate?.toIso8601String() ?? '';
    final double targetCost = double.tryParse(_targetCostController.text) ?? 0.0;

    if (date.isEmpty || targetCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid inputs')),
      );
      return;
    }

    // Save changes to the database
    DBHelper dbHelper = DBHelper();
    await dbHelper.updateOrderPlan(
      widget.orderId,
      date,
      _breakfast,
      _lunch,
      _dinner,
      targetCost,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan updated successfully')),
    );

    // Go back to the home screen
    Navigator.pop(context);
  }

  // Delete the order plan from the database
  Future<void> _deleteOrderPlan() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.deleteOrderPlan(widget.orderId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan deleted')),
    );

    // Go back to the home screen
    Navigator.pop(context);
  }

  // Method to open the date picker
  Future<void> _pickDate() async {
    DateTime initialDate = _selectedDate ?? DateTime.now(); // Default to today if no date is selected

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Update the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to pick the date
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
            ),
            const SizedBox(height: 16),

            // Dropdown for Breakfast
            DropdownButton<String>(
              value: _breakfast,
              onChanged: (String? newValue) {
                setState(() {
                  _breakfast = newValue!;
                });
              },
              items: foodItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text('${item['name']} - \$${item['cost']}'), // Show name and cost
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Dropdown for Lunch
            DropdownButton<String>(
              value: _lunch,
              onChanged: (String? newValue) {
                setState(() {
                  _lunch = newValue!;
                });
              },
              items: foodItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text('${item['name']} - \$${item['cost']}'), // Show name and cost
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Dropdown for Dinner
            DropdownButton<String>(
              value: _dinner,
              onChanged: (String? newValue) {
                setState(() {
                  _dinner = newValue!;
                });
              },
              items: foodItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['name'],
                  child: Text('${item['name']} - \$${item['cost']}'), // Show name and cost
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Target cost input
            TextField(
              controller: _targetCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Save changes button
            ElevatedButton(
              onPressed: _updateOrderPlan,
              child: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xff91ff9e)),
            ),
            const SizedBox(height: 16),

            // Delete order plan button
            ElevatedButton(
              onPressed: _deleteOrderPlan,
              child: const Text('Delete Order Plan'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xffff9991)),
            ),
          ],
        ),
      ),
    );
  }
}
