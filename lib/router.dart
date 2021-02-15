//import 'package:flutter_widgets/pdf/load_pdf.dart';
import 'package:flutter/material.dart';
//import 'images/upload_images.dart';
import 'screens/upload_receipt.dart';
import 'home.dart';
//import 'utils/mldocumentai.dart';

const String HOME = "/";
const String LIST_IMAGES = '/LIST_IMAGES';
const String LOAD_IMAGE_FIR_STORAGE = 'LOAD_IMAGE_FIR_STORAGE';
const String UPLOAD_IMAGE_FIR_STORAGE = 'UPLOAD_IMAGE_FIR_STORAGE';
const String TEST_VISION = 'TEST_VISION';
const String TEST_PDF = 'TEST_PDF';
const String DOCUMENTAI = 'DOCUMENTAI';
const String MYLIST = 'MYLIST';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  print(routeSettings.name);

  switch (routeSettings.name) {
    case HOME:
      return MaterialPageRoute(builder: (context) => Home());
      break;

    case UPLOAD_IMAGE_FIR_STORAGE:
      return MaterialPageRoute(
          builder: (context) => UploadingImageToFirebaseStorage());
      break;
    default:
      return MaterialPageRoute(builder: (context) => Home());
  }
}
