// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mybukupink/screens/community_screen.dart';
import 'package:mybukupink/screens/home_screen.dart';
import 'package:mybukupink/screens/lifestyle_screen.dart';
import 'package:mybukupink/screens/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          LifestyleScreen(),
          CommunityScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0
                    ? const Color.fromRGBO(255, 53, 139, 1)
                    : Colors.black,
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                'assets/icons/home.svg',
                width: 24, // Set the width of the SVG icon
                height: 24, // Set the height of the SVG icon
              ),
            ),
            label: 'Menu Utama',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1
                    ? const Color.fromRGBO(255, 53, 139, 1)
                    : Colors.black,
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                'assets/icons/lifestyle.svg',
                width: 24, // Set the width of the SVG icon
                height: 24, // Set the height of the SVG icon
              ),
            ),
            label: 'Gaya Hidup',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _selectedIndex == 2
                    ? const Color.fromRGBO(255, 53, 139, 1)
                    : Colors.black,
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                'assets/icons/community.svg',
                width: 24, // Set the width of the SVG icon
                height: 24, // Set the height of the SVG icon
              ),
            ),
            label: 'Komuniti',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _selectedIndex == 3
                    ? const Color.fromRGBO(255, 53, 139, 1)
                    : Colors.black,
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                'assets/icons/profile.svg',
                width: 24, // Set the width of the SVG icon
                height: 24, // Set the height of the SVG icon
              ),
            ),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color.fromRGBO(255, 53, 139, 1),
      ),
    );
  }
}
