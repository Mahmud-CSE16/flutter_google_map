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
  Set<Marker> _markers = {};
  GoogleMapController _controller;
  String searchAddress;
  BitmapDescriptor myIcon;


  static final CameraPosition myplace = CameraPosition(
    target: LatLng(23.734143,90.392770),
    zoom: 14.4746,
  );

  void getCurrentLocation()async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setMarkerAndMoveCamera(position);
  }

  setMarkerAndMoveCamera(Position position){
    _controller.animateCamera(CameraUpdate.newCameraPosition( CameraPosition(
      target: LatLng(position.latitude,position.longitude),
      zoom: 15.0,
    )));

    setState(() {
      _markers.add(
          Marker(
            markerId: MarkerId('currentlodation'),
            position: LatLng(position.latitude,position.longitude),
            icon: myIcon == null? BitmapDescriptor.defaultMarker : myIcon /*BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)*/,
          )
      );
    });
  }
  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), 'images/resize_car_marker.png')
        .then((onValue) {
      setState(() {
        myIcon = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     resizeToAvoidBottomInset: false,
     body: Stack(
       children: <Widget>[
         GoogleMap(
           //mapType: MapType.normal,
           initialCameraPosition: myplace,
           markers: _markers,
           onMapCreated: (GoogleMapController controller) {
             _controller = controller;
             getCurrentLocation();
           },
         ),
         searchBar(),
       ],
     )
    );
  }

  Widget searchBar(){
    return Positioned(
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
                       setMarkerAndMoveCamera(newPlace.position);
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
       );
  }
}
