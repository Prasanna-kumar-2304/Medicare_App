import 'package:flutter/material.dart';
import 'package:medicare_app/screens/user_provider.dart';
// import 'package:medicare_app/screens/add_doctor.dart';
import 'package:medicare_app/services/mongo_service.dart';
import 'package:provider/provider.dart';

class Doctor {
  final String id;
  final String name;
  final String speciality;
  final double rating;
  final Map<String, List<String>> dateSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.dateSlots,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> parseDateSlots() {
      if (json['dateSlots'] != null && json['dateSlots'] is Map) {
        Map<String, List<String>> result = {};
        (json['dateSlots'] as Map).forEach((key, value) {
          if (value is List) {
            result[key.toString()] = List<String>.from(value);
          }
        });
        return result;
      } else if (json['slots'] != null && json['slots'] is List) {
        final defaultSlots = List<String>.from(json['slots']);
        final result = <String, List<String>>{};
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = now.add(Duration(days: i));
          final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          result[dateStr] = List.from(defaultSlots);
        }
        return result;
      } else {
        final defaultSlots = ["10:00 AM", "11:30 AM", "2:00 PM"];
        final result = <String, List<String>>{};
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = now.add(Duration(days: i));
          final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          result[dateStr] = List.from(defaultSlots);
        }
        return result;
      }
    }

    return Doctor(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Doctor',
      speciality: json['specialization'] ?? json['speciality'] ?? 'Specialist',
      rating: (json['rating'] is num) ? json['rating'].toDouble() : 4.5,
      dateSlots: parseDateSlots(),
    );
  }

  List<String> getSlotsForDate(DateTime date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return dateSlots[dateStr] ?? [];
  }

  void removeSlotForDate(DateTime date, String slot) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (dateSlots.containsKey(dateStr)) {
      dateSlots[dateStr]!.remove(slot);
    }
  }
}

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});
  
  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int selectedDoctor = 0;
  int selectedSlot = -1;
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  String errorMessage = '';
  String? filterSpeciality;
  
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    
    // Get the route arguments if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('speciality')) {
        setState(() {
          filterSpeciality = args['speciality'];
        });
      }
      fetchDoctors();
    });
  }

  // In the _AppointmentScreenState class, update the fetchDoctors method
Future<void> fetchDoctors() async {
  if (!mounted) return;
  
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    print('Fetching doctors from API');
    final fetchedDoctors = await MongoDBService.fetchDoctors();
    
    if (!mounted) return;
    
    setState(() {
      doctors = fetchedDoctors;
      // Filter doctors if speciality filter is set
      if (filterSpeciality != null && filterSpeciality!.isNotEmpty) {
        filteredDoctors = doctors.where((doctor) => 
          doctor.speciality.toLowerCase() == filterSpeciality!.toLowerCase()
        ).toList();
        
        // If no doctors match the filter, show all doctors
        if (filteredDoctors.isEmpty) {
          filteredDoctors = doctors;
        }
      } else {
        filteredDoctors = doctors;
      }
      isLoading = false;
      // Reset selected slot as available slots may have changed
      selectedSlot = -1;
      
      // Debug info to check slots
      if (filteredDoctors.isNotEmpty) {
        print('Available slots for selected doctor:');
        final doctor = filteredDoctors[selectedDoctor];
        doctor.dateSlots.forEach((date, slots) {
          print('Date: $date, Slots: $slots');
        });
      }
    });
  } catch (e) {
    print('Error fetching doctors: $e');
    
    if (!mounted) return;
    
    String errorMsg = 'Network error: Unable to connect to the server';
    if (e.toString().contains('SocketException')) {
      errorMsg = 'Network error: Server unavailable. Make sure your Node.js server is running.';
    } else if (e.toString().contains('TimeoutException')) {
      errorMsg = 'Request timed out. Check your network connection and server status.';
    }
    
    setState(() {
      errorMessage = errorMsg;
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filterSpeciality != null ? "$filterSpeciality Specialists" : "Book Appointment"),
        backgroundColor: Colors.blue,
        elevation: 0,
        // Add a clear filter button if filter is active
        actions: filterSpeciality != null ? [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear filter',
            onPressed: () {
              setState(() {
                filterSpeciality = null;
                filteredDoctors = doctors;
              });
            },
          )
        ] : null,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchDoctors,
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : filteredDoctors.isEmpty
                  ? const Center(child: Text("No doctors available"))
                  : buildAppointmentUI(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
      //     ).then((_) => fetchDoctors()); // Refresh doctors after adding new one
      //   },
      //   backgroundColor: Colors.blue,
      //   child: const Icon(Icons.add),
      //   tooltip: 'Add Doctor',
      // ),
    );
  }

  Widget buildAppointmentUI() {
    // Safety check to prevent index out of bounds
    if (selectedDoctor >= filteredDoctors.length) {
      selectedDoctor = 0;
    }
    
    final doctor = filteredDoctors[selectedDoctor];
    final availableSlots = doctor.getSlotsForDate(selectedDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Doctor",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // Select doctor - using filtered doctors
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                var doc = filteredDoctors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDoctor = index;
                      selectedSlot = -1;
                    });
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedDoctor == index
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedDoctor == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: selectedDoctor == index
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              doc.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doc.speciality,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Date selection
          const Text(
            "Select Date",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = date.day == selectedDate.day &&
                    date.month == selectedDate.month;
                    
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      selectedSlot = -1; // Reset selected slot when date changes
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          
          const Text(
            "Available Slots",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Time slots for the selected date
          availableSlots.isEmpty
              ? const Center(
                  child: Text(
                    "No available slots for this date",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(availableSlots.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSlot = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedSlot == index ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedSlot == index ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          availableSlots[index],
                          style: TextStyle(
                            color: selectedSlot == index ? Colors.white : Colors.black,
                            fontWeight: selectedSlot == index ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

          const Spacer(),

          // Book button
          SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: selectedSlot != -1 && availableSlots.isNotEmpty
        ? () async {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
            
            final doctor = filteredDoctors[selectedDoctor];
            final selectedTime = availableSlots[selectedSlot];
            final selectedDateFormatted = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
            
            try {
              // In your appointment screen
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              if (!userProvider.isLoggedIn) {
                // Handle not logged in scenario
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please login to book appointments"),
                    backgroundColor: Colors.red,
                  ),
                );
                // Close loading dialog
                Navigator.of(context).pop();
                return;
              }

              // Book the appointment with actual user data
              final result = await MongoDBService.bookAppointment(
                userId: userProvider.userId!,
                userName: userProvider.userName!,
                doctorId: doctor.id,
                doctorName: doctor.name,
                specialization: doctor.speciality,
                date: selectedDateFormatted,
                time: selectedTime,
              );
              
              // Update local doctor data to reflect the booking
              setState(() {
                // Remove the slot only from the selected date, not from all dates
                doctor.removeSlotForDate(selectedDate, selectedTime);
                // Reset selected slot
                selectedSlot = -1;
              });
              
              // Close loading dialog
              Navigator.of(context).pop();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Appointment booked with ${doctor.name} at $selectedTime"),
                  backgroundColor: Colors.green,
                ),
              );
              
            } catch (e) {
              // Close loading dialog
              Navigator.of(context).pop();
              
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Failed to book appointment: ${e.toString()}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        : null,
        
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: const Text(
                "Book Appointment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}