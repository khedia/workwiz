import 'package:flutter/material.dart';

import 'package:workwiz/pages/chat_list_screen.dart';
import 'package:workwiz/widgets/user_bottom_nav_bar.dart';
import 'package:workwiz/pages/user_category_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});


  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
        gradient: RadialGradient(
        center: Alignment(-0.3, 0),
    radius: 1.5,
    colors: [
    Color(0xffC2E8E8),
    Color(0xff8FBFE0),
    ],
    ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomNavigationBarForUser(indexNum: 0),
        appBar: AppBar(
          title: const Text('User Home Screen'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white,),
            onPressed: (){},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.white,),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
              },
            ),
          ],
        ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Jamshedpur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for services',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black45,
                ),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black45,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              color: Colors.white,
              // Set the background color of the container to white
              child: GridView.count(
                crossAxisCount: 3,
                // Number of columns in the grid
                crossAxisSpacing: 10,
                // Spacing between columns
                mainAxisSpacing: 10,
                // Spacing between rows
                padding: const EdgeInsets.all(10),
                children: const [
                  // Add your category items here
                  CategoryItem(icon: Icons.home, title: 'Home Cleaning'),
                  CategoryItem(icon: Icons.auto_awesome, title: 'Car Wash'),
                  CategoryItem(icon: Icons.spa, title: 'Personal Care'),
                  CategoryItem(icon: Icons.build, title: 'Home Repairs'),
                  CategoryItem(icon: Icons.food_bank, title: 'Food Delivery'),
                  CategoryItem(icon: Icons.healing, title: 'Healthcare'),
                  CategoryItem(icon: Icons.pets, title: 'Pet Care'),
                  CategoryItem(icon: Icons.school, title: 'Tutoring'),
                  CategoryItem(icon: Icons.work, title: 'Others'),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryItem({Key? key, required this.icon, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the category page when clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserCategoryScreen(categoryName: title),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}