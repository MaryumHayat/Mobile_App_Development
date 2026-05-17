// FirestoreHelper.dart
import 'package:abaya_designer/cart_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper { 
  static final _db = FirebaseFirestore.instance; 
  static final _auth = FirebaseAuth.instance;

  static Future<void> saveUser(String name, String email) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> placeOrder(List<CartItem> cart, String phone, String address, double total) async {
    final user = _auth.currentUser;
    
    List<Map<String, dynamic>> cartMaps = cart.map((item) => {
      'description': item.description,
      'price': item.basePrice,
      'quantity': item.quantity,
      'image': item.image, // Stores "h1.jpg"
      'size': item.size,
    }).toList();

    await _db.collection('orders').add({ 
      'userId': user?.uid ?? 'guest', 
      'items': cartMaps, 
      'phone': phone,
      'address': address,
      'grandTotal': total,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}