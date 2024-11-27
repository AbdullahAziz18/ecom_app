import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/database.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CartPage extends StatefulWidget {
  String iD;
  CartPage({required this.iD, super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Stream? orderStream;
  String? email;

  fetchUserDetails() async {
    DatabaseMethods databaseMethods = DatabaseMethods();
    DocumentSnapshot userDetails =
        await databaseMethods.getUserDetails(widget.iD);
    if (userDetails.exists) {
      Map<String, dynamic>? data = userDetails.data() as Map<String, dynamic>?;
      // Update the state with user details
      setState(() {
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

  getontheload() async {
    await fetchUserDetails();
    orderStream = await DatabaseMethods().getOrders(email!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allOrders() {
    final screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
        stream: orderStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                ds['ProductImage'],
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ds['Product'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenHeight > 700 ? 18 : 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '\$${ds['Price']}',
                                      style: TextStyle(
                                        color: const Color(0xfffd6f3e),
                                        fontSize: screenHeight > 700 ? 22 : 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Status: ${ds['Status']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenHeight > 700 ? 15 : 13,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : const Center(
                  child: CircularProgressIndicator(
                  color: Colors.cyan,
                ));
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Text(
              'Current Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight > 700 ? 30 : 22.5,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: allOrders(),
            ),
          ],
        ),
      ),
    );
  }
}
