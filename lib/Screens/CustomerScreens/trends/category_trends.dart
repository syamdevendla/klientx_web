//*************   © Copyrighted by aagama_it. 

// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Screens/CustomerScreens/trends/customer_trends.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Utils/utils.dart';
import '../../../widgets/OtherCustomWidgets/page_navigator.dart';
import 'category_details.dart';

class CategoryTrends extends StatefulWidget {
  late List<dynamic>? categoryList;
  late List<dynamic>? wishList;
  final String? currentUserID;
  CategoryTrends(
      {Key? key,
      @required this.categoryList,
      @required this.wishList,
      this.currentUserID})
      : super(key: key);

  // CategoryTrends({required this.categoryName});

  @override
  State createState() => new CategoryTrendsState();
}

class CategoryTrendsState extends State<CategoryTrends>
    with TickerProviderStateMixin {
  CarouselController buttonCarouselController = CarouselController();
  late List<dynamic> _catList = [];
  late List<dynamic> _wishList = [];
  late List<dynamic> newList = [];
  late bool isloading = true;
  var categoryData;
  @override
  void initState() {
    super.initState();
    this.isloading = true;
    this._catList = widget.categoryList!;
    this._wishList = widget.wishList!;
    newList = [];
    this._catList.forEach((element1) {
      if (this._wishList.length > 0) {
        this._wishList.forEach((element) {
          int index = newList.indexWhere(
              (existingOrder) => existingOrder["id"] == element1.id);
          if (index == -1) {
            if (element['subCatId'] == element1.id) {
              newList.add({
                "image": element1.data()['image'],
                "categoryName": element1.data()['categoryName'],
                "id": element1.id,
                "wishList": (element['status'] == 1) ? true : false
              });
            } else {
              newList.add({
                "image": element1.data()['image'],
                "categoryName": element1.data()['categoryName'],
                "id": element1.id,
                "wishList": false
              });
            }
          } else {
            if (element['subCatId'] == newList[index]["id"]) {
              newList[index] = {
                "image": element1.data()['image'],
                "categoryName": element1.data()['categoryName'],
                "id": element1.id,
                "wishList": true
              };
            } else {
              newList[index] = {
                "image": element1.data()['image'],
                "categoryName": element1.data()['categoryName'],
                "id": element1.id,
                "wishList": (newList[index]["wishList"]) ? true : false
              };
            }
          }
          print(newList);
          // newList.forEach((elementNew) {
          //   if (element['subCatId'] == elementNew.id) {
          //     newList.add({
          //       "image": element1.data()['image'],
          //       "categoryName": element1.data()['categoryName'],
          //       "id": element1.id,
          //       "wishList": true
          //     });
          //   }
          // });
          //     if (element['subCatId'] == element1.id) {
          // } else {
          //   int index = newList.indexWhere(
          //       (existingOrder) => existingOrder["id"] == element1.id);
          //   if (index == -1)
          //     newList.add({
          //       "image": element1.data()['image'],
          //       "categoryName": element1.data()['categoryName'],
          //       "id": element1.id,
          //       "wishList": false
          //     });
          //   else {
          //     newList[index] = {
          //       "image": element1.data()['image'],
          //       "categoryName": element1.data()['categoryName'],
          //       "id": element1.id,
          //       "wishList": false
          //     };
          //   }
          //   // newList.add({
          //   //   "image": element1.data()['image'],
          //   //   "categoryName": element1.data()['categoryName'],
          //   //   "id": element1.id,
          //   //   "wishList": false
          //   // });
          // }
        });
      } else {
        newList.add({
          "image": element1.data()['image'],
          "categoryName": element1.data()['categoryName'],
          "id": element1.id,
          "wishList": false
        });
      }
    });
    // print(newList);
    //loadWishList();
    // await FirebaseFirestore.instance
    //     .collection('wishList')
    //     .where("userID", isEqualTo: widget.currentUserID)
    //     .get()
    //     .then((wishList) async {
    //   // if (wishList.docs.length != 0) {
    //   //   this._wishList = wishList.docs.toList();
    //   // }
    // });
    // loadAndListenOrgs(widget.categoryName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadWishList() async {
    await FirebaseFirestore.instance
        .collection('wishList')
        .where("userID", isEqualTo: widget.currentUserID)
        .get()
        .then((wishList) async {
      if (wishList.docs.length != 0) {
        this._wishList = wishList.docs.toList();
        this._wishList.forEach((element) {
          this._catList.forEach((element1) {
            if (element['subCatId'] == element1.id && element['status'] == 1) {
              element1['wishList'] = true;
            } else {
              element1['wishList'] = false;
            }
          });
        });
        print(this._catList);
        //this.isloading = false;
      }
    });
  }

  // loadAndListenOrgs(categoryName) async {
  //   await FirebaseFirestore.instance
  //       .collection('advertisement')
  //       .where('category', isEqualTo: categoryName)
  //       .get()
  //       .then((orgs) async {
  //     if (orgs.docs.length != 0) {
  //       this._catList = orgs.docs.toList();
  //       //this.isloading = false;
  //     }
  //   });
  // }
  handleListTap(context, String subCatId) async {
    // var mysubCatId = int.parse(subCatId);
    // assert(mysubCatId is int);
    // print(mysubCatId);
    print(widget.currentUserID);

    await FirebaseFirestore.instance
        .collection('wishList')
        .where("subCatId", isEqualTo: subCatId)
        .where("userID", isEqualTo: widget.currentUserID)
        .get()
        .then((list) async {
      DateTime today = DateTime.now();
      String dateStr = "${today.day}-${today.month}-${today.year}";
      if (list.docs.length >= 1) {
        await FirebaseFirestore.instance
            .collection('wishList')
            .doc(list.docs[0].id)
            .set({"status": (list.docs[0].data()['status'] == 1) ? 0 : 1},
                SetOptions(merge: true));
      } else {
        int index = newList
            .indexWhere((existingOrder) => existingOrder["id"] == subCatId);
        if (newList[index]["wishList"]) {
          newList[index] = {
            "image": newList[index]['image'],
            "categoryName": newList[index]['categoryName'],
            "id": newList[index]["id"],
            "wishList": false
          };
        } else {
          newList[index] = {
            "image": newList[index]['image'],
            "categoryName": newList[index]['categoryName'],
            "id": newList[index]["id"],
            "wishList": true
          };
        }

        CollectionReference wishList =
            FirebaseFirestore.instance.collection('wishList');

        wishList.add({
          "subCatId": subCatId,
          "userID": widget.currentUserID,
          "addedon": dateStr,
          "status": 1
        });
        try {
          //Navigator.of(context).pop();
          //setState(() => newList.addAll(newList));
          // pageNavigator(
          //   this.context,
          //   CustomerTrends(
          //     currentUserID: widget.currentUserID,
          //   ),
          // );
        } catch (e) {
          print("Error: $e");
        }
        Navigator.of(context).pop();
        //Navigator.of(context).pop();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) =>  CustomerTrends(
        //               currentUserID: widget.currentUserID,
        //             ),),
        // );

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //var catName = widget.categoryName;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'List',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          // body: SingleChildScrollView(
          //   child: Stack(
          //     children: [
          //       BodyLayout(),
          //     ],
          //   ),
          // ),
          //body: BodyLayout(),
          body: newList.length == 0
              ? Center(
                  child: circularProgress(),
                )
              : ListView.separated(
                  itemCount:
                      newList.length, // Set the number of items in the list
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(), // Add a divider between each item in the list
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () =>
                            handleListTap(context, newList[index]["id"]),
                        child: ListTile(
                          leading: SizedBox(
                              height: Get.height / 5,
                              width: Get.width / 3, // fixed width and height
                              child: Image.asset(
                                  'assets/images/' + newList[index]['image'])),
                          //Image.network(
                          //_catList[index].data()['mainBanner']),

                          //  NetworkImage(_catList[index].data()[
                          //     'mainBanner']), // Display the image on the left side of the ListTile
                          title: Text(newList[index]['categoryName']),
                          trailing: Icon(
                            Icons.favorite_rounded,
                            color: (newList[index]['wishList'] == true)
                                ? Colors.pink
                                : Colors.grey,
                          ),
                          // trailing:
                          //     Icon(Icons.favorite_rounded, color: Colors.pink),
                          // subtitle: Column(
                          //   children: <Widget>[
                          //     Text('inside column'),
                          //     FlatButton(
                          //         child: Text('button'), onPressed: () {})
                          //   ],
                          // ), // Display the name as the title of the ListTile
                          // subtitle: Text(_catList[index][
                          //     'name']), // Display the description as the subtitle of the ListTile
                        ));
                  })
          // ListView.builder(
          //     itemCount: _catList.length,
          //     // prototypeItem: ListTile(
          //     //   title: Text(_catList[index]['name']),
          //     // ),
          //     // itemBuilder: (context, index) {
          //     //   return ListTile(
          //     //     title: Text(_catList[index].data()['name']),
          //     //   );
          //     // },
          //     itemBuilder: (BuildContext context, int index) {
          //       return InkWell(
          //         //onTap: () => _catList([index]),
          //         child: Container(
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(
          //                   10), // <= No more error here :)
          //               color: Colors.white,
          //               border: Border.all(color: Colors.black),
          //               image: DecorationImage(
          //                   image: NetworkImage(
          //                       _catList[index].data()['mainBanner']),
          //                   fit: BoxFit.fill)),
          //           height: 100,
          //           margin: EdgeInsets.all(10),
          //           padding: EdgeInsets.all(15),
          //           child: Text(_catList[index].data()['name']),
          //         ),
          //         // child: Container(
          //         //   color: Colors.blue,
          //         //   margin: EdgeInsets.all(10),
          //         //   padding: EdgeInsets.all(15),
          //         //   alignment: Alignment.center,
          //         //   child: Text(
          //         //     _catList[index].data()['name'],
          //         //     style: TextStyle(
          //         //       color: Colors.white,
          //         //       fontSize: 22,
          //         //     ),
          //         //   ),
          //         // ),
          //       );
          //     }),
          ),
    );
  }
}

class Category extends StatelessWidget {
  final String catName;

  Category({Key? key, required this.catName}) : super(key: key);
  handleCategoryTap(String category) {
    print(category);
    //pageNavigator(PasscodeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        new GestureDetector(
            onTap: () => handleCategoryTap(catName),
            // onTap: () {
            //   print("Container clicked");
            // },
            child: Container(
              height: Get.height / 9,
              width: Get.width / 4.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                    image: AssetImage('assets/images/' + catName + '.jpg'),
                    fit: BoxFit.fill),
              ),
              // child: Image.asset('assets/slides/slide1.jpg',
              //     fit: BoxFit.fill),
            )),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            catName,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class FlashSell extends StatelessWidget {
  FlashSell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width / 1.5,
      height: Get.height / 8,
      child: Row(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                  image: AssetImage('assets/images/Travel.jpg'),
                  fit: BoxFit.fill),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 6.0, right: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Container(
                        height: 15,
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 9,
                            offset: Offset(1, 1),
                          )
                        ]),
                        child: Center(
                            child: Text('09',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Container(
                        height: 15,
                        // width: 15,
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 9,
                            offset: Offset(1, 1),
                          )
                        ]),
                        child: Center(
                            child: Text('12',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Container(
                        height: 15,
                        // width: 15,
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 9,
                            offset: Offset(1, 1),
                          )
                        ]),
                        child: Center(
                            child: Text('25',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // child: Image.asset('assets/slides/slide1.jpg',
            //     fit: BoxFit.fill),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exhaust Flex Pipe',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tube Light',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Text(
                  "10.25 USD",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 8),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                              // color: Colors.blue.shade300,
                              // borderRadius: BorderRadius.circular(5),
                              ),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Color(0xff804040),
                                inactiveTrackColor: Colors.blue.shade100,
                                overlayColor: Colors.pink.withOpacity(0.2),
                                trackHeight: 8,
                                // trackShape:RoundedRectSliderTrackShape(),
                                trackShape: RectangularSliderTrackShape(),
                                thumbShape: SliderComponentShape.noThumb,
                                overlayShape: SliderComponentShape.noOverlay),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: 30,
                              onChanged: null,
                              activeColor: Colors.blue,
                              inactiveColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      Text('120 sold',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text('on stock 160',
                    style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SliderImage extends StatelessWidget {
  final List orgList;

  // var img1 = null;
  // var img2 = null;
  // var img3 = null;
  // var img4 = null;
  // var img5 = null;
  // var img6 = null;
  // var img7 = null;
  // var img8 = null;
  // var img9 = null;
  // var img10 = null;
  var imageArray = [];

  SliderImage(this.orgList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> imageList = [];
    List<dynamic> urls = [];
    for (var org in orgList) {
      imageList.add(org.data()['mainBanner']);
      urls.add(org.data()['url']);
    }

    Future<void> handleImageTap(int index) async {
      String url = urls[index];
      final Uri _uri = Uri.parse(url);
      // ignore: deprecated_member_use
      var urllaunchable =
          // ignore: deprecated_member_use
          await canLaunchUrl(_uri); //canLaunch is from url_launcher package
      if (urllaunchable) {
        // ignore: deprecated_member_use
        await launchUrl(
            _uri); //launch is from url_launcher package to launch URL
      } else {
        print("URL can't be launched.");
      }
    }

    return Container(
        height: Get.height / 3.5,
        // decoration: BoxDecoration(
        // image: DecorationImage(
        //     image: AssetImage('assets/images/bgshop.jpg'),
        //     fit: BoxFit.fill)),
        child: CarouselSlider(
            // items:
            // items: imageList.map((String imageUrl) {
            //   return Builder(
            //     builder: (BuildContext context) {
            //       return Container(
            //         width: MediaQuery.of(context).size.width,
            //         margin: EdgeInsets.symmetric(horizontal: 5.0),
            //         child: Image.network(imageUrl,
            //             fit: BoxFit.fill, width: Get.width),
            //       );
            //     },
            //   );
            // }).toList(),
            items: imageList.asMap().entries.map((entry) {
              final index = entry.key;
              final imageUrl = entry.value;
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () => handleImageTap(index),
                    child: Container(
                      //width: MediaQuery.of(context).size.width,
                      // margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.fill,
                        width: Get.width,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            // [
            //   orgList.forEach((n) => print(
            //         Image.network('${n}', fit: BoxFit.fill, width: Get.width),
            //       ))
            //   // for (var n in orgList) {
            //   //   print(Image.network('${n}, fit: BoxFit.fill, width: Get.width),'));
            //   // }
            //   //  orgList.forEachIndexed(
            //   //   (e, i) =>
            //   //       return Image.network('$e', fit: BoxFit.fill, width: Get.width),
            //   // )
            // ],
            // [
            //   Image.asset('assets/slides/slide1.jpg',
            //       fit: BoxFit.fill, width: Get.width),
            //   Image.asset('assets/slides/slide2.jpg',
            //       fit: BoxFit.fill, width: Get.width),
            //   Image.asset('assets/slides/slide3.jpg',
            //       fit: BoxFit.fill, width: Get.width),
            // ],
            options: CarouselOptions(
              height: 400,
              aspectRatio: 16 / 9,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false,
              //enlargeFactor: 0.3,
              // onPageChanged: callbackFunction,
              scrollDirection: Axis.horizontal,
            )));
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _myListView(context);
  }
}

Widget _myListView(BuildContext context) {
  final titles = [
    'bike',
    'boat',
    'bus',
    'car',
    'railway',
    'run',
    'subway',
    'transit',
    'walk',
    'Test',
    'Test1',
    'Test2',
    'Test3',
    'Test4',
    'Test5',
    'Test6',
    'Test7',
    'Test8',
    'Test9',
    'Test10'
  ];

  final icons = [
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.directions_bus,
    Icons.directions_car,
    Icons.directions_railway,
    Icons.directions_run,
    Icons.directions_subway,
    Icons.directions_transit,
    Icons.directions_walk
  ];

  return ListView.builder(
    itemCount: titles.length,
    itemBuilder: (context, index) {
      return Card(
        //                           <-- Card widget
        child: ListTile(
          leading: Icon(icons[index]),
          title: Text(titles[index]),
        ),
      );
    },
  );
}

Container circularProgress() {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Mycolors.loadingindicator),
      ));
}
