import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'food_order.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        breakfast TEXT NOT NULL,
        lunch TEXT NOT NULL,
        dinner TEXT NOT NULL,
        target_cost REAL NOT NULL
      )
    ''');

    // Populate food items during database creation
    await populateFoodItems(db);
  }

  // Method to delete all existing food items and insert 20 new ones
  Future<void> populateFoodItems(Database db) async {
    // Clear the table
    await db.delete('food_items');

    // List of food items to insert
    List<Map<String, dynamic>> foodItems = [
      {'name': 'Pizza', 'cost': 8.50},
      {'name': 'Burger', 'cost': 6.99},
      {'name': 'Pasta', 'cost': 7.50},
      {'name': 'Salad', 'cost': 5.00},
      {'name': 'Sandwich', 'cost': 4.75},
      {'name': 'Sushi', 'cost': 9.00},
      {'name': 'Tacos', 'cost': 3.99},
      {'name': 'Burrito', 'cost': 6.00},
      {'name': 'Fries', 'cost': 2.50},
      {'name': 'Chicken Wings', 'cost': 7.25},
      {'name': 'Fish and Chips', 'cost': 8.00},
      {'name': 'Wrap', 'cost': 6.50},
      {'name': 'Hot Dog', 'cost': 3.75},
      {'name': 'Nachos', 'cost': 5.50},
      {'name': 'Pancakes', 'cost': 4.00},
      {'name': 'Waffles', 'cost': 5.25},
      {'name': 'Toast', 'cost': 2.00},
      {'name': 'Steak', 'cost': 9.00},
      {'name': 'Rice', 'cost': 1.50},
      {'name': 'Soup', 'cost': 3.25},
    ];

    // Insert the food items into the database
    for (var item in foodItems) {
      await db.insert('food_items', item);
    }
  }

  // Method to insert a food item
  Future<int> addFoodItem(String name, double cost) async {
    final db = await database;
    return await db.insert(
      'food_items',
      {'name': name, 'cost': cost},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to get all food items from the database
  Future<List<Map<String, dynamic>>> getAllFoodItems() async {
    final db = await database;
    return await db.query('food_items');
  }

  // Method to get all order plans from the database
  Future<List<Map<String, dynamic>>> getAllOrderPlans() async {
    final db = await database;
    return await db.query('order_plans');
  }

  // Method to get order plans by date
  Future<List<Map<String, dynamic>>> getOrderPlansByDate(String date) async {
    final db = await database;
    return await db.query(
      'order_plans',
      where: 'date LIKE ?',
      whereArgs: ['%$date%'],  // Using LIKE to allow partial matching
    );
  }

  // Method to insert an order plan
  Future<int> addOrderPlan(
      DateTime date, String breakfast, String lunch, String dinner, double targetCost) async {
    final db = await database;
    return await db.insert('order_plans', {
      'date': date.toIso8601String(),
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'target_cost': targetCost,
    });
  }

  // Method to update an existing order plan
  Future<int> updateOrderPlan(
      int id, String date, String breakfast, String lunch, String dinner, double targetCost) async {
    final db = await database;
    return await db.update('order_plans', {
      'date': date,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'target_cost': targetCost,
    }, where: 'id = ?', whereArgs: [id]);
  }

  // Method to delete an order plan
  Future<int> deleteOrderPlan(int id) async {
    final db = await database;
    return await db.delete('order_plans', where: 'id = ?', whereArgs: [id]);
  }
}
