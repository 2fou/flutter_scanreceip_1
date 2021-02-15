//Caution: Only works on Android & iOS platforms
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

final Color yellow = Color(0xFF1BA9FB);
final Color orange = Color(0xFF1C0696);

class UploadingImageToFirebaseStorage extends StatefulWidget {
  @override
  _UploadingImageToFirebaseStorageState createState() =>
      _UploadingImageToFirebaseStorageState();
}

class _UploadingImageToFirebaseStorageState
    extends State<UploadingImageToFirebaseStorage> {
  bool working = false;
  // Create the initialization Future outside of `build`:

  // Set default `_initialized` and `_error` state to false

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await firebase_core.Firebase.initializeApp();
      setState(() {
        working = false;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {});
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  File _imageFile;
  String _imagePath = 'Unknown';

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  loadProgress() {
    if (working == true) {
      setState(() {
        working = false;
      });
    } else {
      setState(() {
        working = true;
      });
    }
  }

  // Future ocrtrigger() async {
  //   final response = await http
  //       .get('https://academy-acsolutions-lu.ew.r.appspot.com/OcrDoc');
  //   if (response.statusCode == 200) {
  //     print("Operation successful!");
  //   } else {
  //     throw Exception('Unable to fetch products from the REST API');
  //   }
  // }

  Widget getProgressDialog() {
    return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: working,
        child: Container(
            margin: EdgeInsets.only(top: 50, bottom: 30),
            child: CircularProgressIndicator()));
  }

  Future<void> uploadImageToFirebase(BuildContext context) async {
    String fileName = basenameWithoutExtension(_imageFile.path);
    String timestamp = DateTime.now().toString();
    final image = pw.MemoryImage(_imageFile.readAsBytesSync());
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image.provider(image));
        },
      ),
    ); // Page;

    Directory tempDir = await getExternalStorageDirectory();

    final pdfFile = File("${tempDir.path}/$fileName _$timestamp.pdf");
    await pdfFile.writeAsBytes(pdf.save());
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref("pdf/$fileName _$timestamp.pdf")
          .putFile(pdfFile);
      final String downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref("pdf/$fileName _$timestamp.pdf")
          .getDownloadURL();

      final String gcsReference = "gs://" +
          firebase_storage.FirebaseStorage.instance.bucket +
          "/" +
          firebase_storage.FirebaseStorage.instance
              .ref("pdf/$fileName _$timestamp.pdf")
              .fullPath;

      await FirebaseFirestore.instance
          .collection("images")
          .doc("doc_$timestamp")
          .set({
            "url": downloadUrl,
            "gsc": gcsReference,
            "name": "$fileName _$timestamp.pdf",
            "timestamp": "$timestamp",
            "status": "pending"
          })
          .then((value) => print("Document added"))
          .catchError((error) => print('Failed to add the document:$error'));
    } on firebase_core.FirebaseException catch (e) {
      print(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan your Ticket"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: 360,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0)),
                gradient: LinearGradient(
                    colors: [orange, yellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 80),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Uploading Image to Firebase Storage",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),
                          child: _imageFile != null
                              ? Image.file(_imageFile)
                              : TextButton(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                  ),
                                  onPressed: pickImage,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                uploadImageButton(context),
                getProgressDialog(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadImageButton(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            margin: const EdgeInsets.only(
                top: 30, left: 20.0, right: 20.0, bottom: 20.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.black],
                ),
                borderRadius: BorderRadius.circular(30.0)),
            child: TextButton(
              onPressed: () {
                loadProgress();
                uploadImageToFirebase(context);
                // ocrtrigger();
                /*Provide the feeling that processing is on-going*/
                //The The loadProgress will be executed after 3 secs
                Timer(Duration(seconds: 3), () {
                  loadProgress();
                });
              },
              child: Text(
                "Upload Image",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
