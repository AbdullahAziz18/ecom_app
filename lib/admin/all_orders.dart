import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/database.dart';
import 'package:flutter/material.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  Stream? orderStream;
  getontheload() async {
    orderStream = await DatabaseMethods().allOrders();
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
                              left: 20, top: 10, bottom: 10, right: 10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    ds['Image'],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name:  ${ds['Name']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenHeight > 700 ? 18 : 13,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      'Email:  ${ds['Email']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenHeight > 700 ? 15 : 10,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
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
                                      fontSize: screenHeight > 700 ? 18 : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      await DatabaseMethods()
                                          .updateStatus(ds.id);
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      width: 150,
                                      decoration: BoxDecoration(
                                          color: const Color(0xfffd6f3e),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: Text(
                                          'Done',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                screenHeight > 700 ? 18 : 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        title: Text(
          'All Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenHeight > 700 ? 30 : 22.5,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Expanded(
              child: allOrders(),
            )
          ],
        ),
      ),
    );
  }
}
