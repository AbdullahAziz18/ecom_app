import 'dart:async';
import 'dart:io';
import 'package:ecom_app/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  bool isLoading = false; // Loading state tracker
  final int maxSizeInBytes = 5 * 1024 * 1024;
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      int imageSize = await imageFile.length();
      if (imageSize > maxSizeInBytes) {
        // Show error message if the image size exceeds the limit
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Image size exceeds the 5MB limit. Please select a smaller image.',
              style: TextStyle(fontSize: 15),
            ),
          ),
        );
      } else {
        selectedImage = imageFile;
        setState(() {}); // Update UI with the selected image
      }
    } else {
      // Image is not selected, show a message to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please select an image.',
            style: TextStyle(
              // ignore: use_build_context_synchronously
              fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
            ),
          ),
        ),
      );
    }
  }

  uploadItem() async {
    if (selectedImage != null &&
        nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        detailController.text.isNotEmpty &&
        value != null) {
      setState(() {
        isLoading = true; // Start loading
      });

      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('blogImage').child(addId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();
      String firstLetter = nameController.text.substring(0, 1).toUpperCase();
      Map<String, dynamic> addProduct = {
        'Name': nameController.text,
        'Image': downloadUrl,
        'SearchKey': firstLetter,
        'UpdatedName': nameController.text.toUpperCase(),
        'Price': priceController.text,
        'Detail': detailController.text,
        'Category': value,
      };

      await DatabaseMethods().addProduct(addProduct, value!).then((_) async {
        await DatabaseMethods().addAllProducts(addProduct);
        setState(() {
          isLoading = false; // Stop loading
          selectedImage = null;
          nameController.clear();
          priceController.clear();
          detailController.clear();
          value = null; // Clear selected category
        });

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Product added successfully.',
              style: TextStyle(
                // ignore: use_build_context_synchronously
                fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
              ),
            ),
          ),
        );
      }).catchError((error) {
        // Handle errors and stop the loader in case of failure
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to add product. Please try again.',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
              ),
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please fill in all fields and select an image.',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height > 700 ? 20 : 15,
            ),
          ),
        ),
      );
    }
  }

  String? value;
  final List<String> category = ['Headphones', 'Laptop', 'Watch', 'TV'];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    Widget dynamicSizedBox(double largeHeight, double smallHeight) {
      return screenHeight > 700
          ? SizedBox(height: largeHeight)
          : SizedBox(height: smallHeight);
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
        title: Text(
          'Add Product',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenHeight > 700 ? 20 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ), // Show loader
            )
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload the Product Image',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenHeight > 700 ? 18 : 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dynamicSizedBox(20, 10),
                    selectedImage == null
                        ? GestureDetector(
                            onTap: () {
                              getImage();
                            },
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
                    dynamicSizedBox(20, 10),
                    Text(
                      'Product Name',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenHeight > 700 ? 18 : 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dynamicSizedBox(10, 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xffececf8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'e.g: Mac,Headphones',
                          hintStyle: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ),
                    dynamicSizedBox(20, 10),
                    Text(
                      'Product Price',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenHeight > 700 ? 18 : 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dynamicSizedBox(10, 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xffececf8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: priceController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'e.g: 50,40,60',
                            hintStyle: TextStyle(color: Colors.black38)),
                      ),
                    ),
                    dynamicSizedBox(20, 10),
                    Text(
                      'Product Detail',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenHeight > 700 ? 18 : 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dynamicSizedBox(10, 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xffececf8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        maxLines: 7,
                        cursorColor: Colors.black,
                        controller: detailController,
                        decoration: const InputDecoration(
                          hintText: 'e.g: About The Product.',
                          hintStyle: TextStyle(color: Colors.black38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    dynamicSizedBox(20, 10),
                    Text(
                      'Product Category',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenHeight > 700 ? 18 : 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dynamicSizedBox(10, 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xffececf8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: category
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: screenHeight > 700 ? 20 : 15,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              this.value = value;
                            });
                          },
                          dropdownColor: Colors.white,
                          hint: const Text('Select Category'),
                          iconSize: screenHeight > 700 ? 36 : 16,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                          value: value,
                        ),
                      ),
                    ),
                    dynamicSizedBox(40, 20),
                    GestureDetector(
                      onTap: () {
                        uploadItem();
                      },
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
                              'Add',
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
    );
  }
}
