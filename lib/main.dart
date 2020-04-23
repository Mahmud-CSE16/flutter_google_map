import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            rotation: 0,
            infoWindow: InfoWindow(
              title: 'dhaka',
            ),
            markerId: MarkerId('currentlodation'),
            position: LatLng(position.latitude,position.longitude),
            icon: myIcon == null? BitmapDescriptor.defaultMarker : myIcon /*BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)*/,
          )
      );
    });
  }

  getCustomMarker(){
    getMarkerIcon('images/bike.png','Bike(0 kph)',Colors.indigo,0.0).then((value){
      setState(() {
        myIcon = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
//    BitmapDescriptor.fromAssetImage(
//        ImageConfiguration(size: Size(10, 10)), 'images/resize_car_marker.png')
//        .then((onValue) {
//      setState(() {
//        myIcon = onValue;
//      });
//    });
    getCustomMarker();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       resizeToAvoidBottomInset: false,
       body: Stack(
         children: <Widget>[
           GoogleMap(
             //mapType: MapType.satellite,
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
      ),
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



Future<BitmapDescriptor> getMarkerIcon(String imagePath,String infoText,Color color,double rotateDegree) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  //size
  Size canvasSize = Size(500.0,220.0);
  Size markerSize = Size(150.0,150.0);

  // Add info text
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: infoText,
    style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.w600, color: color),
  );
  textPainter.layout();

  final Paint infoPaint = Paint()..color = Colors.white;
  final Paint infoStrokePaint = Paint()..color = color;
  final double infoHeight = 70.0;
  final double strokeWidth = 2.0;

  final Paint markerPaint = Paint()..color = color.withOpacity(.5);
  final double shadowWidth = 30.0;

  final Paint borderPaint = Paint()..color = color..strokeWidth=2.0..style = PaintingStyle.stroke;

  final double imageOffset = shadowWidth*.5;

  canvas.translate(canvasSize.width/2, canvasSize.height/2+infoHeight/2);

  // Add shadow circle
  canvas.drawOval(Rect.fromLTWH(-markerSize.width/2, -markerSize.height/2, markerSize.width, markerSize.height), markerPaint);
  // Add border circle
  canvas.drawOval(Rect.fromLTWH(-markerSize.width/2+shadowWidth, -markerSize.height/2+shadowWidth, markerSize.width-2*shadowWidth, markerSize.height-2*shadowWidth), borderPaint);

  // Oval for the image
  Rect oval = Rect.fromLTWH(-markerSize.width/2+.5* shadowWidth, -markerSize.height/2+.5*shadowWidth, markerSize.width-shadowWidth, markerSize.height-shadowWidth);

  //save canvas before rotate
  canvas.save();

  double rotateRadian = (pi/180.0)*rotateDegree;

  //Rotate Image
  canvas.rotate(rotateRadian);

  // Add path for oval image
  canvas.clipPath(Path()
    ..addOval(oval));

  // Add image
  ui.Image image = await getImageFromPath(imagePath);
  paintImage(canvas: canvas,image: image, rect: oval, fit: BoxFit.fitHeight);

  canvas.restore();

  // Add info box stroke
  canvas.drawPath(Path()..addRRect(RRect.fromLTRBR(-textPainter.width/2-infoHeight/2, -canvasSize.height/2-infoHeight/2+1, textPainter.width/2+infoHeight/2, -canvasSize.height/2+infoHeight/2+1,Radius.circular(35.0)))
      ..moveTo(-15, -canvasSize.height/2+infoHeight/2+1)
      ..lineTo(0, -canvasSize.height/2+infoHeight/2+25)
      ..lineTo(15, -canvasSize.height/2+infoHeight/2+1)
      , infoStrokePaint);

  //info info box
  canvas.drawPath(Path()..addRRect(RRect.fromLTRBR(-textPainter.width/2-infoHeight/2+strokeWidth, -canvasSize.height/2-infoHeight/2+1+strokeWidth, textPainter.width/2+infoHeight/2-strokeWidth, -canvasSize.height/2+infoHeight/2+1-strokeWidth,Radius.circular(32.0)))
    ..moveTo(-15+strokeWidth/2, -canvasSize.height/2+infoHeight/2+1-strokeWidth)
    ..lineTo(0, -canvasSize.height/2+infoHeight/2+25-strokeWidth*2)
    ..lineTo(15-strokeWidth/2, -canvasSize.height/2+infoHeight/2+1-strokeWidth)
      , infoPaint);
  textPainter.paint(
      canvas,
      Offset(
          - textPainter.width / 2,
          -canvasSize.height/2-infoHeight/2+infoHeight / 2 - textPainter.height / 2
      )
  );

  canvas.restore();

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt()
  );

  // Convert image to bytes
  final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}


Future<ui.Image> getImageFromPath(String imagePath) async {
  //File imageFile = File(imagePath);
  var bd = await rootBundle.load(imagePath);
  Uint8List imageBytes = Uint8List.view(bd.buffer);

  final Completer<ui.Image> completer = new Completer();

  ui.decodeImageFromList(imageBytes, (ui.Image img) {
    return completer.complete(img);
  });

  return completer.future;
}
