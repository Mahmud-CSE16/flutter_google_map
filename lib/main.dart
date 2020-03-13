import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GoogleMapController _controller;
  String searchAddress;


  static final CameraPosition myplace = CameraPosition(
    target: LatLng(22.897245,89.505011),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Stack(
       children: <Widget>[
         GoogleMap(
           //mapType: MapType.normal,
           initialCameraPosition: myplace,
           onMapCreated: (GoogleMapController controller) {
             _controller = controller;
           },
         ),
         Positioned(
           top: 30.0,
           right: 15.0,
           left: 15.0,
           child: Container(
             height: 50.0,
             width: double.infinity,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10.0),
               color: Colors.white,
             ),
             child: Center(
               child: TextField(
                 decoration: InputDecoration(
                   hintText: 'Enter Address',
                   border: InputBorder.none,
                   contentPadding: EdgeInsets.only(left: 15.0,top: 15.0),
                   suffixIcon: IconButton(
                     icon: Icon(Icons.search),
                     iconSize: 30.0,
                     onPressed: () async{
                       print(searchAddress);
                       try {
                         List<Placemark> placemark = await Geolocator().placemarkFromAddress(searchAddress);
                         Placemark newPlace = placemark[0];
                         _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                           target: LatLng(newPlace.position.latitude,newPlace.position.longitude),
                           zoom: 15.0,
                         )));
                       }catch(e){
                         print(e);
                       }
                     } ,
                   )
                 ),
                 onChanged: (val){
                   setState(() {
                     searchAddress = val;
                   });
                 },
               ),
             ),
           ),
         )
       ],
     )
    );
  }
}
