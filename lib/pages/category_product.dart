import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/pages/product_detail_page.dart';
import 'package:ecom_app/services/database.dart';
import 'package:ecom_app/widgets/support_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CategoryProduct extends StatefulWidget {
  String category, iD;
  CategoryProduct({super.key, required this.category, required this.iD});

  @override
  State<CategoryProduct> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  // ignore: non_constant_identifier_names
  Stream? CategoryStream;

  getontheload() async {
    CategoryStream = await DatabaseMethods().getProducts(widget.category);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allProducts() {
    final screenHeight = MediaQuery.of(context).size.height;

    Widget dynamicSizedBox(double largeHeight, double smallHeight) {
      return screenHeight > 700
          ? SizedBox(height: largeHeight)
          : SizedBox(height: smallHeight);
    }

    return StreamBuilder(
        stream: CategoryStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          dynamicSizedBox(10, 5),
                          Image.network(
                            ds['Image'],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          dynamicSizedBox(5, 2),
                          Text(
                            ds['Name'],
                            style: AppWidget.semiBoldTextFieldStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                // ignore: prefer_interpolation_to_compose_strings
                                '\$' + ds['Price'],
                                style: const TextStyle(
                                    color: Color(0xfffd6f3e),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: ds['Price'].length > 3 ? 20 : 36,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        detail: ds['Detail'],
                                        image: ds['Image'],
                                        name: ds['Name'],
                                        price: ds['Price'],
                                        iD: widget.iD,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfffd6f3e),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        // padding: EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Expanded(
              child: allProducts(),
            ),
          ],
        ),
      ),
    );
  }
}
