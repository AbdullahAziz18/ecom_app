import 'package:ecom_app/pages/login_page.dart';
import 'package:ecom_app/pages/bottom_navigation.dart';
import 'package:ecom_app/services/database.dart';
import 'package:ecom_app/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? name, email, password;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // Email validation using RegExp
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
    );
    return emailRegex.hasMatch(email);
  }

  registration() async {
    // Trim email to avoid leading/trailing whitespaces
    String trimmedEmail = email?.trim() ?? "";

    if (password != null && name != null && isValidEmail(trimmedEmail)) {
      try {
        // ignore: unused_local_variable
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: trimmedEmail,
          password: password!,
        );

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Registered Successfully.',
              style: TextStyle(
                // ignore: use_build_context_synchronously
                fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
              ),
            ),
          ),
        );
        String id = emailController.text;
        await SharedPreferenceHelper().saveUserEmail(emailController.text);
        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserName(nameController.text);
        await SharedPreferenceHelper().saveLoginState();
        Map<String, dynamic> userInfoMap = {
          'Name': nameController.text,
          'Email': emailController.text,
          'Id': id,
        };
        await DatabaseMethods().addUserDetails(userInfoMap, id);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigation(
              id: id,
            ),
          ),
        );
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Password provided is too weak.',
                style: TextStyle(
                  // ignore: use_build_context_synchronously
                  fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
                ),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Account already exists.',
                style: TextStyle(
                  // ignore: use_build_context_synchronously
                  fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
                ),
              ),
            ),
          );
        } else if (e.code == 'invalid-email') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Invalid email format.',
                style: TextStyle(
                  // ignore: use_build_context_synchronously
                  fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
                ),
              ),
            ),
          );
        }
      }
    } else {
      // Handle invalid email case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please enter a valid email.',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
            ),
          ),
        ),
      );
    }
  }

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
      body: Form(
        key: _formkey,
        child: Stack(
          children: [
            Image.asset(
              'images/sebastiaan-chia-AYHq5mSVm98-unsplash.jpg',
              height: screenHeight * 0.4,
              width: screenWidth,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 250),
              child: Container(
                height: screenHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight > 700 ? 25 : 17.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Please enter details to continue',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: screenHeight > 700 ? 15 : 5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      dynamicSizedBox(40, 20),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xfff4f5f9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter your Name';
                            } else {
                              return null;
                            }
                          },
                          controller: nameController,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name',
                          ),
                        ),
                      ),
                      dynamicSizedBox(10, 5),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xfff4f5f9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter your Email';
                            } else if (!isValidEmail(value.trim())) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                          controller: emailController,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                          ),
                        ),
                      ),
                      dynamicSizedBox(10, 5),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xfff4f5f9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter your Password';
                            }
                            return null;
                          },
                          controller: passwordController,
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
                      dynamicSizedBox(20, 20),
                      screenWidth > 350
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                  '---------------------------Or signup with--------------------------'),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                  '---------------------Or signup with--------------------'),
                            ),
                      dynamicSizedBox(30, 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all()),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  fixedSize: const Size(155, 50),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Image(
                                      image: AssetImage(
                                        'images/google.png',
                                      ),
                                      height: 20,
                                    ),
                                    Text(
                                      'Google',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(50)),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  fixedSize: const Size(155, 50),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.facebook_outlined,
                                      color: Colors.blue,
                                    ),
                                    Text(
                                      'Facebook',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      dynamicSizedBox(30, 10),
                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              name = nameController.text;
                              email = emailController.text;
                              password = passwordController.text;
                            });
                          }
                          registration();
                        },
                        child: Center(
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.8,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'SIGN UP',
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
                      dynamicSizedBox(40, 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: screenHeight > 700 ? 15 : 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.w500,
                                fontSize: screenHeight > 700 ? 15 : 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
