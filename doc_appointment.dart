import 'package:flutter/material.dart';
import 'package:medicare_app/services/mongo_service.dart';
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();
  
  final ValueNotifier<bool> showAppointmentsTab = ValueNotifier<bool>(false);
  String doctorId = '';
  String doctorName = '';
  
  // Method to toggle the appointments tab visibility
  void toggleAppointmentsTab(bool value) {
    showAppointmentsTab.value = value;
  }
  
  // Method to set doctor details
  void setDoctorDetails(String id, String name) {
    doctorId = id;
    doctorName = name;
  }
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final doctorId = AppState().doctorId;
      
      if (doctorId.isNotEmpty) {
        final fetchedAppointments = await MongoDBService.getDoctorAppointments(doctorId);
        setState(() {
          appointments = fetchedAppointments;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Appointments"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (appointments.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Appointments"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                "No appointments scheduled",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Your upcoming appointments will appear here",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Appointments"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Patients: ${appointments.length}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return PatientAppointmentCard(appointment: appointment);
        },
      ),
    );
  }
}

class PatientAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const PatientAppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 25,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['userName'] ?? 'Patient Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "ID: ${appointment['userId'] ?? 'Unknown'}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    "Date",
                    appointment['date'] ?? 'Not specified',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.access_time,
                    "Time",
                    appointment['time'] ?? 'Not specified',
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            _buildInfoItem(
              Icons.local_hospital,
              "Reason",
              appointment['specialization'] ?? 'Consultation',
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Add cancel functionality
                    _showCancelDialog(context, appointment);
                  },
                  icon: Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text('Cancel', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add complete appointment functionality
                    _showCompleteDialog(context, appointment);
                  },
                  icon: Icon(Icons.check_circle_outline),
                  label: Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment'),
        content: Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              // Add cancel functionality here
              Navigator.pop(context);
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Appointment cancelled')),
              );
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Appointment'),
        content: Text('Do you confirm this appointment has been completed?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              // Add complete functionality here
              Navigator.pop(context);
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Appointment marked as completed')),
              );
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}