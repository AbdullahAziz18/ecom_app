import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/admin/edit_product_page.dart';
import 'package:ecom_app/services/database.dart';
import 'package:ecom_app/widgets/support_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DeleteProductPage extends StatefulWidget {
  String category;
  DeleteProductPage({super.key, required this.category});

  @override
  State<DeleteProductPage> createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
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

  // Function to show the confirmation dialog
  void showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
          content: const Text(
            "Do you want to delete this product?",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                deleteProduct(productId);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text(
                "Yes",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a product by its ID
  void deleteProduct(String productId) async {
    await DatabaseMethods().deleteProduct(productId, widget.category);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Product deleted successfully.',
          style: TextStyle(
            // ignore: use_build_context_synchronously
            fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
          ),
        ),
      ),
    );
    getontheload(); // Refresh the list after deletion
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

                  return GestureDetector(
                    onTap: () {
                      // Navigate to the ProductEditPage when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductEditPage(
                            productId: ds.id,
                            categoryName: widget.category,
                            name: ds['Name'],
                            detail: ds['Detail'],
                            image: ds['Image'],
                            price: ds['Price'],
                          ),
                        ),
                      );
                    },
                    child: Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${ds['Price']}',
                                style: const TextStyle(
                                    color: Color(0xfffd6f3e),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              // Delete product button
                              GestureDetector(
                                onTap: () {
                                  showDeleteDialog(ds
                                      .id); // Show the delete confirmation dialog
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                })
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text('Delete Products'),
        backgroundColor: const Color(0xfff2f2f2),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Expanded(
              child: allProducts(),
            ),
            const Text('Tap on the product to edit it\'s details.')
          ],
        ),
      ),
    );
  }
}
