import 'dart:async';
import 'dart:io';

import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/model/user_chat_model.dart';
import 'package:flutter_chat_messenger/pages/chat_page.dart';
import 'package:flutter_chat_messenger/providers/home_provider.dart';
import 'package:flutter_chat_messenger/services/auth/auth_service.dart';
import 'package:flutter_chat_messenger/utilities/debouncer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late AuthService authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  void signOut() {
    // get auth service
    // final authService = Provider.of<AuthService>(context, listen: false);
    authProvider.signOut();
    // should redirect to login page
  }

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

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthService>();
    homeProvider = context.read<HomeProvider>();
    // if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
    //   currentUserId = authProvider.getFirebaseUserId()!;
    // } else {
    //   Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute(builder: (context) => const LoginPage()),
    //       (Route<dynamic> route) => false);
    // }

    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 4)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 5.0,
        leading: const Icon(
          Icons.menu_rounded,
          size: 30.0,
        ),
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // sign out button
          // take out this sign out button to profile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                onPressed: signOut,
                icon: const Icon(
                  Icons.logout,
                  size: 30.0,
                )),
          )
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Adjust the height as needed
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _searchBar(),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          }
          // Filter users based on the search text
          final filteredUsers = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['fullName']
                .toLowerCase()
                .contains(_textSearch.toLowerCase());
          }).toList();
          return ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: filteredUsers
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        },
      ),
    );
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // display all users except current user
    if (_auth.currentUser!.email != data['email']) {
      print("data ${data.toString()}");
      UserChat userChat = UserChat.fromDocument(document);
      return Column(
        children: [
          ListTile(
            leading: userChat.photoUrl.isNotEmpty
                ? 
                // ClipRRect(
                //     borderRadius: BorderRadius.circular(25.r),
                //     child: Image.network(
                //       userChat.photoUrl,
                //       fit: BoxFit.cover,
                //       width: 50,
                //       height: 50,
                //       loadingBuilder: (BuildContext ctx, Widget child,
                //           ImageChunkEvent? loadingProgress) {
                //         if (loadingProgress == null) {
                //           return child;
                //         } else {
                //           return SizedBox(
                //             width: 50,
                //             height: 50,
                //             child: CircularProgressIndicator(
                //                 color: Colors.grey,
                //                 value: loadingProgress.expectedTotalBytes !=
                //                         null
                //                     ? loadingProgress.cumulativeBytesLoaded /
                //                         loadingProgress.expectedTotalBytes!
                //                     : null),
                //           );
                //         }
                //       },
                //       errorBuilder: (context, object, stackTrace) {
                //         return const Icon(Icons.account_circle, size: 50);
                //       },
                //     ),
                //   )

                AvatarView(
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
              imagePath: userChat.photoUrl.toString(),
              placeHolder: Container(
                child: const Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
              errorWidget: Container(
                child: Icon(Icons.account_circle, size: 50),
              ),
            )
                : const Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
    
            title: Text(
              data['fullName'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            // subtitle: Text("Hello"),
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
                      fullName: data['fullName'] ?? '',
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

  // searchbar
  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                searchDebouncer.run(() {
                  if (value.isNotEmpty) {
                    buttonClearController.add(true);
                    setState(() {
                      _textSearch = value;
                    });
                  } else {
                    buttonClearController.add(false);
                    setState(() {
                      _textSearch = "";
                    });
                  }
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                // border: OutlineInputBorder(
                //     borderSide: BorderSide(color: Colors.grey, ),
                //   borderRadius: BorderRadius.all(Radius.circular(20.0))
                // ),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search here...',
                suffixIcon: StreamBuilder(
                    stream: buttonClearController.stream,
                    builder: (context, snapshot) {
                      return snapshot.data == true
                          ? GestureDetector(
                              onTap: () {
                                searchTextEditingController.clear();
                                buttonClearController.add(false);
                                setState(() {
                                  _textSearch = '';
                                });
                              },
                              child: const Icon(
                                Icons.clear_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
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
          ),
        ],
      ),
    );
  }
}
