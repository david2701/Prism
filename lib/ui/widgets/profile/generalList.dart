import 'package:Prism/routes/routing_constants.dart';
import 'package:Prism/theme/jam_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:Prism/theme/toasts.dart' as toasts;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:Prism/main.dart' as main;
import 'package:Prism/theme/themeModel.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:Prism/theme/config.dart' as config;

class GeneralList extends StatefulWidget {
  @override
  _GeneralListState createState() => _GeneralListState();
}

class _GeneralListState extends State<GeneralList> {
  bool optWall = (main.prefs.get('optimisedWallpapers') ?? true) as bool;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(
        JamIcons.wrench,
      ),
      title: Text(
        "General",
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.w500,
            fontFamily: "Proxima Nova"),
      ),
      subtitle: Text(
        "Change app look & settings",
        style: TextStyle(fontSize: 12, color: Theme.of(context).accentColor),
      ),
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, themeViewRoute, arguments: [
              Provider.of<ThemeModel>(context, listen: false).currentTheme,
              Color(main.prefs.get("mainAccentColor") as int),
              Provider.of<ThemeModel>(context, listen: false).returnThemeIndex(
                Provider.of<ThemeModel>(context, listen: false).currentTheme,
              )
            ]);
          },
          leading: const Icon(JamIcons.wrench),
          title: Text(
            "Themes",
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w500,
                fontFamily: "Proxima Nova"),
          ),
          subtitle: const Text(
            "Toggle app theme",
            style: TextStyle(fontSize: 12),
          ),
        ),
        ListTile(
            leading: const Icon(
              JamIcons.pie_chart_alt,
            ),
            title: Text(
              "Clear Cache",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: const Text(
              "Clear locally cached images",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () async {
              DefaultCacheManager().emptyCache();
              PaintingBinding.instance.imageCache.clear();
              await Hive.box('wallpapers').deleteFromDisk();
              await Hive.openBox('wallpapers');
              await Hive.box('collections').deleteFromDisk();
              await Hive.openBox('collections');
              await Hive.box('setups').deleteFromDisk();
              await Hive.openBox('setups');
              toasts.codeSend("Cleared cache!");
            }),
        SwitchListTile(
            activeColor: config.Colors().mainAccentColor(1),
            secondary: const Icon(
              JamIcons.dashboard,
            ),
            value: optWall,
            title: Text(
              "Wallpaper Optimisation",
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Proxima Nova"),
            ),
            subtitle: optWall
                ? const Text(
                    "Disabling this might lead to High Internet Usage",
                    style: TextStyle(fontSize: 12),
                  )
                : const Text(
                    "Enable this to optimise Wallpapers according to your device",
                    style: TextStyle(fontSize: 12),
                  ),
            onChanged: (bool value) async {
              setState(() {
                optWall = value;
              });
              main.prefs.put('optimisedWallpapers', value);
            }),
        ListTile(
          onTap: () {
            main.RestartWidget.restartApp(context);
          },
          leading: const Icon(JamIcons.refresh),
          title: Text(
            "Restart App",
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w500,
                fontFamily: "Proxima Nova"),
          ),
          subtitle: const Text(
            "Force the application to restart",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
