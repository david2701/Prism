import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Prism/analytics/analytics_service.dart';
import 'package:Prism/routes/router.dart';
import 'package:Prism/routes/routing_constants.dart';
import 'package:Prism/theme/jam_icons_icons.dart';
import 'package:Prism/ui/widgets/animated/loader.dart';
import 'package:Prism/ui/widgets/popup/signInPopUp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imagelib;
import 'package:photo_view/photo_view.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:Prism/theme/config.dart' as config;
import 'package:Prism/theme/toasts.dart' as toasts;
import 'package:Prism/main.dart' as main;

class WallpaperFilterScreen extends StatefulWidget {
  final imagelib.Image image;
  final String filename;

  const WallpaperFilterScreen({
    Key key,
    @required this.image,
    @required this.filename,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WallpaperFilterScreenState();
}

class _WallpaperFilterScreenState extends State<WallpaperFilterScreen> {
  String filename;
  Map<String, List<int>> cachedFilters = {};
  Filter _filter;
  imagelib.Image image;
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;
    _filter = presetFiltersList[0];
    filename = widget.filename;
    image = widget.image;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onWillPop() async {
    if (navStack.length > 1) navStack.removeLast();
    debugPrint(navStack.toString());
    return true;
  }

  static const platform = MethodChannel("flutter.prism.set_wallpaper");

  Future<void> _setWallPaper(String url) async {
    bool result;
    try {
      if (url.contains("com.hash.prism")) {
        result =
            await platform.invokeMethod("set_wallpaper_file", <String, dynamic>{
          'url': url,
        });
      } else if (url.contains("/0/")) {
        result =
            await platform.invokeMethod("set_wallpaper_file", <String, dynamic>{
          'url': "/${url.replaceAll("/0//", "/0/")}",
        });
      } else {
        result = await platform.invokeMethod("set_wallpaper", <String, dynamic>{
          'url': url,
        });
      }
      if (result) {
        debugPrint("Success");
        analytics.logEvent(
            name: 'set_wall',
            parameters: {'type': 'Both', 'result': 'Success'});
      } else {
        debugPrint("Failed");
        toasts.error("Something went wrong!");
      }
    } catch (e) {
      analytics.logEvent(
          name: 'set_wall', parameters: {'type': 'Both', 'result': 'Failure'});
      debugPrint(e.toString());
    }
  }

  Future<void> _setBothWallPaper(String url) async {
    bool result;
    try {
      if (url.contains("com.hash.prism")) {
        result = await platform
            .invokeMethod("set_both_wallpaper_file", <String, dynamic>{
          'url': url,
        });
      } else if (url.contains("/0/")) {
        result = await platform
            .invokeMethod("set_both_wallpaper_file", <String, dynamic>{
          'url': "/${url.replaceAll("/0//", "/0/")}",
        });
      } else {
        result =
            await platform.invokeMethod("set_both_wallpaper", <String, dynamic>{
          'url': url,
        });
      }
      if (result) {
        debugPrint("Success");
        analytics.logEvent(
            name: 'set_wall',
            parameters: {'type': 'Both', 'result': 'Success'});
        toasts.codeSend("Wallpaper set successfully!");
      } else {
        debugPrint("Failed");
        toasts.error("Something went wrong!");
      }
    } catch (e) {
      analytics.logEvent(
          name: 'set_wall', parameters: {'type': 'Both', 'result': 'Failure'});
      debugPrint(e.toString());
    }
  }

  Future<void> _setLockWallPaper(String url) async {
    bool result;
    try {
      if (url.contains("com.hash.prism")) {
        result = await platform
            .invokeMethod("set_lock_wallpaper_file", <String, dynamic>{
          'url': url,
        });
      } else if (url.contains("/0/")) {
        result = await platform
            .invokeMethod("set_lock_wallpaper_file", <String, dynamic>{
          'url': "/${url.replaceAll("/0//", "/0/")}",
        });
      } else {
        result =
            await platform.invokeMethod("set_lock_wallpaper", <String, dynamic>{
          'url': url,
        });
      }
      if (result) {
        debugPrint("Success");
        analytics.logEvent(
            name: 'set_wall',
            parameters: {'type': 'Lock', 'result': 'Success'});
        toasts.codeSend("Wallpaper set successfully!");
      } else {
        debugPrint("Failed");
        toasts.error("Something went wrong!");
      }
    } catch (e) {
      debugPrint(e.toString());
      analytics.logEvent(
          name: 'set_wall', parameters: {'type': 'Lock', 'result': 'Failure'});
    }
  }

  Future<void> _setHomeWallPaper(String url) async {
    bool result;
    try {
      if (url.contains("com.hash.prism")) {
        result = await platform
            .invokeMethod("set_home_wallpaper_file", <String, dynamic>{
          'url': url,
        });
      } else if (url.contains("/0/")) {
        result = await platform
            .invokeMethod("set_home_wallpaper_file", <String, dynamic>{
          'url': "/${url.replaceAll("/0//", "/0/")}",
        });
      } else {
        result =
            await platform.invokeMethod("set_home_wallpaper", <String, dynamic>{
          'url': url,
        });
      }
      if (result) {
        debugPrint("Success");
        analytics.logEvent(
            name: 'set_wall',
            parameters: {'type': 'Home', 'result': 'Success'});
        toasts.codeSend("Wallpaper set successfully!");
      } else {
        debugPrint("Failed");
        toasts.error("Something went wrong!");
      }
    } catch (e) {
      debugPrint(e.toString());
      analytics.logEvent(
          name: 'set_wall', parameters: {'type': 'Home', 'result': 'Failure'});
    }
  }

  void showPremiumPopUp(Function func) {
    if (main.prefs.get("isLoggedin") == false) {
      toasts.codeSend("Editing Wallpaper is a premium feature.");
      googleSignInPopUp(context, () {
        if (main.prefs.get("premium") == false) {
          Navigator.pushNamed(context, premiumRoute);
        } else {
          func();
        }
      });
    } else {
      if (main.prefs.get("premium") == false) {
        toasts.codeSend("Editing Wallpaper is a premium feature.");
        Navigator.pushNamed(context, premiumRoute);
      } else {
        func();
      }
    }
  }

  Future<void> onTapPaint(String url) async {
    showPremiumPopUp(() async {
      showDialog(
        context: context,
        child: AlertDialog(
          backgroundColor: Theme.of(context).hintColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: Container(
            height: 200,
            width: 250,
            child: Center(
              child: ListView.builder(
                  itemCount: 3,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        index == 0
                            ? JamIcons.phone
                            : index == 1
                                ? JamIcons.key
                                : JamIcons.picture,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text(
                        index == 0
                            ? "Home Screen"
                            : index == 1
                                ? "Lock Screen"
                                : "Both",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: index == 0
                          ? () async {
                              HapticFeedback.vibrate();
                              Navigator.of(context).pop();
                              _setHomeWallPaper(url);
                            }
                          : index == 1
                              ? () async {
                                  HapticFeedback.vibrate();
                                  Navigator.of(context).pop();
                                  _setLockWallPaper(url);
                                }
                              : () async {
                                  HapticFeedback.vibrate();
                                  Navigator.of(context).pop();
                                  _setBothWallPaper(url);
                                },
                    );
                  }),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                "Edit Wallpaper",
                style: Theme.of(context).textTheme.headline3,
              ),
              Container(
                margin: const EdgeInsets.only(left: 3, bottom: 5),
                decoration: BoxDecoration(
                    color: config.Colors().mainAccentColor(1),
                    borderRadius: BorderRadius.circular(500)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4),
                  child: Text(
                    "BETA",
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          leading: IconButton(
              icon: const Icon(JamIcons.close),
              onPressed: () {
                navStack.removeLast();
                debugPrint(navStack.toString());
                Navigator.pop(context);
              }),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            loading
                ? Container()
                : IconButton(
                    icon: const Icon(JamIcons.check),
                    onPressed: () async {
                      final imageFile = await saveFilteredImage();
                      onTapPaint(imageFile.path);
                    },
                  )
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: loading
              ? Center(child: Loader())
              : Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildFilteredImage(
                          _filter,
                          image,
                          filename,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: presetFiltersList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () => setState(() {
                                _filter = presetFiltersList[index];
                              }),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    _buildFilterThumbnail(
                                        presetFiltersList[index],
                                        image,
                                        filename),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      presetFiltersList[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .accentColor),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFilterThumbnail(
      Filter filter, imagelib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
                width: 90.0,
                height: 140.0,
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Loader(),
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return Container(
                width: 90.0,
                height: 140.0,
                color: Theme.of(context).primaryColor,
                child: Image(
                  image: MemoryImage(
                    snapshot.data as Uint8List,
                  ),
                  fit: BoxFit.cover,
                ),
              );
          }
          return null; // unreachable
        },
      );
    } else {
      return Container(
        width: 90.0,
        height: 140.0,
        color: Theme.of(context).primaryColor,
        child: Image(
          image: MemoryImage(
            cachedFilters[filter?.name ?? "_"] as Uint8List,
          ),
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    final imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter filter, imagelib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Loader());
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: Loader());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return PhotoView(
                imageProvider: MemoryImage(
                  snapshot.data as Uint8List,
                ),
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              );
          }
          return null; // unreachable
        },
      );
    } else {
      return PhotoView(
        imageProvider: MemoryImage(
          cachedFilters[filter?.name ?? "_"] as Uint8List,
        ),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      );
    }
  }
}

///The global applyfilter function
List<int> applyFilter(Map<String, dynamic> params) {
  final Filter filter = params["filter"] as Filter;
  final imagelib.Image image = params["image"] as imagelib.Image;
  final String filename = params["filename"] as String;
  List<int> _bytes = image.getBytes();
  if (filter != null) {
    filter.apply(_bytes as Uint8List, image.width, image.height);
  }
  final imagelib.Image _image =
      imagelib.Image.fromBytes(image.width, image.height, _bytes);

  return _bytes = imagelib.encodeNamedImage(_image, filename);
}

///The global buildThumbnail function
List<int> buildThumbnail(Map<String, dynamic> params) {
  final int width = params["width"] as int;
  params["image"] =
      imagelib.copyResize(params["image"] as imagelib.Image, width: width);
  return applyFilter(params);
}