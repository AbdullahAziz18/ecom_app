import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .set(userInfoMap);
  }

  // Method to retrieve user details from Firestore
  Future<DocumentSnapshot> getUserDetails(String id) async {
    return await FirebaseFirestore.instance.collection('Users').doc(id).get();
  }

  Future addAllProducts(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .add(userInfoMap);
  }

  Future addProduct(
      Map<String, dynamic> userInfoMap, String categoryName) async {
    return await FirebaseFirestore.instance
        .collection(categoryName)
        .add(userInfoMap);
  }

  updateStatus(String id) async {
    return await FirebaseFirestore.instance
        .collection('Orders')
        .doc(id)
        .update({'Status': 'Delivered'});
  }

  Future<Stream<QuerySnapshot>> getProducts(String category) async {
    // ignore: await_only_futures
    return await FirebaseFirestore.instance.collection(category).snapshots();
  }

  // Future<Stream<QuerySnapshot>> getCategories() async {
  //   return FirebaseFirestore.instance.collection('Categories').snapshots();
  // }

  Future<Stream<QuerySnapshot>> allOrders() async {
    // ignore: await_only_futures
    return await FirebaseFirestore.instance
        .collection('Orders')
        .where('Status', isEqualTo: 'On the way')
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getOrders(String email) async {
    // ignore: await_only_futures
    return await FirebaseFirestore.instance
        .collection('Orders')
        .where('Email', isEqualTo: email)
        .snapshots();
  }

  Future orderDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection('Orders')
        .add(userInfoMap);
  }

  Future<QuerySnapshot> search(String updatedName) async {
    return await FirebaseFirestore.instance
        .collection('Products')
        .where('SearchKey',
            isEqualTo: updatedName.substring(0, 1).toUpperCase())
        .get();
  }

  Future<void> deleteProduct(String productId, String categoryName) async {
    return await FirebaseFirestore.instance
        .collection(categoryName)
        .doc(productId)
        .delete();
  }

  Future<void> editProduct(String productId, String categoryName,
      Map<String, dynamic> updatedData) async {
    return await FirebaseFirestore.instance
        .collection(categoryName)
        .doc(productId)
        .update(updatedData);
  }
}
