import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/data/data.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/models/photos_model.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/widget/widget.dart';
import 'package:http/http.dart' as http;

class SearchView extends StatefulWidget {
  final String search;

  const SearchView({super.key, required this.search});

  @override
  // ignore: library_private_types_in_public_api
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<PhotosModel> photos = [];
  TextEditingController searchController = TextEditingController();

  getSearchWallpaper(String searchQuery) async {
    await http.get(
      Uri.parse("https://api.pexels.com/v1/search?query=$searchQuery&per_page=30&page=1"),
      headers: {"Authorization": apiKEY},
        ).then((value) {
      //print(value.body);


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
    getSearchWallpaper(widget.search);
    searchController.text = widget.search;
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xfff5f8fd),
                borderRadius: BorderRadius.circular(30),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                        hintText: "search wallpapers",
                        border: InputBorder.none),
                  )),
                  InkWell(
                      onTap: () {
                        getSearchWallpaper(searchController.text);
                      },
                      child: const Icon(Icons.search))
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            wallPaper(photos, context),
          ],
        ),
      ),
    );
  }
}
