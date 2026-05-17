//import 'package:abaya_designer/main_navigation.dart';
import 'package:abaya_designer/screens/main_navigation.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cart_model.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 56, 33),
      appBar: AppBar(
        title: const Text("MY ORDERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color.fromARGB(255, 194, 239, 220),
        foregroundColor: const Color(0xFF2D3E33),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.uid ?? 'guest')
            .snapshots(), 
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading orders", style: TextStyle(color: Colors.white)));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found", style: TextStyle(color: Colors.white70)));
          }

          // Sort manually by timestamp if the index isn't ready in Firebase yet
          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var order = docs[index].data() as Map<String, dynamic>;
              var items = List.from(order['items'] ?? []);
              String status = (order['status'] ?? 'Pending').toString();
              bool isDelivered = status.toLowerCase() == 'delivered';

              return Card(
                color: Colors.white.withValues(alpha: 0.1),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status: ${status.toUpperCase()}",
                            style: TextStyle(
                              color: isDelivered ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rs. ${order['grandTotal']}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "• ${item['description'] ?? 'Abaya'} (x${item['quantity'] ?? 1})",
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _reorderItems(context, items),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text("REORDER"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF01301C),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _reorderItems(BuildContext context, List items) {
  // Clear the cart if you want a fresh reorder, or keep it to append
  // globalCart.clear(); 

  for (var itemData in items) {
    final Map<String, dynamic> item = Map<String, dynamic>.from(itemData);
    
    // DEBUG: Uncomment the line below to check your console for unique image names
    // print("Reordering item with image: ${item['image']}");

    globalCart.add(CartItem(
      // Ensure this key 'image' matches exactly what you named it in your Checkout/Firebase save logic
      image: item['image']?.toString() ?? "h1.jpg", 
      description: item['description']?.toString() ?? "Elegant Abaya",
      basePrice: (item['price'] is int) ? item['price'] : (item['price'] ?? 0).toInt(),
      size: item['size']?.toString() ?? "Small",
      quantity: (item['quantity'] is int) ? item['quantity'] : 1,
      sizeSurcharge: 0,
    ));
  }
  
  // Navigation to reset the app state and show the new cart items
  Navigator.pushAndRemoveUntil(
    context, 
    MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 2)),
    (route) => false,
  );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Reordered items added to your cart!"),
        backgroundColor: Color(0xFF017059),
        duration: Duration(seconds: 2)
      ),
    );
  }
}