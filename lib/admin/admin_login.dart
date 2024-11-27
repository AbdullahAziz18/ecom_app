import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/admin/admin_home.dart';
import 'package:flutter/material.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    Widget dynamicSizedBox(double largeHeight, double smallHeight) {
      return screenHeight > 700
          ? SizedBox(height: largeHeight)
          : SizedBox(height: smallHeight);
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'images/headphone.PNG',
            height: screenHeight * 0.6,
            width: screenWidth,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 450),
            child: Container(
              height: screenHeight,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight > 700 ? 30 : 22.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    screenWidth > 350
                        ? dynamicSizedBox(50, 40)
                        : dynamicSizedBox(30, 20),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xfff4f5f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: userNameController,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Username',
                        ),
                      ),
                    ),
                    screenWidth > 350
                        ? dynamicSizedBox(20, 10)
                        : dynamicSizedBox(10, 5),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xfff4f5f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: userPasswordController,
                        obscureText:
                            _isPasswordHidden, // Toggles password visibility
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: screenHeight > 700 ? 25 : 15,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordHidden =
                                    !_isPasswordHidden; // Toggles the state
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    screenWidth > 350
                        ? dynamicSizedBox(50, 40)
                        : dynamicSizedBox(30, 20),
                    GestureDetector(
                      onTap: () {
                        loginAdmin();
                      },
                      child: Center(
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: screenWidth / 2.8,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenHeight > 700 ? 15 : 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    screenHeight > 700
                        ? const SizedBox(
                            height: 0,
                          )
                        : const SizedBox(
                            height: 10,
                          )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  loginAdmin() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    FirebaseFirestore.instance.collection('Admin').get().then((snapshot) {
      // ignore: avoid_function_literals_in_foreach_calls
      snapshot.docs.forEach((result) {
        if (result.data()['username'] != userNameController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Invalid Username.',
                style: TextStyle(
                  fontSize: screenHeight > 700 || screenWidth > 350 ? 20 : 15,
                ),
              ),
            ),
          );
        } else if (result.data()['password'] !=
            userPasswordController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Invalid Password.',
                style: TextStyle(
                  fontSize: screenHeight > 700 || screenWidth > 350 ? 20 : 15,
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Logged In Successfully.',
                style: TextStyle(
                  fontSize: screenHeight > 700 || screenWidth > 350 ? 20 : 15,
                ),
              ),
            ),
          );
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminHome()));
        }
      });
    });
  }
}
