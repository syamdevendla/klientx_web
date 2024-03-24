//*************   © Copyrighted by aagama_it. 

// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Configs/my_colors.dart';
import '../../../widgets/OtherCustomWidgets/mycustomtext.dart';
import 'category_trends.dart';
import 'dart:convert';
import 'package:aagama_it/Utils/utils.dart';

// class CustomerTrends extends StatefulWidget {
//   const CustomerTrends({Key? key}) : super(key: key);

//   @override
//   State createState() => new CustomerTrendsState();
// }

class CustomerTrends extends StatefulWidget {
  CustomerTrends({required this.currentUserID, key}) : super(key: key);
  final String? currentUserID;

  @override
  State createState() => new CustomerTrendsState();
}

class CustomerTrendsState extends State<CustomerTrends>
    with TickerProviderStateMixin {
  CarouselController buttonCarouselController = CarouselController();
  late List<dynamic> _orgList;
  late List<dynamic> _catList;
  late List<dynamic> _trendsList;
  late List<String> _imageUrls;
  late TabController _tabController;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);

    _tabController.addListener(_handleTabSelection);
    loadAndListenOrgs();
    loadCategories();
    loadTrends();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          this.selectedIndex = 0;
          showTabsData(this.selectedIndex);
          break;
        case 1:
          this.selectedIndex = 1;
          showTabsData(this.selectedIndex);
          break;
        case 2:
          this.selectedIndex = 3;
          showTabsData(this.selectedIndex);
          break;
      }
    }
  }

  loadAndListenOrgs() async {
    await FirebaseFirestore.instance
        .collection('advertisement')
        .get()
        .then((orgs) async {
      if (orgs.docs.length != 0) {
        this._orgList = orgs.docs.toList();
      }
    });
  }

  loadCategories() async {
    await FirebaseFirestore.instance
        .collection('categories')
        .where('parent', isEqualTo: 0)
        .get()
        .then((categories) async {
      if (categories.docs.length != 0) {
        this._catList = categories.docs.toList();
      }
    });
  }

  loadTrends() async {
    await FirebaseFirestore.instance
        .collection('advertisement')
        .get()
        .then((trends) async {
      if (trends.docs.length != 0) {
        this._trendsList = trends.docs.toList();
      }
    });
  }

  showData(index) {
    if (index == 0) {
      return Container(
          margin: EdgeInsets.only(top: 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text("This is trends")]));
    } else if (index == 1) {
      return Container(
          margin: EdgeInsets.only(top: 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text("This is wishlist")]));
    } else if (index == 2) {
      return Container(
          margin: EdgeInsets.only(top: 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text("This is adds")]));
    }
  }

  TabBar _getTabBar() {
    return TabBar(
      tabs: <Widget>[
        Tab(
            icon: MtCustomfontBold(
          isNullColor: true,
          text: getTranslatedForCurrentUser(this.context, 'xxwishlistxx'),
          fontsize: 16,
        )),
        Tab(
            icon: MtCustomfontBold(
          isNullColor: true,
          text: getTranslatedForCurrentUser(this.context, 'xxtrendsxx'),
          fontsize: 16,
        )),
        Tab(
            icon: MtCustomfontBold(
          isNullColor: true,
          text: getTranslatedForCurrentUser(this.context, 'xxcategoriesxx'),
          fontsize: 16,
        )),
      ],
      controller: _tabController,
    );
  }

  TabBarView _getTabBarView(tabs) {
    return TabBarView(
      children: tabs,
      controller: _tabController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  ///slider
                  SliderImage(this._orgList),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      _getTabBar(),
                      Container(
                        //height: 300,
                        height: Get.height / 1.3,
                        child: _getTabBarView(
                          <Widget>[
                            Container(
                                child: Stack(
                              children: [
                                WishListPage(
                                    currentUserID: widget.currentUserID)
                              ],
                            )),
                            Container(
                                child: Stack(
                              //children: [TrendsListPage()],
                              children: [TrendsList(this._orgList)],
                            )),

                            Container(
                                child: Stack(children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, left: 8, right: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Popular Categories',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 8.0, right: 1),
                                        child: Row(
                                          children: [
                                            Text(
                                              'See all',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color:
                                                        Colors.blue.shade700),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 12,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 60.0, right: 8, left: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Category(
                                        catName: _catList[0].data(),
                                        catId: _catList[0].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[1].data(),
                                        catId: _catList[1].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[2].data(),
                                        catId: _catList[2].id,
                                        currentUserID: widget.currentUserID),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 180.0, right: 8, left: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Category(
                                        catName: _catList[3].data(),
                                        catId: _catList[3].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[4].data(),
                                        catId: _catList[4].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[5].data(),
                                        catId: _catList[5].id,
                                        currentUserID: widget.currentUserID),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 300.0, right: 8, left: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Category(
                                        catName: _catList[6].data(),
                                        catId: _catList[6].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[7].data(),
                                        catId: _catList[7].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[8].data(),
                                        catId: _catList[8].id,
                                        currentUserID: widget.currentUserID),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 420.0, right: 8, left: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Category(
                                        catName: _catList[9].data(),
                                        catId: _catList[9].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[10].data(),
                                        catId: _catList[10].id,
                                        currentUserID: widget.currentUserID),
                                    Category(
                                        catName: _catList[11].data(),
                                        catId: _catList[11].id,
                                        currentUserID: widget.currentUserID),
                                  ],
                                ),
                              ),
                            ])),
                            // Container(
                            //     child: Stack(
                            //   children: [AdsPage()],
                            // )),
                          ],
                        ),
                      )
                    ],
                  ),

                  // TabBar(
                  //   isScrollable: false,
                  //   controller: _tabController,
                  //   indicatorWeight: 0.8,
                  //   unselectedLabelColor: Mycolors.blackDynamic,
                  //   tabs: [
                  //     new Tab(
                  //         icon: MtCustomfontBold(
                  //       isNullColor: true,
                  //       text: getTranslatedForCurrentUser(
                  //           this.context, 'xxtrendsxx'),
                  //       fontsize: 16,
                  //     )),
                  //     new Tab(
                  //         icon: MtCustomfontBold(
                  //       isNullColor: true,
                  //       text: getTranslatedForCurrentUser(
                  //           this.context, 'xxwishlistxx'),
                  //       fontsize: 16,
                  //     )),
                  //     new Tab(
                  //         icon: MtCustomfontBold(
                  //       isNullColor: true,
                  //       text: getTranslatedForCurrentUser(
                  //           this.context, 'xxadsxx'),
                  //       fontsize: 16,
                  //     )),
                  //   ],
                  // ),
                  // Expanded(
                  //   child: TabBarView(
                  //     children: [
                  //       Container(color: Colors.blue),
                  //       Container(color: Colors.red),
                  //       Container(color: Colors.orange),
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   child: TabBarView(
                  //     controller: _tabController,
                  //     children: [
                  //       /// Each content from each tab will have a dynamic height
                  //       (_tabController.index == 0)
                  //           ? Text("THis is Trends")
                  //           : (_tabController.index == 1)
                  //               ? Text("THis is Wishlist")
                  //               : Text("THis is Ads")
                  //     ],
                  //   ),
                  // ),
                  // TabBarView(
                  //   controller: _tabController,
                  //   children: [
                  //     Container(
                  //       color: Mycolors.backgroundcolor,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Container(
                  //               color: Colors.white,
                  //               padding:
                  //                   const EdgeInsets.fromLTRB(18, 0, 18, 8),
                  //               child: (_tabController.index == 0)
                  //                   ? Text("THis is Trends")
                  //                   : (_tabController.index == 1)
                  //                       ? Text("THis is Wishlist")
                  //                       : Text("THis is Ads")),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  //popular catagories
                  // showTabsData(_tabController.index)

                  ///flesh sale
                  //   Padding(
                  //     padding: EdgeInsets.all(10.0),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text(
                  //           'Flash Sell',
                  //           style: TextStyle(fontSize: 20),
                  //         )),
                  //   ),
                  //   SizedBox(
                  //     height: 130,
                  //     width: Get.width,
                  //     child: ListView.builder(
                  //         itemCount: 4,
                  //         shrinkWrap: true,
                  //         physics: ClampingScrollPhysics(),
                  //         scrollDirection: Axis.horizontal,
                  //         itemBuilder: (BuildContext build, value) {
                  //           return FlashSell();
                  //         }),
                  //   ),
                ],
              ),
              // Expanded(
              //   child: TabBarView(
              //     children: [
              //       Container(child: Center(child: Text('people'))),
              //       Text('Person')
              //     ],
              //     controller: _tabController,
              //   ),
              // ),

              ///bigsale top
              Padding(
                padding: EdgeInsets.only(top: 20, left: 40, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'New Arrivals',
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    // ),
                    // Text(
                    //   'BIG SALE',
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    // ),
                    // Text(
                    //   'UPTO',
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    // ),
                    // Text(
                    //   '70% OFF',
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    // ),
                    // Text(
                    //   'ON ALL MODELS',
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    //   child: Container(
                    //       width: Get.width / 3.3,
                    //       height: 40,
                    //       child: CustomButton(
                    //           label: 'BUY NOW',
                    //           colorButton: Colors.yellow,
                    //           colorLabel: Colors.black,
                    //           borderRadius: 50,
                    //           action: false)),
                    // ),
                  ],
                ),
              ),
              // Padding(
              //   padding:   EdgeInsets.only(top:20.0),
              //   child: Icon(Icons.arrow_back),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class Category extends StatelessWidget {
  final catName;

  final catId;

  var currentUserID;

  Category(
      {Key? key,
      required this.catName,
      required this.catId,
      required this.currentUserID})
      : super(key: key);
  late List<dynamic> _catList = [];
  late List<dynamic> _wishList = [];

  handleCategoryTap(context, String category) async {
    var myInt = int.parse(category);
    assert(myInt is int);
    print(myInt);
    await FirebaseFirestore.instance
        // .collection('advertisement')
        // .where('category', isEqualTo: category)
        .collection('categories')
        .where('parent', isEqualTo: myInt)
        .get()
        .then((cats) async {
      if (cats.docs.length != 0) {
        this._catList = cats.docs.toList();
        await FirebaseFirestore.instance
            .collection('wishList')
            .where("userID", isEqualTo: this.currentUserID)
            .get()
            .then((wishList) async {
          if (wishList.docs.length != 0) {
            this._wishList = wishList.docs.toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoryTrends(
                      categoryList: this._catList,
                      wishList: this._wishList,
                      currentUserID: this.currentUserID)),
            );
            print(this._catList);
            //this.isloading = false;
          } else {
            this._wishList = [];
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoryTrends(
                      categoryList: this._catList,
                      wishList: this._wishList,
                      currentUserID: this.currentUserID)),
            );
          }
        });
      } else {
        Utils.toast("not found");
      }
    });

    //print(category);
    //pageNavigator(CategoryTrends(key: null, categoryName: category));
    //Navigator.push(CategoryTrends(categoryName: category));
  }

  @override
  Widget build(BuildContext context) {
    print('assets/images/' + catName['image']);
    return Column(
      children: [
        new GestureDetector(
            onTap: () => handleCategoryTap(context, catId),
            // onTap: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               CategoryTrends(categoryName: catName)),
            //     ),
            // onTap: () {
            //   print("Container clicked");
            // },

            child: Container(
              height: Get.height / 9,
              width: Get.width / 3.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                    //image: AssetImage('assets/images/' + catName + '.png'),
                    image: AssetImage('assets/images/' + catName['image']),
                    fit: BoxFit.fill),
              ),
              // child: Image.asset('assets/slides/slide1.jpg',
              //     fit: BoxFit.fill),
            )),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            catName['categoryName'],
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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

class TrendsList extends StatelessWidget {
  final List orgList;
  var imageArray = [];

  TrendsList(this.orgList, {Key? key}) : super(key: key);

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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          children: [
            Expanded(
              child: orgList.isNotEmpty
                  ? ListView.builder(
                      itemCount: orgList.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(orgList[index].data()),
                        // color: Colors.amberAccent,
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: <Widget>[
                              Image.network(orgList[index].data()["mainBanner"],
                                  fit: BoxFit.fill, width: Get.width),
                              // Image.asset("./assets/images/" +
                              //     orgList[index]["image"] +
                              //     ".jpeg"),
                              Row(
                                children: [
                                  Text(
                                    orgList[index].data()["name"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: SizedBox(height: 10)),
                                  Text(
                                    'Category:' +
                                        orgList[index].data()["categoryName"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Valid From:' +
                                        orgList[index].data()["validfrom"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: SizedBox(height: 10)),
                                  Text(
                                    'Valid To:' +
                                        orgList[index].data()["validto"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    orgList[index].data()["subcategoryName"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    orgList[index].data()["name"],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class showTabsData extends StatelessWidget {
  final tabIndex;

  showTabsData(this.tabIndex, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height / 3.5,
        // decoration: BoxDecoration(
        // image: DecorationImage(
        //     image: AssetImage('assets/images/bgshop.jpg'),
        //     fit: BoxFit.fill)),
        child: (tabIndex == 0)
            ? Container(
                child: Stack(children: [
                //   Padding(
                //     padding: EdgeInsets.only(top: 30.0, left: 8, right: 8),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           'Popular Categories',
                //           style: TextStyle(fontSize: 17),
                //         ),
                //         Container(
                //           decoration: BoxDecoration(
                //             color: Colors.blueAccent,
                //             borderRadius: BorderRadius.circular(50),
                //           ),
                //           child: Padding(
                //             padding: EdgeInsets.only(left: 8.0, right: 1),
                //             child: Row(
                //               children: [
                //                 Text(
                //                   'See all',
                //                   style: TextStyle(color: Colors.white),
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.only(left: 8.0),
                //                   child: Container(
                //                     decoration: BoxDecoration(
                //                         borderRadius: BorderRadius.circular(20),
                //                         color: Colors.blue.shade700),
                //                     child: Padding(
                //                       padding: EdgeInsets.all(8.0),
                //                       child: Icon(Icons.arrow_forward_ios,
                //                           size: 12, color: Colors.white),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                //   Padding(
                //     padding:
                //         EdgeInsets.only(top: 15.0, right: 8, left: 8, bottom: 8),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Category(catName: 'Home'),
                //         Category(catName: 'Kitchen'),
                //         Category(catName: 'Watch'),
                //         Category(catName: 'Bags'),
                //       ],
                //     ),
                //   ),
                //   Padding(
                //     padding:
                //         EdgeInsets.only(top: 140.0, right: 8, left: 8, bottom: 8),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Category(
                //           catName: 'Fashion',
                //         ),
                //         Category(catName: 'Music'),
                //         Category(catName: 'Travel'),
                //         Category(catName: 'Beauty'),
                //       ],
                //     ),
                //   ),
              ]))
            : (tabIndex == 1)
                ? Text("THis is Wishlist")
                : Text("THis is Ads"));
  }
}

class WishListPage extends StatefulWidget {
  var currentUserID;

  WishListPage({Key? key, required this.currentUserID}) : super(key: key);

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  final List<Map<String, dynamic>> _allUsers = [
    {
      "id": 1,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 2,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 3,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 4,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 5,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 6,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 7,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 8,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 9,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 10,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
  ];

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];
  List<dynamic> _wishList = [];
  List<dynamic> _wishListAds = [];
  List<dynamic> subCats = [];
  List<dynamic> displayAds = [];

  @override
  initState() {
    // at the beginning, all users are shown
    _foundUsers = _allUsers;
    super.initState();
    loadWishListAds();
    loadWishList();
  }

  loadWishListAds() async {
    await FirebaseFirestore.instance
        .collection('advertisement')
        .get()
        .then((wishListAds) async {
      if (wishListAds.docs.length != 0) {
        _wishListAds = wishListAds.docs.toList();
      }
    });
  }

  loadWishList() async {
    await FirebaseFirestore.instance
        .collection('wishList')
        .where("userID", isEqualTo: widget.currentUserID)
        .where("status", isEqualTo: 1)
        .get()
        .then((wishLists) async {
      if (wishLists.docs.length != 0) {
        _wishList = wishLists.docs.toList();
        _wishList.forEach((element) {
          subCats.add(int.parse(element['subCatId']));
        });
        getWishListAds();
      }
    });
  }

  getWishListAds() {
    var displayAdsList = [];
    _wishListAds.forEach((element) {
      if (subCats.contains(element['subcategory'])) displayAdsList.add(element);
    });
    setState(() => displayAds.addAll(displayAdsList));
    print(displayAds);
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      //minimumSize: Size(22, 22),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      backgroundColor: Colors.blue,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          children: [
            const SizedBox(
              height: 1,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: displayAds.isNotEmpty
                  ? ListView.builder(
                      itemCount: displayAds.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(displayAds[index].data()["id"]),
                        // color: Colors.amberAccent,
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: <Widget>[
                              Image.network(
                                  displayAds[index].data()["mainBanner"],
                                  fit: BoxFit.fill,
                                  width: Get.width),
                              // Image.asset("./assets/images/" +
                              //     _foundUsers[index]["image"] +
                              //     ".jpeg"),
                              Row(
                                children: [
                                  Text(
                                    displayAds[index].data()['name'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: SizedBox(height: 10)),
                                  Text(
                                    displayAds[index].data()['categoryName'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    displayAds[index].data()['subcategoryName'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    displayAds[index].data()['name'],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                              // Text("Plantations"),
                              // Icon(Icons.favorite),
                              // Positioned(
                              //   bottom: 0,
                              //   left: 10,
                              //   child: SizedBox(
                              //     height: 50,
                              //     child: Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [Text('Title'), Text('Subtitle')],
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        // Card(
                        //   clipBehavior: Clip.antiAliasWithSaveLayer,
                        //   child: Column(
                        //     children: [
                        //       SizedBox(
                        //         width: Get.width / 1,
                        //         height: 110,
                        //         child: Image.network(
                        //           'https://via.placeholder.com/300?text=DITTO',
                        //           fit: BoxFit.fill,
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         height: 16,
                        //       ),
                        //       Column(
                        //           children: [Text('Title'), Text('Subtitle')])
                        //     ],
                        //   ),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(10.0),
                        //   ),
                        //   elevation: 5,
                        //   margin: EdgeInsets.all(10),
                        // )
                        // ListTile(
                        //     leading: Text(
                        //       _foundUsers[index]["id"].toString(),
                        //       style: const TextStyle(fontSize: 18),
                        //     ),

                        //     title: Text(_foundUsers[index]['name']),
                        //     subtitle: Text('${_foundUsers[index]["age"]} '),
                        //     trailing: TextButton(
                        //       style: flatButtonStyle,
                        //       onPressed: () {
                        //         print('Button pressed');
                        //       },
                        //       child: Text('Buy Now'),
                        //     )),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrendsListPage extends StatefulWidget {
  const TrendsListPage({Key? key}) : super(key: key);

  @override
  State<TrendsListPage> createState() => _TrendsListPageState();
}

class _TrendsListPageState extends State<TrendsListPage> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well

  final List<Map<String, dynamic>> _allUsers = [
    {
      "id": 1,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 2,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 3,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 4,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 5,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 6,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 7,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 8,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
    {
      "id": 9,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist1'
    },
    {
      "id": 10,
      "name": "Test Product",
      "age": "Test product",
      "image": 'wishlist2'
    },
  ];

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];
  @override
  initState() {
    // at the beginning, all users are shown
    _foundUsers = _allUsers;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      //minimumSize: Size(22, 22),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      backgroundColor: Colors.blue,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          children: [
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundUsers[index]["id"]),
                        // color: Colors.amberAccent,
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: <Widget>[
                              Image.asset("./assets/images/" +
                                  _foundUsers[index]["image"] +
                                  ".jpeg"),
                              Row(
                                children: [
                                  Text(
                                    'AED 1234',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: SizedBox(height: 10)),
                                  Text(
                                    'Category: Phone',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Tablets Apple',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Ipad from m2 with 126GB',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                              // Text("Plantations"),
                              // Icon(Icons.favorite),
                              // Positioned(
                              //   bottom: 0,
                              //   left: 10,
                              //   child: SizedBox(
                              //     height: 50,
                              //     child: Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [Text('Title'), Text('Subtitle')],
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        // Card(
                        //   clipBehavior: Clip.antiAliasWithSaveLayer,
                        //   child: Column(
                        //     children: [
                        //       SizedBox(
                        //         width: Get.width / 1,
                        //         height: 110,
                        //         child: Image.network(
                        //           'https://via.placeholder.com/300?text=DITTO',
                        //           fit: BoxFit.fill,
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         height: 16,
                        //       ),
                        //       Column(
                        //           children: [Text('Title'), Text('Subtitle')])
                        //     ],
                        //   ),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(10.0),
                        //   ),
                        //   elevation: 5,
                        //   margin: EdgeInsets.all(10),
                        // )
                        // ListTile(
                        //     leading: Text(
                        //       _foundUsers[index]["id"].toString(),
                        //       style: const TextStyle(fontSize: 18),
                        //     ),

                        //     title: Text(_foundUsers[index]['name']),
                        //     subtitle: Text('${_foundUsers[index]["age"]} '),
                        //     trailing: TextButton(
                        //       style: flatButtonStyle,
                        //       onPressed: () {
                        //         print('Button pressed');
                        //       },
                        //       child: Text('Buy Now'),
                        //     )),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdsPage extends StatefulWidget {
  const AdsPage({Key? key}) : super(key: key);

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  final List<Map<String, dynamic>> _allUsers = [
    {
      "id": 1,
      "name": "Ad1",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist1"
    },
    {
      "id": 2,
      "name": "Test Ad2",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist2"
    },
    {
      "id": 3,
      "name": "Sample Ad3",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist1"
    },
    {
      "id": 4,
      "name": "Ad4 check",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist2"
    },
    {
      "id": 5,
      "name": "Ad5 Testing",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist1"
    },
    {
      "id": 6,
      "name": "Ad6",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist2"
    },
    {
      "id": 7,
      "name": "Ad7",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist1"
    },
    {
      "id": 8,
      "name": "Ad8 checking search",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist2"
    },
    {
      "id": 9,
      "name": "Ad9 discount",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist1"
    },
    {
      "id": 10,
      "name": "Ad10 new test",
      "age": "Lore lopsum lore lumpsum",
      "image": "wishlist2"
    },
  ];

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];
  @override
  initState() {
    // at the beginning, all users are shown
    _foundUsers = _allUsers;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 1,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundUsers[index]["id"]),
                        color: Colors.blueAccent,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Text(
                            _foundUsers[index]["id"].toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          title: Text(_foundUsers[index]['name']),
                          subtitle: Text('${_foundUsers[index]["age"]} '),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
