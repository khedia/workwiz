import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:workwiz/pages/chat_list_screen.dart';
import 'package:workwiz/widgets/user_bottom_nav_bar.dart';
import 'package:workwiz/pages/user_category_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  Future<String> _cityFuture = Future<String>.value("Ranchi");

  List<String> imageList = [
    'assets/images/carousel1.jpg',
    'assets/images/carousel2.jpg',
    'assets/images/carousel3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _cityFuture = getCurrentCity();
  }

  Future<String> getCurrentCity() async {
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final Placemark place = placemarks.first;
    return place.locality ?? 'Unknown City';
  }

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
            title: const Text('Home Screen'),
            centerTitle: true,
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatListScreen(
                        currentUserId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: FutureBuilder<String>(
              future: _cityFuture,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Error getting current city: ${snapshot.error}'),
                  );
                } else {
                  final String city = snapshot.data!;
                  print(city);
                  return Column(
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
                              children: [
                                const Text(
                                  'Current Location',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  city,
                                  style: const TextStyle(
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
                      const SizedBox(height: 25),
                      Container(
                        child: CarouselSlider(
                            options: CarouselOptions(
                              height: 110.0,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16/10,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration: Duration(milliseconds: 800),
                              viewportFraction: 0.8,
                            ),
                            items: imageList.map((item) => Container(
                              child: Center(
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                  height: 200,
                                ),
                              ),
                            )).toList(),
                          )
                      ),
                      const SizedBox(height: 25),
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
                              CategoryItem(
                                  icon: Icons.home, title: 'Home Cleaning'),
                              CategoryItem(
                                  icon: Icons.auto_awesome, title: 'Car Wash'),
                              CategoryItem(
                                  icon: Icons.spa, title: 'Personal Care'),
                              CategoryItem(
                                  icon: Icons.build, title: 'Home Repairs'),
                              CategoryItem(
                                  icon: Icons.food_bank,
                                  title: 'Food Delivery'),
                              CategoryItem(
                                  icon: Icons.healing, title: 'Healthcare'),
                              CategoryItem(icon: Icons.pets, title: 'Pet Care'),
                              CategoryItem(
                                  icon: Icons.school, title: 'Tutoring'),
                              CategoryItem(icon: Icons.work, title: 'Others'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
        ));
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryItem({Key? key, required this.icon, required this.title})
      : super(key: key);

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
