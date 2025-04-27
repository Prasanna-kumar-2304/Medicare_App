import 'package:flutter/material.dart';
import 'package:medicare_app/screens/Home_Screen.dart';
import 'package:medicare_app/screens/chatbot.dart';
import 'package:medicare_app/screens/delivery1.dart';
import 'package:medicare_app/screens/profile.dart';
import 'package:medicare_app/screens/doc_appointment.dart';
import 'package:medicare_app/services/mongo_service.dart';

// Create a global state management for the appointments tab visibility
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();
  
  final ValueNotifier<bool> showAppointmentsTab = ValueNotifier<bool>(false);
  
  // Method to toggle the appointments tab visibility
  void toggleAppointmentsTab(bool value) {
    showAppointmentsTab.value = value;
  }
}

// Modify the DoctorForm class to use the AppState
class DoctorForm extends StatelessWidget {
  final PageController pageController = PageController();
  final ValueNotifier<int> currentPage = ValueNotifier<int>(0);

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController graduationYearController =
      TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController specialtyController = TextEditingController();

  final TextEditingController experienceYearsController =
      TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  DoctorForm({super.key});

  void nextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
      pageController.animateToPage(currentPage.value,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.animateToPage(currentPage.value,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

void submitForm(BuildContext context) async {
  try {
    // Get the form values
    String name = fullNameController.text;
    String specialization = specialtyController.text;
    String hospital = hospitalController.text;
    // For location, you can use the address or add a separate field
    String location = addressController.text;
    String experience = experienceYearsController.text;
    // Setting default values for required fields that are not in the form
    double rating = 4.0; // Default rating
    bool available = true; // Default availability
    List<String> slots = ['9:00 AM', '10:00 AM', '11:00 AM']; // Default slots
    
    // Call the MongoDB service to add the doctor
    final result = await MongoDBService.addDoctor(
      name: name,
      specialization: specialization,
      hospital: hospital,
      location: location,
      experience: experience,
      rating: rating,
      available: available,
      slots: slots,
    );
    
    // Enable the appointments tab when the form is submitted successfully
    AppState().toggleAppointmentsTab(true);
    
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor details have been submitted successfully.'),
            SizedBox(height: 16),
            Text('The Appointments tab has been added to your navigation bar.'),
            SizedBox(height: 8),
            Text('You can toggle its visibility from the home screen using the calendar icon button.')
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
            child: Text('OK')
          ),
        ],
      ),
    );
  } catch (e) {
    // Show error dialog if submission fails
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to submit doctor details: ${e.toString()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK')
          ),
        ],
      ),
    );
  }
}

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget stepIndicator(int step) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPage,
      builder: (context, value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                decoration: BoxDecoration(
                  color: index <= value ? Colors.blue : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (currentPage.value > 0) {
              previousPage();
            } else {
              Navigator.pop(context); // Exit form or go back
            }
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text("Act as Doctor",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(width: 48), // To balance the IconButton width
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPage,
      builder: (context, value, _) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const SizedBox(height: 25),
                header(context),
                const SizedBox(height: 40),
                stepIndicator(value),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      // Page 1: Personal Details
                      ListView(
                        children: [
                          const Text(
                            "Personal Details :",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          buildTextField("Full Name", fullNameController),
                          buildTextField("Gender", genderController),
                          buildTextField("Age / Date of Birth", dobController),
                          buildTextField("Phone Number", phoneController),
                          buildTextField("Email Address", emailController),
                          buildTextField("Address", addressController),
                          SizedBox(
                            height: 30,
                            width: 100,
                          ),
                          ElevatedButton(
                            onPressed: nextPage,
                            child: Text("Next",
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                          ),
                        ],
                      ),

                      // Page 2: Educational Details
                      ListView(
                        children: [
                          const Text("Educational Details :",
                              style: TextStyle(fontSize: 25)),
                          SizedBox(
                            height: 30,
                          ),
                          buildTextField(
                              "Highest Qualification (e.g., MBBS, MD)",
                              qualificationController),
                          buildTextField(
                              "University/College Name", collegeController),
                          buildTextField(
                              "Year of Graduation", graduationYearController),
                          buildTextField(
                              "Registration Number (Medical Council ID)",
                              registrationNumberController),
                          buildTextField("Specialty", specialtyController),
                          SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: nextPage,
                            child: Text("Next",
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                          ),
                        ],
                      ),

                      // Page 3: Experience
                      ListView(
                        children: [
                          const Text("Total Years of Experience :",
                              style: TextStyle(fontSize: 25)),
                          SizedBox(
                            height: 30,
                          ),
                          buildTextField("Total Years of Experience",
                              experienceYearsController),
                          buildTextField("Current Hospital/Clinic Name",
                              hospitalController),
                          buildTextField("Designation/Role", roleController),
                          SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: () => submitForm(context),
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Create a simple AppointmentsScreen


// Modify the MainScreen to include the dynamic appointments tab
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _baseScreens = [
    const HomeScreen(),
    const DeliveryScreen(),
    const ChatBotScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState().showAppointmentsTab,
      builder: (context, showAppointmentsTab, child) {
        // Create a dynamic list of screens and nav items based on appointments visibility
        final List<Widget> currentScreens = List.from(_baseScreens);
        
        // If we need to show appointments, insert it after delivery screen (index 1)
        if (showAppointmentsTab) {
          currentScreens.insert(2, const AppointmentsScreen());
        }
        
        // Adjust current index if we're removing a tab that was selected
        if (!showAppointmentsTab && _currentIndex >= 2) {
          _currentIndex = _currentIndex >= currentScreens.length ? currentScreens.length - 1 : _currentIndex;
        }
        
        return Scaffold(
          body: currentScreens[_currentIndex],
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
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Delivery',
              ),
              // Conditionally add the appointments tab
              if (showAppointmentsTab)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Appointments',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
