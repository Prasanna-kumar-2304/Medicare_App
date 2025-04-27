import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int quantity = 1;

  void addToCart() {
    // Create a copy of the medicine item with quantity
    final Map<String, dynamic> cartItem = {
      ...widget.medicine,
      'quantity': quantity,
    };
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.medicine['name']} (x$quantity) added to cart!"),
      ),
    );
    
    // Return to previous screen with cart item data
    Navigator.pop(context, cartItem);
  }

  @override
  Widget build(BuildContext context) {
    final medicine = widget.medicine;
    // Convert price to double before calculations
    final double originalPrice = medicine["price"].toDouble();
    final double offerPrice = originalPrice * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine["name"]),
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  medicine["image"],
                  height: 160,
                  fit: BoxFit.contain, // Show full image
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              medicine["name"],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              medicine["desc"],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "₹${offerPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(width: 10),
                Text(
                  "₹${originalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("15% OFF", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Quantity:", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text("$quantity", style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Add to Cart", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Amit"),
              subtitle: const Text("Very effective. Works quickly!"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 16)),
              ),
            ),
            ListTile(
              title: const Text("Sneha"),
              subtitle: const Text("Affordable and helpful during fever."),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (i) => const Icon(Icons.star, color: Colors.amber, size: 16))
                  ..add(const Icon(Icons.star_border, color: Colors.amber, size: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}