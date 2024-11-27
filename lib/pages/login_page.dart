import 'package:ecom_app/pages/bottom_navigation.dart';
import 'package:ecom_app/pages/signup_page.dart';
import 'package:ecom_app/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '', password = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    // Trimming the inputs
    email = emailController.text.trim();
    password = passwordController.text.trim();
    await SharedPreferenceHelper().saveUserEmail(email);

    if (_formkey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Logged In Successfully.',
              style: TextStyle(
                // ignore: use_build_context_synchronously
                fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
              ),
            ),
          ),
        );
        await SharedPreferenceHelper().saveLoginState();
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigation(
              id: email,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = '';

        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Invalid password provided.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format.';
        } else {
          errorMessage = 'An error occurred. Check your Email and Password.';
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              errorMessage,
              style: TextStyle(
                // ignore: use_build_context_synchronously
                fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
              ),
            ),
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'An unexpected error occurred. Check your Email and Password.',
              style: TextStyle(
                // ignore: use_build_context_synchronously
                fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
              ),
            ),
          ),
        );
      }
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
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.only(top: 10),
                height: screenHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Log In',
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
                      dynamicSizedBox(50, 25),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xfff4f5f9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          validator: (value) {
                            // Email validation with regex
                            String pattern =
                                r'^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                            RegExp regex = RegExp(pattern);
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!regex.hasMatch(value.trim())) {
                              return 'Enter a valid email address';
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
                                  '---------------------------Or login with---------------------------'),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                  '---------------------Or login with---------------------'),
                            ),
                      dynamicSizedBox(60, 40),
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
                      dynamicSizedBox(50, 40),
                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            userLogin();
                          }
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
                      dynamicSizedBox(40, 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
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
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
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
