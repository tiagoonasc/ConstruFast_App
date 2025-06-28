import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/src/pages/cart/cart_tab.dart';
import 'package:teste/src/pages/home/home_tab.dart';
import 'package:teste/src/pages/orders/orders_tab.dart';
import 'package:teste/src/pages/profile/profile_tab.dart';
import 'package:teste/src/pages/admin/admin_tab.dart'; 

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int currentIndex = 0;
  final pageController = PageController();

  
  final List<Widget> _pages = [
    const HomeTab(),
    const CartTab(),
    const OrdersTab(),
    const ProfileTab()
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      label: 'Carrinho',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Pedidos'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Perfil',
    ),
  ];

  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  //Funcao admin

  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      
      if (mounted && (userDoc.data()?['isAdmin'] ?? false) == true) {
       
        setState(() {
          _pages.add(const AdminTab());
          _navItems.add(
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          );
        });
      }
    } catch (e) {
      
      print("Erro ao verificar status de admin: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
       
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(100),
        // --- MODIFICAÇÃO 4: Usamos as listas dinâmicas aqui ---
        items: _navItems,
      ),
    );
  }
}