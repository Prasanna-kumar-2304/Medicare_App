import 'package:flutter/material.dart';
import 'package:medicare_app/app_routes.dart';
import 'package:medicare_app/screens/chatbot.dart';
import 'package:medicare_app/screens/delivery1.dart';
import 'package:medicare_app/screens/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Existing doctors list and categories remain unchanged
  final List<Map<String, dynamic>> doctors = [
    {
      "name": "Dr. Andy Wilson",
      "speciality": "Dermatologist",
      "rating": 4.6,
      "image": "assets/doctor1.png"
    },
    {
      "name": "Dr. Priya Sharma",
      "speciality": "Orthopedist",
      "rating": 4.7,
      "image": "assets/doctor.png"
    },
    {
      "name": "Dr. Ananya K",
      "speciality": "Pediatrician",
      "rating": 4.4,
      "image": "assets/doctor.png"
    },
  ];

  final List<Map<String, dynamic>> categories = [
  {
    "name": "Pediatrician",
    "icon": Icons.child_care,
    "color": Colors.orange,
  },
  {
    "name": "Cardiologist",
    "icon": Icons.favorite,
    "color": Colors.red,
  },
  {
    "name": "Dentist",
    "icon": Icons.emoji_emotions,
    "color": Colors.blue,
  },
  {
    "name": "Orthopedist",
    "icon": Icons.accessibility_new,
    "color": Colors.green,
  },
  {
    "name": "Neurologist",
    "icon": Icons.psychology,
    "color": Colors.purple,
  },
  {
    "name": "ENT Specialist",
    "icon": Icons.hearing,
    "color": Colors.teal,
  },
  {
    "name": "Psychiatrist",
    "icon": Icons.mood,
    "color": Colors.amber,
  },
  {
    "name": "Urologist",
    "icon": Icons.water_drop,
    "color": Colors.lightBlue,
  },
  {
    "name": "Oncologist",
    "icon": Icons.biotech,
    "color": Colors.deepOrange,
  },
  {
    "name": "Hematologist",
    "icon": Icons.opacity,
    "color": Colors.red[900],
  },
  {
    "name": "Nutritionist",
    "icon": Icons.restaurant,
    "color": Colors.greenAccent,
  },
  {
    "name": "Physical Therapist",
    "icon": Icons.directions_run,
    "color": Colors.blueGrey,
  },
  {
    "name": "Surgeon",
    "icon": Icons.medical_services,
    "color": Colors.redAccent,
  },
];

  @override
  Widget build(BuildContext context) {
    // Existing build method remains unchanged
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Good Morning ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: "Prasanna",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: " 👋",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.location_on_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search doctor",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Promotion card
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue[800]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Exclusive Offer for New Users!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Get your first consultation with top doctors at 20% OFF. Limited time only!",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.asset(
                              'assets/doctor.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Categories section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Find Your Specialists",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                   
                  ],
                ),
                const SizedBox(height: 16),

              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to appointment screen with the selected category
                        Navigator.pushNamed(
                          context, 
                          AppRoutes.appointment,
                          arguments: {'speciality': category["name"]}
                        );
                      },
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 3,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                category["icon"],
                                color: category["color"],
                                size: 32.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category["name"],
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
                
                const SizedBox(height: 30),
                
                // Top Specialists section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Top Specialists",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("See all"),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Doctor cards
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return GestureDetector(
        onTap: () {
          // Navigate to specialist details screen
          Navigator.pushNamed(
            context,
            AppRoutes.doctorDetails,
            arguments: {
              'doctor': doctor,
              'speciality': doctor["speciality"]
            },
          );
        },
                      child:  Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: index == 2 ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: Image.asset(
                                    doctor["image"],
                                    fit: BoxFit.fitHeight,
                                  ),
                                  
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        doctor["rating"].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: index == 2
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor["name"],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: index == 2
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    doctor["speciality"],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: index == 2
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Main app with navigation between screens
class DoctorApp extends StatefulWidget {
  const DoctorApp({super.key});

  @override
  State<DoctorApp> createState() => _DoctorAppState();
}

class _DoctorAppState extends State<DoctorApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        ...AppRoutes.routes,
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      // Use either initialRoute or home, not both
      // Remove the home property when using initialRoute
      // The splash screen should navigate to your main screen with bottom nav
    );
  }
}

// Create a separate MainScreen widget to be used after splash
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const DeliveryScreen(),
    const ChatBotScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'delivery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),  
    );
  }
}