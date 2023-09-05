import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/pages/call_page.dart';
import 'package:flutter_chat_messenger/pages/chat_page.dart';
import 'package:flutter_chat_messenger/pages/messages_page.dart';
import 'package:flutter_chat_messenger/pages/profile_page.dart';
import 'package:flutter_chat_messenger/services/auth/auth_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
     
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Calls"),
          BottomNavigationBarItem(icon: Icon(Icons.message_rounded), label: "Messages"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: "Profile"),
        ],
      ),
    );
  }

  // searchbar
  Widget  _searchBar() {
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
              borderRadius: BorderRadius.all(Radius.circular(20.0),),),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0,),),),
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
                'C',
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
            title: Text(data['email'], 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
            subtitle: Text("Hello"),
            trailing: const Text("2:43 PM", style: TextStyle(color: 
            Color.fromARGB(255, 144, 142, 142)),),
            onTap: () {
              // pass the clicked user's UID to the chat page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverUserEmail: data['email'],
                      receiverUserID: data['uid'],
                    ),
                  ));
            },
          ),
          Divider(color: Colors.grey.shade300, height: 5.0,endIndent: 16, 
          indent: 16),
        ],
      );
    } else {
      // return empty container
      return Container();
    }
  }


}
