import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

// ignore: must_be_immutable
class ProductEditPage extends StatefulWidget {
  String productId, categoryName, name, detail, price, image;

  ProductEditPage({
    super.key,
    required this.productId,
    required this.categoryName,
    required this.name,
    required this.detail,
    required this.price,
    required this.image,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prepopulate the fields with the current product details
    nameController.text = widget.name;
    detailController.text = widget.detail;
    priceController.text = widget.price;
  }

  Future<void> getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    } else {
      // Show a message to the user if no image is selected
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please select an image.'),
        ),
      );
    }
  }

  // Function to handle product editing
  void editProduct() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updatedProduct = {
        'Name': nameController.text,
        'Detail': detailController.text,
        'Price': priceController.text,
        // 'Image': selectedImage != null ? selectedImage!.path : widget.image, // Placeholder for the current image if not updated
      };

      if (selectedImage != null) {
        // If an image is selected, upload it to Firebase Storage and get the URL
        String addId = randomAlphaNumeric(10);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('productImages').child(addId);

        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        var downloadUrl = await (await task).ref.getDownloadURL();
        updatedProduct['Image'] =
            downloadUrl; // Add the image URL to the updated product map
      } else {
        updatedProduct['Image'] = widget
            .image; // Use the existing image URL if no new image is selected
      }

      // Call the database method to update product
      await DatabaseMethods()
          .editProduct(widget.productId, widget.categoryName, updatedProduct);

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Product updated successfully.'),
        ),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Navigate back after updating
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Product Details',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: screenHeight > 700 ? 18 : 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Product Image
                selectedImage == null
                    ? GestureDetector(
                        onTap: getImage,
                        child: Center(
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Product Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xffececf8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black38)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Product Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xffececf8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    controller: priceController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                        labelText: 'Price',
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black38)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Product Detail
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xffececf8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    controller: detailController,
                    cursorColor: Colors.black,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        labelText: 'Product Detail',
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black38)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product detail';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Update Button
                GestureDetector(
                  onTap: editProduct,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Update Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight > 700 ? 20 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
