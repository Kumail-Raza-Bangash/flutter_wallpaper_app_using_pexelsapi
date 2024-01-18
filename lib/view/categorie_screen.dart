import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/data/data.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/models/photos_model.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/widget/widget.dart';
import 'package:http/http.dart' as http;

class CategorieScreen extends StatefulWidget {
  final String categorie;

  const CategorieScreen({super.key, required this.categorie});

  @override
  // ignore: library_private_types_in_public_api
  _CategorieScreenState createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen> {
  List<PhotosModel> photos = [];

getCategorieWallpaper() async {
  await http.get(
    Uri.parse("https://api.pexels.com/v1/search?query=${widget.categorie}&per_page=30&page=1"),
    headers: {"Authorization": apiKEY},
  ).then((value) {


    Map<String, dynamic>? jsonData = jsonDecode(value.body);

    if (jsonData != null && jsonData["photos"] != null) {
      for (var element in (jsonData["photos"] as List)) {
        PhotosModel photosModel = PhotosModel(
          url: element["url"],
          photographer: element["photographer"],
          photographerId: element["photographer_id"],
          photographerUrl: element["photographer_url"],
          src: SrcModel.fromMap(element["src"]),
        );
        photosModel = PhotosModel.fromMap(element);
        photos.add(photosModel);
        //print(photosModel.toString()+ "  "+ photosModel.src.portrait);
      }

      setState(() {});

      } else {
      // Handle the case where jsonData or jsonData["photos"] is null
      // ignore: avoid_print
      print("Error: jsonData or photos data is null");
    }
  });
}


  @override
  void initState() {
    getCategorieWallpaper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: brandName(),
        elevation: 0.0,
        actions: <Widget>[
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: wallPaper(photos, context)
        ,
      ),
    );
  }
}
