import 'dart:ui';
import 'package:abaya_designer/cart_model.dart';
import 'package:abaya_designer/cart_page.dart';
import 'package:abaya_designer/screens/checkout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'design_page.dart';
import 'profile_page.dart';


class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  String? savedAbaya;
  String? savedHijab;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  AppUser get _currentAppUser {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "guest@abaya.com";
    final displayName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : email.split('@')[0].toUpperCase();

    return AppUser(
      name: displayName,
      email: email,
      profilePic: email,
      memberStatus: "Studio Designer",
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final List<Widget> pages = [
      HomePage(onCartUpdated: _updateUI),
      DesignPage(
        initialAbaya: savedAbaya,
        initialHijab: savedHijab,
        onSaveState: (abaya, hijab) => setState(() {
          savedAbaya = abaya;
          savedHijab = hijab;
        }),
        onBack: () => setState(() => _selectedIndex = 0),
      ),
      CartPage(key: ValueKey('cart_${globalCart.length}')),
      ProfilePage(user: _currentAppUser, isEmbedded: true),
    ];

    bool isDarkBackground = _selectedIndex == 0 || _selectedIndex == 3;
    Color activeColor = isDarkBackground ? Colors.white : const Color(0xFF2D3E33);

    return Stack(
      children: [
        // --- BASE APP LAYER ---
        Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkBackground
                      ? Colors.black.withValues(alpha: .2)
                      : Colors.white.withValues(alpha: .4),
                  border: Border(
                    top: BorderSide(color: isDarkBackground ? Colors.white10 : Colors.black12),
                  ),
                ),
                child: SafeArea(
                  child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (index) => setState(() => _selectedIndex = index),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: activeColor,
                    unselectedItemColor: activeColor.withValues(alpha: .4),
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    items: [
                      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 28), label: ''),
                      const BottomNavigationBarItem(icon: Icon(Icons.design_services_outlined, size: 28), label: ''),
                      BottomNavigationBarItem(
                        icon: Badge(
                          label: Text(globalCart.length.toString()),
                          isLabelVisible: globalCart.isNotEmpty,
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.shopping_cart_outlined, size: 28),
                        ),
                        label: '',
                      ),
                      const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 28), label: ''),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- GLOBAL HIJACK LAYER ---
        if (user != null)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .where('status', isEqualTo: 'Delivered')
                .where('isAcknowledged', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final orderId = snapshot.data!.docs.first.id;
                return OrderSuccessScreen(
                  orderId: orderId,
                  isGlobalOverlay: true,
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}