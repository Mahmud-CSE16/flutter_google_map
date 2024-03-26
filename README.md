# Flutter Google Map

##### It's a simple project of Flutter Google Maps. In this project I am able to show get Corrent Location, Searching and add custom marker in google maps

In this repo I am taking about
* Flutter Google Maps
* Geolocatior
* Desing Custom Marker and place it in the Maps
* Canvas in Flutter
* Rotate Center Image

# Outputs

<img src="https://github.com/Mahmud-CSE16/flutter_google_map/blob/master/screenshots/Screenshot_20200423-173859.png" width="200">          <img src="https://github.com/Mahmud-CSE16/flutter_google_map/blob/master/screenshots/Screenshot_20200423-185351.png" width="200">

## Procedure

#### Dependencies:

Add dependencies at pubspec.yaml
```dart
geolocator: ^5.3.0 //for geolocator
google_maps_flutter: ^0.5.24+1 //for google maps
```

Add below lines at AndroidManifest.xml inside application tag
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
       android:value="Your_Api_Key"/>
```

#### Google Map To display:

Use GoogleMap() Widget
```dart
GoogleMap(
   //mapType: MapType.satellite,
   initialCameraPosition: myplace,
   markers: _markers,
   onMapCreated: (GoogleMapController controller) {
     _controller = controller;
     getCurrentLocation();
   },
 ),
 ```

#### Get Current Location and Search by Address:
For current location and searching address I used Geolocator()
```dart
Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high); //Get Current Location
Geolocator().placemarkFromAddress(searchAddress); // Get Searched Location
```

#### Desing Custom Marker:
Here in the marker have info text top of the marker and image center of the marker. we can set rotate value to rotate center image.

* I used Canvas to desing the Marker.
* Convwrt Canvas to Image by PictureRecorder
```dart
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
```

#### Place Custom Marker in Google Map:

Marker Icon Type is BitmapDescriptor. So, I converr custiom desing image to BitmapDescriptor
```dart
BitmapDescriptor.fromBytes(uint8List);
```
Marker Will Like:
```dart
Marker(
    markerId: MarkerId('currentlodation'),
    position: LatLng(position.latitude,position.longitude),
    icon: myIcon == null? BitmapDescriptor.defaultMarker :,
  )
```
Have to call getCustomMarker() function before Marker Icon
```dart
getCustomMarker(){
    getMarkerIcon('images/bike.png','Bike(0 kph)',Colors.indigo,0.0).then((value){
      setState(() {
        myIcon = value;
      });
    });
  }
```

### To more understand please see project code in this repo.

## Thank you.
