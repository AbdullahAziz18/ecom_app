import 'package:flutter/material.dart';
import 'package:ecom_app/pages/category_product.dart';

// ignore: must_be_immutable
class AllCategoriesPage extends StatefulWidget {
  String iD;
  AllCategoriesPage({super.key, required this.iD});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  List categories = [
    'images/headphone_icon.png',
    'images/laptop.png',
    'images/watch.png',
    'images/TV.png'
  ];

  List categoryName = ['Headphones', 'Laptop', 'Watch', 'TV'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text('All Categories'),
        centerTitle: true,
        backgroundColor: const Color(0xfff2f2f2),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two items per row
            crossAxisSpacing: 10, // Spacing between items horizontally
            mainAxisSpacing: 10, // Spacing between items vertically
            childAspectRatio: 0.8, // Aspect ratio to adjust item shape
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProduct(
                      category: categoryName[index],
                      iD: widget.iD, // Pass the category name
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        categories[index], // Category image from the list
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        categoryName[index], // Category name from the list
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
