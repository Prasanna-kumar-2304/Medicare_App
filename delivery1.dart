import 'package:flutter/material.dart';
import 'medicine_detail_screen.dart'; 

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final List<Map<String, dynamic>> medicines = [
    { 
      "name": "Paracetamol 500mg",
      "desc": "For fever and mild pain",
      "price": 40,
      "image": "assets/paracetamol.png"
    },
    {
      "name": "Vitamin D3",
      "desc": "Bone strength supplement",
      "price": 120,
      "image": "assets/vitamin_d3.png"
    },
    {
      "name": "Ibuprofen",
      "desc": "Pain reliever & anti-inflammatory",
      "price": 55,
      "image": "assets/ibuprofen.png"
    },
    {
      "name": "Cotton Buds",
      "desc": "Personal hygiene use",
      "price": 20,
      "image": "assets/cotton_buds.png"
    },
    {
      "name": "Saibol",
      "desc": "Energy tonic supplement",
      "price": 110,
      "image": "assets/saibol.png"
    },
    {
      "name": "Dettol",
      "desc": "Antiseptic liquid",
      "price": 70,
      "image": "assets/dettol.png"
    },
  ];

  final List<Map<String, dynamic>> cart = [];

  void addToCart(Map<String, dynamic> item, {int quantity = 1}) {
    setState(() {
      // Check if item is already in cart
      final existingIndex = cart.indexWhere((element) => element['name'] == item['name']);
      
      if (existingIndex >= 0) {
        // Update quantity if already in cart
        cart[existingIndex]['quantity'] = (cart[existingIndex]['quantity'] ?? 1) + quantity;
      } else {
        // Add new item with quantity
        final itemWithQuantity = {...item, 'quantity': quantity};
        cart.add(itemWithQuantity);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item['name']} added to cart")),
    );
  }

  void showCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Calculate total considering quantities
        double total = cart.fold(0, (sum, item) => 
          sum + (item['price'] * (item['quantity'] ?? 1)));
          
        return AlertDialog(
          title: const Text("Your Cart"),
          content: cart.isEmpty
              ? const Text("Your cart is empty.")
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...cart.map((item) => ListTile(
                            title: Text(item['name']),
                            subtitle: Text("Qty: ${item['quantity'] ?? 1}"),
                            trailing: Text("₹${item['price'] * (item['quantity'] ?? 1)}"),
                          )),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("Total: ₹$total",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            if (cart.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Order placed successfully!")),
                  );
                  setState(() => cart.clear());
                },
                child: const Text("Place Order"),
              )
          ],
        );
      },
    );
  }

  Future<void> navigateToDetail(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailScreen(medicine: item),
      ),
    );
    
    // If we get back a result, add it to cart
    if (result != null && result is Map<String, dynamic>) {
      final quantity = result['quantity'] ?? 1;
      addToCart(item, quantity: quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Medical Store"),
        backgroundColor: Colors.blue.shade600,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: showCartDialog,
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final item = medicines[index];
          return GestureDetector(
            onTap: () => navigateToDetail(item),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16/9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["desc"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${item["price"]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => addToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text("Add to Cart", style: TextStyle(fontSize: 12,color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}