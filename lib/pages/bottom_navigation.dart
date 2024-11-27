import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecom_app/pages/cart_page.dart';
import 'package:ecom_app/pages/home_page.dart';
import 'package:ecom_app/pages/profile_page.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BottomNavigation extends StatefulWidget {
  String id;
  BottomNavigation({required this.id, super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late List<Widget> pages;

  late HomePage home;
  late CartPage cart;
  late ProfilePage profile;
  int currentTabIndex = 0;

  @override
  void initState() {
    home = HomePage(
      iD: widget.id,
    );
    cart = CartPage(
      iD: widget.id,
    );
    profile = ProfilePage(
      iD: widget.id,
    );
    pages = [home, cart, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        color: Colors.black,
        backgroundColor: const Color(0xfff2f2f2),
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.person_2_outlined,
            color: Colors.white,
          ),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
