import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/constant.dart';
import 'package:ecom_app/services/database.dart';
import 'package:ecom_app/services/shared_pref.dart';
import 'package:ecom_app/widgets/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ProductDetailPage extends StatefulWidget {
  String image, name, detail, price, iD;
  ProductDetailPage({
    super.key,
    required this.detail,
    required this.iD,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? userName, email, image;
  fetchUserDetails() async {
    DatabaseMethods databaseMethods = DatabaseMethods();
    DocumentSnapshot userDetails =
        await databaseMethods.getUserDetails(widget.iD);

    if (userDetails.exists) {
      Map<String, dynamic>? data = userDetails.data() as Map<String, dynamic>?;
      // Update the state with user details
      setState(() {
        userName = data?['Name'] ?? 'User';
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

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffef5f1),
      appBar: AppBar(
        backgroundColor: const Color(0xfffef5f1),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.image,
                height: MediaQuery.of(context).size.height * 0.45,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: AppWidget.boldTextFieldStyle(),
                      ),
                      Text(
                        '\$${widget.price}',
                        style: const TextStyle(
                          color: Color(0xfffd6f3e),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Details',
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.detail),
                  SizedBox(
                    height: screenHeight > 700 ? screenHeight / 8.8 : 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      makePayment(widget.price);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xfffd6f3e),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: Text(
                          'Buy Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight > 700 ? 10 : 5,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent?['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Ahsan'))
          .then((value) {});
      displayPaymentSheet();
    } catch (e, s) {
      // ignore: avoid_print
      print('Execption: $e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        Map<String, dynamic> orderInfoMap = {
          'Product': widget.name,
          'Price': widget.price,
          'Name': userName,
          'Email': email,
          'Image': image,
          'ProductImage': widget.image,
          'Status': 'On the way',
        };
        await DatabaseMethods().orderDetails(orderInfoMap);
        showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text('Payment Successful'),
                        ],
                      )
                    ],
                  ),
                ));
        paymentIntent = null;
      }).onError((error, stackTrace) {
        // ignore: avoid_print
        print('Error is :--> $error $stackTrace');
      });
    } on StripeException catch (e) {
      // ignore: avoid_print
      print('Error is :---> $e');
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (_) => const AlertDialog(
                content: Text('Cancelled'),
              ));
    } catch (e) {
      // ignore: avoid_print
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var responce = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content_Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return jsonDecode(responce.body);
    } catch (err) {
      // ignore: avoid_print
      print('Error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount) * 100);
    return calculatedAmount.toString();
  }
}
