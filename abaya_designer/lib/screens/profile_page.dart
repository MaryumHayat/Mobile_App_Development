import 'dart:ui';
import 'package:abaya_designer/screens/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abaya_designer/screens/splash_page.dart';
import 'home_page.dart';
import 'package:abaya_designer/cart_model.dart'; // Ensure this is imported for cart access

class AppUser {
  final String name;
  final String email;
  final String profilePic;
  final String memberStatus;

  AppUser({
    required this.name,
    required this.email,
    required this.profilePic,
    required this.memberStatus,
  });
}

class ProfilePage extends StatefulWidget {
  final AppUser user;
  final bool isEmbedded;

  const ProfilePage({
    super.key,
    required this.user,
    this.isEmbedded = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showSaved = false;

  void _removeDesign(int index) {
    setState(() {
      savedDesigns.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Removed from saved designs"),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  // --- NEW: Function to show full image and add to cart ---
  // --- FIXED: Function to show full image and add to cart ---
  void _showImageDetails(String imageName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child:
                  Image.asset('assets/images/$imageName', fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 63, 52),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  globalCart.add(CartItem(
                    image: imageName,
                    description: "Custom Saved Design",
                    basePrice: 4500,
                    size:
                        "Small", // Changed from "Standard" to "Std" to fix the 3.2px overflow
                    quantity: 1,
                    sizeSurcharge: 0,
                  ));
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Added to Cart!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("ADD TO CART"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget profileContent = Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/homebg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              _buildProfileHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: _showSaved
                    ? _buildSavedGallery()
                    : _buildProfileMenu(context),
              ),
            ],
          ),
        ),
      ],
    );

    return widget.isEmbedded ? profileContent : Scaffold(body: profileContent);
  }

  Widget _buildProfileHeader() {
    String avatarUrl =
        "https://ui-avatars.com/api/?name=${widget.user.name}&background=2D3E33&color=fff";

    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: const Color.fromARGB(255, 206, 200, 200),
          child: CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFF2D3E33),
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.user.name,
          style: const TextStyle(
            fontFamily: 'Serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          widget.user.email,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: .8),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedGallery() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _showSaved = false),
              ),
              const Text(
                "SAVED DESIGNS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: savedDesigns.isEmpty
              ? const Center(
                  child: Text(
                    "No saved designs yet",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: savedDesigns.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showImageDetails(savedDesigns[index]),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/${savedDesigns[index]}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _removeDesign(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        border: Border.all(color: Colors.white.withValues(alpha: .5)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              _buildMenuItem(
                Icons.favorite_border,
                "My Saved Designs",
                onTap: () {
                  setState(() => _showSaved = true);
                },
              ),
              // Locate the "My Orders" menu item in your ProfilePage and update the onTap:
              _buildMenuItem(
                Icons.shopping_bag_outlined,
                "My Orders",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrdersPage()),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.white54, height: 20),
              ),
              _buildMenuItem(
                Icons.logout,
                "Logout Account",
                isDestructive: true,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const EntryPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 9), // Reduced padding to prevent overflow
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : Colors.white,
        size: 22,
      ),
      title: Text(
        title,
        overflow:
            TextOverflow.ellipsis, // Prevents text from pushing the arrow out
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: isDestructive ? Colors.redAccent : Colors.white,
      ),
    );
  }
}
