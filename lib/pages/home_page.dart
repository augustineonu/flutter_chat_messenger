import 'dart:io';

import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/pages/call_page.dart';
import 'package:flutter_chat_messenger/pages/chat_page.dart';
import 'package:flutter_chat_messenger/pages/messages_page.dart';
import 'package:flutter_chat_messenger/pages/profile_page.dart';
import 'package:flutter_chat_messenger/services/auth/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signOut() {
    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50.0);

  int _selectedTab = 1;
  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  final List _pages = const [
    Center(
      child: CallsPage(),
    ),
    Center(
      child: MessagesPage(),
    ),
    Center(
      child: ProfilePage(),
    ),
  ];

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  // when the user clicks back button to exit the application
  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            backgroundColor: Color(0xff4c3938),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exit Application',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            children: [
              SizedBox(
                height: 10,
              ),
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Color(0xff1d2951)),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(child: _pages[_selectedTab], onWillPop: onBackPress),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Calls"),
          BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded), label: "Messages"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: "Profile"),
        ],
      ),
    );
  }

  // searchbar
  Widget _searchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[200],
      ),
      child: const TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          // border: OutlineInputBorder(
          //     borderSide: BorderSide(color: Colors.grey, ),
          //   borderRadius: BorderRadius.all(Radius.circular(20.0))
          // ),
          prefixIcon: Icon(Icons.search),
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // build a list of users except for the current logged in user
  Widget _builderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // display all users except current user
    if (_auth.currentUser!.email != data['email']) {
      print("data ${data.toString()}");
      return Column(
        children: [
          ListTile(
            leading: AvatarView(
              radius: 25,
              borderWidth: 2,
              borderColor: Colors.green.shade200,
              isOnlyText: false,
              text: const Text(
                'Test',
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
              avatarType: AvatarType.CIRCLE,
              backgroundColor: Colors.red,
              imagePath: "assets/images/mental.png",
              placeHolder: Container(
                child: const Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
              errorWidget: Container(
                child: const Icon(
                  Icons.error,
                  size: 50,
                ),
              ),
            ),
            title: Text(
              data['email'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            subtitle: Text("Hello"),
            trailing: const Text(
              "2:43 PM",
              style: TextStyle(color: Color.fromARGB(255, 144, 142, 142)),
            ),
            onTap: () {
              // pass the clicked user's UID to the chat page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverUserEmail: data['email'],
                      receiverUserID: data['uid'],
                      fullName: '',
                    ),
                  ));
            },
          ),
          Divider(
              color: Colors.grey.shade300,
              height: 5.0,
              endIndent: 16,
              indent: 16),
        ],
      );
    } else {
      // return empty container
      return Container();
    }
  }
}
