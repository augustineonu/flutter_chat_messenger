// import 'package:flutter/material.dart';
// import 'package:flutter_chat_messenger/pages/chat_page.dart';
// import 'package:flutter_chat_messenger/pages/home_page.dart';

// class Navigation extends StatefulWidget {
//   const Navigation({super.key});

//   @override
//   State<Navigation> createState() => _NavigationState();
// }

// class _NavigationState extends State<Navigation> {
//   int _selectedTab = 0;

//   List _pages = [
//     Center(
//       child: HomePage(),
//     ),
//     Center(
//       child: ChatPage(receiverUserEmail: '',
//        receiverUserID: '',),
//     ),
//     Center(
//       child: Profile(),
//     ),
   
//   ];

//   _changeTab(int index) {
//     setState(() {
//       _selectedTab = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(),
//       body: _pages[_selectedTab],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedTab,
//         onTap: (index) => _changeTab(index),
//         selectedItemColor: Colors.red,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "About"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.grid_3x3_outlined), label: "Product"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.contact_mail), label: "Contact"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.settings), label: "Settings"),
//         ],
//       ),
//     );
//   }
// }