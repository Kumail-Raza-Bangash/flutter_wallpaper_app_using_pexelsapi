import 'dart:io';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:js' as js;

class ImageView extends StatefulWidget {
  final String imgPath;

  const ImageView({super.key, required this.imgPath});

  @override
  // ignore: library_private_types_in_public_api
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  // ignore: prefer_typing_uninitialized_variables
  var filePath;

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
      body: Stack(
        children: <Widget>[
          Hero(
            tag: widget.imgPath,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: kIsWeb
                  ? Image.network(widget.imgPath, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: widget.imgPath,
                      placeholder: (context, url) => Container(
                        color: const Color(0xfff5f8fd),
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        _save();
                        _launchURL(widget.imgPath);
                        //js.context.callMethod('downloadUrl',[widget.imgPath]);
                        //response = await dio.download(widget.imgPath, "./xx.html");
                      } else {
                        _save();
                      }
                      //Navigator.pop(context);
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff1C1B1B).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white24, width: 1),
                                borderRadius: BorderRadius.circular(40),
                                gradient: const LinearGradient(
                                    colors: [
                                      Color(0x36FFFFFF),
                                      Color(0x0FFFFFFF)
                                    ],
                                    begin: FractionalOffset.topLeft,
                                    end: FractionalOffset.bottomRight)),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Set Wallpaper",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Text(
                                  kIsWeb
                                      ? "Image will open in new tab to download"
                                      : "Image will be saved in gallery",
                                  style: TextStyle(
                                      fontSize: 8, color: Colors.white70),
                                ),
                              ],
                            )),
                      ],
                    )),
                const SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          )
        ],
      ),
    );
  }



// ...

_save() async {

  await _askPermission();

  if (kIsWeb) {
    // Handle setting wallpaper for web (if needed)
    // You can use the URL directly or download the image if required.
    // Example:
    // final imageData = await Dio().get(widget.imgPath, options: Options(responseType: ResponseType.bytes));
    // await WallpaperManager.setWallpaper(Uint8List.fromList(imageData.data));
  } else {
    // Set wallpaper for mobile platforms (Android and iOS)
    try {
      final result = await AsyncWallpaper.setWallpaper(
        url: widget.imgPath,
        wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
        
        );
      
      if (result) {
        // Wallpaper set successfully
        // ignore: avoid_print
        print('Wallpaper set successfully.');
      } else {
        // Failed to set wallpaper
        // ignore: avoid_print
        print('Failed to set wallpaper.');
      }
    } catch (e) {
      // Handle exceptions
      // ignore: avoid_print
      print('Error setting wallpaper: $e');
    }
  }

  // ignore: use_build_context_synchronously
  Navigator.pop(context);
}





  // _save() async {
  //   await _askPermission();
  //   var response = await Dio().get(widget.imgPath,
  //       options: Options(responseType: ResponseType.bytes));
  //   final result =
  //       await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  //   // ignore: avoid_print
  //   print(result);
  //   // ignore: use_build_context_synchronously
  //   Navigator.pop(context);
  // }

_askPermission() async {
  if (Platform.isIOS) {
    var status = await Permission.photos.request();
    if (status.isDenied) {
      // Handle denied permission on iOS
    }
  } else {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // Handle denied permission on Android
      await Permission.storage.request();
    }
  }
}

}
