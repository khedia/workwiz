import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
        appBar: AppBar(
          title: const Text(
            'WorkWiz',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
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
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'New York',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                  mainAxisSpacing: 20,
                  // Spacing between rows
                  padding: const EdgeInsets.all(10),
                  children: const [
                    // Add your category items here
                    CategoryItem(icon: Icons.home, title: 'Home Cleaning'),
                    CategoryItem(icon: Icons.auto_awesome, title: 'Car Wash'),
                    CategoryItem(icon: Icons.spa, title: 'Personal Care Services'),
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
            builder: (context) => CategoryPage(categoryName: title),
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

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Center(
        child: Text('This is the $categoryName category page'),
      ),
    );
  }
}
