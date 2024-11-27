import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/pages/all_categories.dart';
import 'package:ecom_app/pages/category_product.dart';
import 'package:ecom_app/pages/product_detail_page.dart';
import 'package:ecom_app/services/database.dart';
import 'package:ecom_app/services/shared_pref.dart';
import 'package:ecom_app/widgets/support_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  String iD;
  HomePage({required this.iD, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool search = false;
  List categories = [
    'images/headphone_icon.png',
    'images/laptop.png',
    'images/watch.png',
    'images/TV.png'
  ];

  List categoryName = ['Headphones', 'Laptop', 'Watch', 'TV'];

  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchcontroller = TextEditingController();

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      // ignore: avoid_function_literals_in_foreach_calls
      queryResultSet.forEach((element) {
        if (element['UpdatedName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  //Is se agy wala part dobra dkhna h from 4:14:34 on youtube.
  String? name, image;
  fetchUserDetails() async {
    DatabaseMethods databaseMethods = DatabaseMethods();
    DocumentSnapshot userDetails =
        await databaseMethods.getUserDetails(widget.iD);

    if (userDetails.exists) {
      Map<String, dynamic>? data = userDetails.data() as Map<String, dynamic>?;
      // Update the state with user details
      setState(() {
        name = data?['Name'] ?? 'User';
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

  String getGreetingMessage() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: SingleChildScrollView(
        child: name == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyan,
                ),
              )
            : Container(
                margin: const EdgeInsets.only(top: 50, left: 18, right: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hey, $name',
                                  style: AppWidget.boldTextFieldStyle(),
                                ),
                                Text(
                                  getGreetingMessage(),
                                  style: AppWidget.lightTextFieldStyle(),
                                ),
                              ],
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: image == null
                                  ? Image.asset(
                                      'images/boy.jpg',
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      image!,
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: searchcontroller,
                            onChanged: (value) {
                              initiateSearch(value.toUpperCase());
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search Product',
                              hintStyle: AppWidget.lightTextFieldStyle(),
                              prefixIcon: search
                                  ? GestureDetector(
                                      onTap: () {
                                        search = false;
                                        tempSearchStore = [];
                                        queryResultSet = [];
                                        searchcontroller.text = '';
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.close),
                                    )
                                  : const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        search
                            ? ListView(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                primary: false,
                                shrinkWrap: true,
                                children: tempSearchStore.map((element) {
                                  return buildResultCard(element);
                                }).toList(),
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Categories',
                                        style:
                                            AppWidget.semiBoldTextFieldStyle(),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AllCategoriesPage(
                                                        iD: widget.iD,
                                                      )));
                                        },
                                        child: const Text(
                                          'see all',
                                          style: TextStyle(
                                              color: Color(0xfffd6f3e),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AllCategoriesPage(
                                                      iD: widget.iD,
                                                    )),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(30),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          height: 130,
                                          decoration: BoxDecoration(
                                            color: const Color(0xfffd6f3e),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'All',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 130,
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: categories.length,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return CategoryTile(
                                                image: categories[index],
                                                name: categoryName[index],
                                                iD: widget.iD,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'All Products',
                                        style:
                                            AppWidget.semiBoldTextFieldStyle(),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AllCategoriesPage(
                                                iD: widget.iD,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'see all',
                                          style: TextStyle(
                                              color: Color(0xfffd6f3e),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // ignore: sized_box_for_whitespace
                                  Container(
                                    height: 240,
                                    child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'images/headphone2.png',
                                                height: 150,
                                                width: 150,
                                                fit: BoxFit.cover,
                                              ),
                                              Text(
                                                'HeadPhone',
                                                style: AppWidget
                                                    .semiBoldTextFieldStyle(),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              const Text(
                                                '\$100',
                                                style: TextStyle(
                                                    color: Color(0xfffd6f3e),
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'images/watch2.png',
                                                height: 150,
                                                width: 150,
                                                fit: BoxFit.cover,
                                              ),
                                              Text(
                                                'Apple Watch',
                                                style: AppWidget
                                                    .semiBoldTextFieldStyle(),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              const Text(
                                                '\$300',
                                                style: TextStyle(
                                                    color: Color(0xfffd6f3e),
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'images/laptop2.png',
                                                height: 150,
                                                width: 150,
                                                fit: BoxFit.cover,
                                              ),
                                              Text(
                                                'Laptop',
                                                style: AppWidget
                                                    .semiBoldTextFieldStyle(),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              const Text(
                                                '\$1000',
                                                style: TextStyle(
                                                    color: Color(0xfffd6f3e),
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                      'Note: Before placing an order kindly add a Profile Picture.')
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                      detail: data['Detail'],
                      image: data['Image'],
                      name: data['Name'],
                      price: data['Price'],
                      iD: widget.iD,
                    )));
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data['Image'],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              data['Name'],
              style: AppWidget.semiBoldTextFieldStyle(),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CategoryTile extends StatelessWidget {
  String image, name, iD;
  // ignore: use_key_in_widget_constructors
  CategoryTile({required this.image, required this.name, required this.iD});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProduct(
              category: name,
              iD: iD,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 90,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              image,
              height: 70,
              width: 60,
              fit: BoxFit.cover,
            ),
            Center(
              child: Text(
                name,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
              ),
            )
          ],
        ),
      ),
    );
  }
}
