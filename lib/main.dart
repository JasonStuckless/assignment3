import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'order_plan_screen.dart';
import 'add_food_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // HomeScreen is set as the initial route
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),  // HomeScreen is the initial screen
        '/foodList': (context) => const OrderPlanScreen(),
        '/addFood': (context) => const AddFoodScreen(),
      },
    );
  }
}
