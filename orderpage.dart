import 'package:flutter/material.dart';

class MyOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // <-- Goes back to the previous screen
          },
        ),
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'My Orders',
                style: TextStyle(
                    color: const Color(0xFF2F80ED),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: const [
          Icon(Icons.close, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("CURRENT ORDERS",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                      'https://th.bing.com/th/id/OIP.0MDGYvUGtUZ9kGOKGboTBAHaFj?w=2000&h=1500&rs=1&pid=ImgDetMain'), // Replace with your image URL
                  radius: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Cold Cough Syrup 200ml",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Item shipped",
                          style: TextStyle(color: Colors.blueAccent)),
                      Text("ETA: 13 May", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("PAST ORDERS",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          buildOrderItem("Paracetamol", "22 Dec 2024",
              "https://th.bing.com/th/id/OIP.R_SYA34g2dikbYtO-5OMPgHaIp?rs=1&pid=ImgDetMain"),
          buildOrderItem("A MAX (Vitamin A) drops 10ml", "10 Jun 2024",
              "https://canprev.ca/wp-content/uploads/2023/03/1647364277_CP-VitaminADropsBox-15ml-RGB-195407-V1_839_1430.png"),
          buildOrderItem("Acefyl Syrup 125ml", "07 Sep 2023",
              "https://img.freepik.com/premium-psd/pharmaceutical-medicine-syrup-bottle-packaging-mockup_47987-4813.jpg?w=2000"),
          buildOrderItem("Vitamin A Chewable Tablet", "27 May 2022",
              "https://th.bing.com/th/id/OIP.QQdTClFFtkEyCz-qlP7xsAHaHa?w=980&h=980&rs=1&pid=ImgDetMain"),
          buildOrderItem("Gliozolamide 100mg Tablet", "27 Feb 2022",
              "https://th.bing.com/th/id/OIP.pz0wWGQuZyyJgQalIprQQQAAAA?w=400&h=300&rs=1&pid=ImgDetMain"),
        ],
      ),
    );
  }

  Widget buildOrderItem(String title, String date, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Text("Delivered", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
