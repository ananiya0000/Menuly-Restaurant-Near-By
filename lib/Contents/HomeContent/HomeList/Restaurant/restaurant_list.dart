import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/Database/Download/getData.dart';
import 'package:e_commerce/Database/Edit/delete_data.dart';
import 'package:e_commerce/Screen/DetailPage/restaurant_detail_screen.dart';
import 'package:e_commerce/zRealDistance/AssistantMethods.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';

class RestaurantList extends StatefulWidget {
  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  Timer timer;
  Stream items;
  GetData crudObj = new GetData();
  DeleteData resData = new DeleteData();
  @override
  void initState() {
    crudObj.getRestaurantData().then((results) {
      setState(() {
        items = results;
      });
    });
    super.initState();
  }

  double distance = 0;
  var locationMessage = "";
  var passlat;
  var passlong;
  @override
  Future<String> getCurrentLocation(String slatitude, String slongitude) async {
    var slat = double.parse(slatitude);
    var slon = double.parse(slongitude);
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    passlat = position.latitude;
    passlong = position.longitude;
    // distance = Geolocator.distanceBetween(
    //     position.latitude, position.longitude, slat, slon);
    // distance = distance.roundToDouble() / 1000;
    // String temp = distance.toStringAsFixed(2);

    LatLng a = LatLng(passlat, passlong);
    LatLng b = LatLng(slat, slon);

    var details = await AssistantMethods.obtainDirectionDetails(a, b);
    return details.distanceText;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: StreamBuilder(
          stream: items,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              var doc = snapshot.data.documents;
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: doc.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => SimpleDialog(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                    onTap: () {
                                      resData.deleteRestaurantData(
                                          snapshot.data.docs[index].id);
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ));
                    },
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RestaurantDetailScreen(
                                    restaurantName:
                                        "${doc[index].data()['name']}",
                                    restaurantMenu: doc[index].documentID,
                                    restaurantImage:
                                        "${doc[index].data()['image']}",
                                    restaurantEmail:
                                        "${doc[index].data()['email']}",
                                    restaurantInstagram:
                                        "${doc[index].data()['instagram']}",
                                    restaurantFacebook:
                                        "${doc[index].data()['facebook']}",
                                    restaurantPhone:
                                        "${doc[index].data()['phone']}",
                                    restaurantType:
                                        "${doc[index].data()['type']}",
                                  )));
                    },
                    child: Card(
                      margin: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              )
                            ]),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: "${doc[index].data()['image']}",
                                fit: BoxFit.cover,
                                //  cache: true,
                              ),
                            ),
                            ListTile(
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        SimpleDialog(
                                          children: [
                                            ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit'),
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.delete),
                                              title: Text('Delete'),
                                              onTap: () {
                                                resData.deleteRestaurantData(
                                                    snapshot
                                                        .data.docs[index].id);
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ));
                              },
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            RestaurantDetailScreen(
                                              restaurantName:
                                                  "${doc[index].data()['name']}",
                                              restaurantImage:
                                                  "${doc[index].data()['image']}",
                                              restaurantMenu:
                                                  doc[index].documentID,
                                              restaurantEmail:
                                                  "${doc[index].data()['email']}",
                                              restaurantInstagram:
                                                  "${doc[index].data()['instagram']}",
                                              restaurantFacebook:
                                                  "${doc[index].data()['facebook']}",
                                              restaurantPhone:
                                                  "${doc[index].data()['phone']}",
                                              restaurantType:
                                                  "${doc[index].data()['type']}",
                                            )));
                              },
                              title: Text(
                                '${doc[index].data()['name']}',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                              subtitle: FutureBuilder<String>(
                                future: getCurrentLocation(
                                    '${doc[index].data()['latitude']}',
                                    '${doc[index].data()['longtiude']}'),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  List<Widget> children;
                                  if (snapshot.hasData) {
                                    children = <Widget>[
                                      Text('Distance: ${snapshot.data}'),
                                    ];
                                  } else {
                                    children = <Widget>[
                                      JumpingText('Calculating distance...'),
                                    ];
                                  }

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: children,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          }),
    );
  }
}
