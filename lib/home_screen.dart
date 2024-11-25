import 'package:flutter/material.dart';
import 'add_food_screen.dart';
import 'order_plan_screen.dart';
import 'db_helper.dart';
import 'edit_order_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to hold all order plans from the database
  List<Map<String, dynamic>> _orderPlans = [];
  DateTime? _selectedDate;  // To store the selected date

  @override
  void initState() {
    super.initState();
    _initializeDatabase();  // Ensure the food items are populated
    _fetchOrderPlans();  // Fetch all order plans when the screen loads
  }

  // Initialize the database and populate food items
  Future<void> _initializeDatabase() async {
    DBHelper dbHelper = DBHelper();

    // Call the populateFoodItems method to populate the food items table
    await dbHelper.populateFoodItems(await dbHelper.database);
  }

  // Method to fetch all order plans from the database
  Future<void> _fetchOrderPlans() async {
    DBHelper dbHelper = DBHelper();
    var orderPlans = await dbHelper.getAllOrderPlans();
    setState(() {
      _orderPlans = orderPlans;
    });
  }

  // Method to search order plans by date
  Future<void> _searchOrderPlansByDate(DateTime selectedDate) async {
    final String date = "${selectedDate.toLocal()}".split(' ')[0];  // Format to YYYY-MM-DD

    DBHelper dbHelper = DBHelper();
    var filteredPlans = await dbHelper.getOrderPlansByDate(date);
    setState(() {
      _orderPlans = filteredPlans;  // Update the order plans list with the filtered results
    });
  }

  // Method to open the date picker
  Future<void> _pickDate() async {
    DateTime initialDate = _selectedDate ?? DateTime.now();  // Default to today if no date is selected

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;  // Update the selected date
      });

      // Call the search method when a date is selected
      _searchOrderPlansByDate(pickedDate);
    }
  }

  // Method to reset the search and show all order plans
  void _resetSearch() {
    setState(() {
      _selectedDate = null;  // Clear the selected date
    });
    _fetchOrderPlans();  // Fetch all order plans from the database again
  }

  // Method to navigate to the EditOrderPlanScreen
  void _navigateToEditOrderPlanScreen(BuildContext context, Map<String, dynamic> orderPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderPlanScreen(
          orderId: orderPlan['id'],
          initialDate: orderPlan['date'],
          initialBreakfast: orderPlan['breakfast'],
          initialLunch: orderPlan['lunch'],
          initialDinner: orderPlan['dinner'],
          initialTargetCost: orderPlan['target_cost'],
        ),
      ),
    ).then((_) {
      // Refresh the order plans after editing
      _fetchOrderPlans();
    });
  }

  // Method to navigate to the AddFoodScreen
  void _navigateToAddFoodScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
    );
  }

  // Method to navigate to the Create Order Plan screen
  void _navigateToCreateOrderPlanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderPlanScreen()),
    ).then((_) {
      // After returning from creating a new order plan, refresh the list
      _fetchOrderPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row to display Select Date and Reset Search buttons side by side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Button to open the date picker
                ElevatedButton(
                  onPressed: _pickDate,
                  child: Text(_selectedDate == null
                      ? 'Select Date to Search'
                      : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                ),

                // Button to reset search and show all order plans
                ElevatedButton(
                  onPressed: _resetSearch,
                  child: const Text('Reset Search'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xffd6d6d6)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrollable list of order plans
            Expanded(
              child: ListView.builder(
                itemCount: _orderPlans.length,
                itemBuilder: (context, index) {
                  final orderPlan = _orderPlans[index];
                  final date = DateTime.parse(orderPlan['date']);
                  final dateString = "${date.toLocal()}".split(' ')[0];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Order Plan: $dateString'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Breakfast: ${orderPlan['breakfast']}'),
                          Text('Lunch: ${orderPlan['lunch']}'),
                          Text('Dinner: ${orderPlan['dinner']}'),
                          Text('Target Cost: ${orderPlan['target_cost']}'),
                        ],
                      ),
                      onTap: () => _navigateToEditOrderPlanScreen(context, orderPlan),  // Navigate to edit page
                    ),
                  );
                },
              ),
            ),

            // Row to display the Add Food Item and Create Order Plan buttons side by side at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // Spread the buttons evenly
                children: [
                  // Button to navigate to the Add Food Item screen
                  ElevatedButton(
                    onPressed: () => _navigateToAddFoodScreen(context),
                    child: const Text('Add Food Item'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xffabbeff)),
                  ),
                  // Button to navigate to the Create Order Plan screen
                  ElevatedButton(
                    onPressed: () => _navigateToCreateOrderPlanScreen(context),
                    child: const Text('Create Order Plan'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xff91ff9e)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
