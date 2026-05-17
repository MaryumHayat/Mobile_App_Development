// ignore_for_file: use_build_context_synchronously
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../cart_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation.dart';

class CheckoutPage extends StatefulWidget {
  final String? selectedAbaya;
  final String? selectedHijab;
  final String? selectedSize;
  final String? abayaColor;
  final String? hijabColor;

  const CheckoutPage({
    super.key,
    this.selectedAbaya,
    this.selectedHijab,
    this.selectedSize,
    this.abayaColor,
    this.hijabColor,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isOrdered = false;
  String? _newOrderId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    int subtotal = 0;
    const int shippingTax = 250;

    if (widget.selectedAbaya != null || widget.selectedHijab != null) {
      int abayaPrice = widget.selectedAbaya != null ? 3500 : 0;
      int hijabPrice = widget.selectedHijab != null ? 700 : 0;
      subtotal = abayaPrice + hijabPrice;
    } else {
      for (var item in globalCart) {
        subtotal += item.total;
      }
    }

    int grandTotal = subtotal + shippingTax;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 56, 33),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 194, 239, 220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3E33)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Checkout", style: TextStyle(color: Color(0xFF2D3E33), fontWeight: FontWeight.bold)),
      ),
      body: _isOrdered && _newOrderId != null
          ? OrderSuccessScreen(orderId: _newOrderId!)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.05, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDetailedSummary(subtotal, shippingTax, grandTotal),
                    const SizedBox(height: 25),
                    _buildGlassForm(grandTotal),
                  ],
                ),
              ),
            ),
    );
  }

  // --- UI Builder Methods ---

  Widget _buildDetailedSummary(int subtotal, int tax, int grandTotal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color.fromARGB(255, 225, 234, 231)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(thickness: 1, color: Colors.black),
          if (widget.selectedAbaya == null && globalCart.isNotEmpty)
            ...globalCart.map((item) => _buildItemRow(item)),
          if (widget.selectedAbaya != null) _buildCustomItemRow(),
          const SizedBox(height: 15),
          const Divider(thickness: 1, color: Colors.black),
          _buildPriceRow("Subtotal", "Rs. $subtotal"),
          _buildPriceRow("Shipping Tax", "Rs. $tax"),
          const SizedBox(height: 10),
          _buildPriceRow("Grand Total", "Rs. $grandTotal", isBold: true),
        ],
      ),
    );
  }

  Widget _buildItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/${item.image}', width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text("Base: Rs. ${item.basePrice} | Size: ${item.size}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text("Qty: ${item.quantity}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text("Rs. ${item.total}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCustomItemRow() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.auto_awesome, color: Color(0xFF2D3E33)),
      title: Text("Custom Abaya (${widget.abayaColor})"),
      subtitle: Text("Size: ${widget.selectedSize}"),
      trailing: const Text("Rs. 3500", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildGlassForm(int grandTotal) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 224, 219).withValues(alpha: .1),
            border: Border.all(color: Colors.white.withValues(alpha: .3)),
          ),
          child: Column(
            children: [
              const Text("Shipping Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _buildTextField("Full Name", _nameController, (v) => v!.isEmpty ? "Enter name" : null),
              _buildTextField("03XXXXXXXXX", _phoneController, (v) {
                if (!RegExp(r'^03\d{9}$').hasMatch(v!)) return "Use format 03xxxxxxxxx";
                return null;
              }, keyboard: TextInputType.phone),
              _buildTextField("Street, Lane, Area, City", _addressController, (v) {
                if (v!.length < 15) return "Please provide full address details";
                return null;
              }, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async => await _submitOrder(grandTotal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text("Confirm Order", style: TextStyle(color: Color(0xFF01301C), fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? Function(String?)? validator, {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 218, 243, 227)),
          filled: true,
          fillColor: const Color.fromARGB(255, 194, 239, 220).withValues(alpha: .2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(1), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<void> _submitOrder(int grandTotal) async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        
        List<Map<String, dynamic>> items = widget.selectedAbaya != null 
          ? [{ 'description': 'Custom Abaya (${widget.abayaColor})', 'image': 'custom_abaya.jpg', 'size': widget.selectedSize, 'price': 3500, 'quantity': 1 }]
          : globalCart.map((i) => { 'description': i.description, 'image': i.image, 'price': i.basePrice, 'quantity': i.quantity, 'size': i.size }).toList();

        DocumentReference docRef = await FirebaseFirestore.instance.collection('orders').add({
          'userId': user?.uid ?? 'guest',
          'customerName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'items': items,
          'grandTotal': grandTotal,
          'status': 'Pending',
          'isAcknowledged': false, // IMPORTANT: Used for the global hijack logic
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _newOrderId = docRef.id;
          _isOrdered = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Database Error: $e")));
      }
    }
  }
}

// --- ORDER SUCCESS COMPONENT ---

// Part of checkout_page.dart

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final bool isGlobalOverlay; 
  const OrderSuccessScreen({super.key, required this.orderId, this.isGlobalOverlay = false});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late VideoPlayerController _controller;
  final String trackingId = "ABY-${Random().nextInt(900000) + 100000}";
  int _userRating = 0;
  bool _ratingSubmitted = false;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    globalCart.clear();
    _controller = VideoPlayerController.asset('assets/images/delivery.mp4')
      ..initialize().then((_) {
        _controller.setVolume(0.0);
        _controller.setLooping(false);
        if (mounted) setState(() => _videoInitialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        var orderData = snapshot.data!.data() as Map<String, dynamic>;
        String status = orderData['status'] ?? 'Pending';
        bool isAcknowledged = orderData['isAcknowledged'] ?? false;

        // 1. If user clicked "Shop Again", remove overlay
        if (isAcknowledged) return const SizedBox.shrink();

        // 2. If status is Delivered, show the success layout (Always)
        if (status == 'Delivered') {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 1, 56, 33),
            body: _buildDeliveredLayout(MediaQuery.of(context).size.height),
          );
        }

        // 3. If NOT delivered and we are in Global mode, stay invisible
        if (widget.isGlobalOverlay) {
          return const SizedBox.shrink();
        }

        // 4. Otherwise, show tracking (Normal Checkout flow)
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 1, 56, 33),
          body: _buildTrackingLayout(status),
        );
      },
    );
  }

  Widget _buildTrackingLayout(String status) {
    bool isOut = status == 'Out for Delivery';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isOut ? Icons.local_shipping_outlined : Icons.check_circle_outline, color: Colors.white, size: 80),
          const SizedBox(height: 20),
          Text(isOut ? "Out for Delivery" : "Order Confirmed!", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(isOut ? "Rider is picking up your order" : "Tracking ID: $trackingId", style: const TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDeliveredLayout(double screenHeight) {
    return Column(
      children: [
        Container(
          height: screenHeight * 0.35,
          width: double.infinity,
          color: Colors.black,
          child: _videoInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller..play()),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
            child: Column(
              children: [
                const Text("Order Delivered!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(_ratingSubmitted ? "Thank you!" : "How was your experience?", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: _ratingSubmitted ? null : () {
                        setState(() {
                          _userRating = index + 1;
                          _ratingSubmitted = true;
                        });
                      },
                      icon: Icon(Icons.star, color: index < _userRating ? Colors.amber : Colors.white24, size: 40),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Update Firestore so the Global Overlay listener removes this screen
                      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'isAcknowledged': true});
                      
                      if (!widget.isGlobalOverlay) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 0)),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text("SHOP AGAIN", style: TextStyle(color: Color(0xFF01301C), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}