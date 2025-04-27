import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Meetings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("current meetings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DoctorCard(
              name: 'Dr. Hari',
              field: 'cardiology',
              rating: '4.8',
              date: '02/05/2025',
              time: '4 pm',
              isCurrent: true,
            ),
            const SizedBox(height: 20),
            const Text("older meetings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DoctorCard(
              name: 'Dr. Prasanna',
              field: 'cardiology',
              rating: '4.8',
              date: '02/05/2024',
              time: '4 pm',
              isCurrent: false,
            ),
            DoctorCard(
              name: 'Dr. Praga',
              field: 'cardiology',
              rating: '3.8',
              date: '29/04/2024',
              time: '4 pm',
              isCurrent: false,
            ),
            DoctorCard(
              name: 'Dr. Akash',
              field: 'cardiology',
              rating: '4.3',
              date: '29/04/2024',
              time: '4 pm',
              isCurrent: false,
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String field;
  final String rating;
  final String date;
  final String time;
  final bool isCurrent;

  const DoctorCard({
    super.key,
    required this.name,
    required this.field,
    required this.rating,
    required this.date,
    required this.time,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                  'assets/doctor.png'), // Replace with your image asset
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(field),
                  Text("$rating star🌟"),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Appointment: $time',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("Date: $date", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if (isCurrent)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.video_call, color: Colors.blue),
                        label: const Text("Video Call"),
                      ),
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
