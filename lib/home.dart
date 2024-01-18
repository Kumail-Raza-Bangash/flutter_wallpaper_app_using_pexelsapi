
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/data/data.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/models/categorie_model.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/models/photos_model.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/view/categorie_screen.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/view/search_view.dart';
import 'package:flutter_wallpaper_app_using_pexelsapi/widget/widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategorieModel> categories = [];

  int noOfImageToLoad = 30;
  List<PhotosModel> photos = [];

  getTrendingWallpaper() async {
    await http.get(
      Uri.parse("https://api.pexels.com/v1/curated?per_page=$noOfImageToLoad&page=1"),
      headers: {"Authorization": apiKEY},).then((value) {
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

  TextEditingController searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    //getWallpaper();
    getTrendingWallpaper();
    categories = getCategories();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        noOfImageToLoad = noOfImageToLoad + 30;
        getTrendingWallpaper();
      }
    });
  }

  _launchURL(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: brandName(),
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                        if (searchController.text != "") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchView(
                                        search: searchController.text,
                                      )));
                        }
                      },
                      child: const Icon(Icons.search))
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categories.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    /// Create List Item tile
                    return CategoriesTile(
                      imgUrls: categories[index].imgUrl,
                      categorie: categories[index].categorieName,
                    );
                  }),
            ),
            wallPaper(photos, context),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Photos provided By ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontFamily: 'Overpass'),
                ),
                GestureDetector(
                  onTap: () {
                    _launchURL("");
                  },
                  child: const Text("9 Pexels",style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'Overpass'),),
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesTile extends StatelessWidget {
  final String imgUrls, categorie;

  const CategoriesTile({super.key, required this.imgUrls, required this.categorie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategorieScreen(
                      categorie: categorie,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: kIsWeb
            ? Column(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        categorie,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Overpass'),
                      )),
                ],
              )
            : Stack(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )),
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        categorie,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Overpass'),
                      ))
                ],
              ),
      ),
    );
  }
}
