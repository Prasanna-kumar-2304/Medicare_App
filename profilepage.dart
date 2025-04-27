import 'package:flutter/material.dart';

class profiledit extends StatelessWidget {
  final TextEditingController nameController =
      TextEditingController(text: 'Hariasin');
  final TextEditingController phoneController =
      TextEditingController(text: '9486807143');
  final TextEditingController addressController =
      TextEditingController(text: 'Jaihindpuram');
  final TextEditingController pincodeController =
      TextEditingController(text: '625011');

  profiledit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 👈 This will navigate back to ProfilePage
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text("Edit", style: TextStyle(color: Colors.black)),
                Icon(Icons.edit, color: Colors.black, size: 18),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.purpleAccent,
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Change photo", style: TextStyle(color: Colors.white)),
              SizedBox(width: 20),
              Icon(Icons.edit, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(30),
              child: ListView(
                children: [
                  const SizedBox(
                      height: 20), // 👈 Added spacing above Name field
                  buildTextField("Name :", nameController),
                  buildTextField("Phone no :", phoneController),
                  buildTextField("Address :", addressController),
                  buildTextField("Pincode :", pincodeController),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 150, // 👈 Set desired width here
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle submission
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "SUBMIT",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                border: UnderlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
