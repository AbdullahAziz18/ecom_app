import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/admin/admin_login.dart';
import 'package:ecom_app/pages/onboarding.dart';
import 'package:ecom_app/services/auth.dart';
import 'package:ecom_app/services/database.dart';
import 'package:ecom_app/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  String iD;
  ProfilePage({required this.iD, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name, image, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isLoading = false; // Loading state tracker
  final int maxSizeInBytes = 5 * 1024 * 1024;
  fetchUserDetails() async {
    DatabaseMethods databaseMethods = DatabaseMethods();
    DocumentSnapshot userDetails =
        await databaseMethods.getUserDetails(widget.iD);

    if (userDetails.exists) {
      Map<String, dynamic>? data = userDetails.data() as Map<String, dynamic>?;
      // Update the state with user details
      setState(() {
        name = data?['Name'] ?? 'User';
        email = data?['Email'] ?? 'User';
        // ignore: avoid_print
        print("User Name: ${data?['Name']}");
        // ignore: avoid_print
        print("User Email: ${data?['Email']}");
      });
    } else {
      // ignore: avoid_print
      print("User does not exist.");
    }
  }

  getthesharedpref() async {
    await fetchUserDetails();
    image = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      int imageSize = await imageFile.length();
      if (imageSize > maxSizeInBytes) {
        // Show error message if the image size exceeds the limit
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Image size exceeds the 5MB limit. Please select a smaller image.',
              style: TextStyle(fontSize: 15),
            ),
          ),
        );
      } else {
        selectedImage = File(image.path);
        uploadItem();
        setState(() {}); // Update UI with the selected image
      }
    } else {
      // Image is not selected, show a message to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please select an image.',
            style: TextStyle(
              // ignore: use_build_context_synchronously
              fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
            ),
          ),
        ),
      );
    }
  }

  String addId = randomAlphaNumeric(10);
  uploadItem() async {
    if (selectedImage != null) {
      setState(() {
        isLoading = true; // Start loading
      });

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('blogImage').child(addId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();
      await SharedPreferenceHelper().saveUserImage(downloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: name == null
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.cyan,
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight > 700 ? 30 : 22.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    selectedImage != null
                        ? GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.file(
                                  selectedImage!,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: (image != null && image!.isNotEmpty
                                ? Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Image.network(
                                        image!,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Image.asset(
                                        'images/boy.jpg',
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Click on image to change',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: screenHeight > 700 ? 15 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 32,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight > 700 ||
                                              screenWidth > 350
                                          ? 18
                                          : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    name!,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight > 700 ||
                                              screenWidth > 350
                                          ? 22
                                          : 17,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mail_outlined,
                                size: 32,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight > 700 ||
                                                screenWidth > 350
                                            ? 18
                                            : 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      email!,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight > 700 ||
                                                screenWidth > 350
                                            ? 18
                                            : 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Log Out'),
                                titleTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.black),
                                content: const Text(
                                  'Log out of your acount?',
                                  style: TextStyle(fontSize: 20),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await AuthMethods()
                                          .signOut()
                                          .then((value) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Onboarding(),
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  size: 32,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'LogOut',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        screenHeight > 700 || screenWidth > 350
                                            ? 18
                                            : 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Show a dialog to prompt for email and password
                        await showDialog(
                          context: context,
                          builder: (context) {
                            String emailInput = '';
                            String passwordInput = '';
                            return AlertDialog(
                              title: const Text('Re-authenticate'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff4f5f9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Email',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      cursorColor: Colors.black,
                                      onChanged: (value) {
                                        emailInput = value;
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff4f5f9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      obscureText: true,
                                      cursorColor: Colors.black,
                                      onChanged: (value) {
                                        passwordInput = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog without deleting
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Check if email or password is empty
                                    if (emailInput.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter Email.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else if (passwordInput.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please enter Password.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      try {
                                        // Call the deleteUser function with email and password inputs
                                        await AuthMethods().deleteUser(
                                            emailInput, passwordInput);

                                        // Navigate to onboarding if successful
                                        Navigator.pushReplacement(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Onboarding(),
                                          ),
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        // Show error message if re-authentication fails
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.message ??
                                                "Authentication failed."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } catch (e) {
                                        // Handle other errors
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Error: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 32,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        screenHeight > 700 || screenWidth > 350
                                            ? 18
                                            : 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios_outlined),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Switch Account'),
                                titleTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.black),
                                content: const Text(
                                  'Switch to Admin Page?',
                                  style: TextStyle(fontSize: 20),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await AuthMethods()
                                          .signOut()
                                          .then((value) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AdminLogin(),
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.switch_account_outlined,
                                  size: 32,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Switch to Admin',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        screenHeight > 700 || screenWidth > 350
                                            ? 18
                                            : 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
