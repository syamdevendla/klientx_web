//*************   © Copyrighted by aagama_it. 

// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryDetails extends StatefulWidget {
  var categoryData;
  CategoryDetails({Key? key, required this.categoryData}) : super(key: key);

  // CategoryTrends({required this.categoryName});

  @override
  State createState() => new CategoryDetailsState();
}

class CategoryDetailsState extends State<CategoryDetails>
    with TickerProviderStateMixin {
  CarouselController buttonCarouselController = CarouselController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var catName = widget.categoryName;
    var advertName = widget.categoryData!['name'];
    var mainBanner = widget.categoryData!['mainBanner'];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            advertName,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Mycolors.white,
        ),
        backgroundColor: Colors.white,
        // body: SingleChildScrollView(
        //   child: Stack(
        //     children: [
        //       BodyLayout(),
        //     ],
        //   ),
        // ),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .35,
              padding: const EdgeInsets.only(bottom: 30),
              width: double.infinity,
              child: Image.network(mainBanner),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 40, right: 14, left: 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category',
                              ),
                              Text(widget.categoryData!['category']),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Name',
                              ),
                              Text(
                                widget.categoryData!['name'],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price',
                              ),
                              Text(
                                widget.categoryData!['price'],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount',
                              ),
                              Text(
                                widget.categoryData!['discount'],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // SizedBox(
                          //   height: 110,
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: widget.categoryData.length,
                          //     itemBuilder: (context, index) => Container(
                          //       margin: const EdgeInsets.only(right: 6),
                          //       width: 110,
                          //       height: 110,
                          //       decoration: BoxDecoration(
                          //         color: Mycolors.blue,
                          //         borderRadius: BorderRadius.circular(20),
                          //       ),
                          //       // child: Center(
                          //       //   child: Image(
                          //       //     height: 70,
                          //       //     //image: Image.network(idget.categoryData['image']),
                          //       //   ),
                          //       // ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 200,
                      height: 50,
                      child: Text(
                        'Visit',
                      ),
                      decoration: BoxDecoration(
                        color: Mycolors.blue,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
