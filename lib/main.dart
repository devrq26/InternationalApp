import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed to set portrait orientation.

  // Must wait until setPreferredOrientations is done before launching App.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    // Enable status bar for Android Apps.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Turn off the on-screen UI debug symbol
      debugShowCheckedModeBanner: false,

      // You cannot use App localizations here as the language modules have
      // not been initialised yet - hence set title to an empty string or
      // a constant string value which will not be changed
      // by a change in locale. Use the AppBar title instead.
      title: "",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        // The delegates are factories for producing localised values.
        AppLocalizations.delegate,   // Needed in the constructor to MaterialApp.
        GlobalMaterialLocalizations.delegate, // Provide localized strings for up to 113 locales (as of June 2023) for Material components
        GlobalWidgetsLocalizations.delegate,  // Defines default text directions, either left-to-right or right-to-left for widgets lib
        GlobalCupertinoLocalizations.delegate, // Provide localized strings for up to 113 locales (as of June 2023) for Cupertino widgets
      ],
      supportedLocales: const <Locale> [
        // You can set supported languages and regions but not script codes.
        // If you need to set the language script code, then you need to use
        // Locale.fromSubtags() - see my LinkedIn article for this project.
        Locale('en'), // English - base file for all countries incl. US locale
        Locale('en', 'AU'), // English - Australia (region)
        Locale('en', 'GB'), // English - UK (region)
        Locale('en', 'MY'), // English - Malaysia (region)
        ],
      // You cannot use App localizations here as the language modules have
      // not been initialised yet - hence set title to an empty string or
      // a constant string value which will not be changed
      // by a change in locale. Use the AppBar title instead.
      home: const MyHomePage(title: ""),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Let App react to lifecycle messages and when the locale is changed
class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;
  late String defaultLocale;
  Locale? _locale;  // Initialised to null by Flutter

  @override
  void initState() {
    super.initState();
    // Register an observer for system locale change notifications.
    WidgetsBinding.instance.addObserver(this);
    // Gets called after the last frame of the page is drawn.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setLocale(context));
  }

  @override
  void dispose() {
    // Remove binding when App is destroyed.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This is called on system locale changes when user changes
  // the device language. WidgetsBindingObserver interface has a method called
  // didChangeLocales() which we override here to change _locale which allows
  // us the show the current system locale to the user.
  // NOTE: This method is triggered when the user changes the language for an associated region,
  // eg English(Australia), English(Great Britain), English(Malaysia), etc. and the region
  // will be taken from this. The separate region set in Android like when we choose
  // English (Malaysia) but set the region to Australia, the region setting will be ignored
  // and instead will be displayed as en-MY not the expected en-AU.
  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    setState(() {
      _locale = locales?.first ?? _locale;
    });
  }

  // Set the _locale from the build context. Can now display locale to users.
  setLocale(BuildContext context) {
    // This gets the locale of the device based on the current BuildContext.
    final Locale locale = Localizations.localeOf(context);

    setState(() {
      _locale = locale;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context)!.appName),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Show localised strings. Note country tags,
            // ie _US, _AU, _GB in main_line_1 to show
            // which .arb file is being used.
            Text(AppLocalizations.of(context)!.main_line_1),
            Text(AppLocalizations.of(context)!.main_line_2),
            Text(AppLocalizations.of(context)!.main_line_3),
            const SizedBox(height: 50),
            // Show language, country & script codes for current system locale.
            // NOTE: Country and script codes are taken from the language setting NOT
            // the regional setting.
            Text('Locale: ${_locale?.languageCode}-${_locale?.countryCode}-${_locale?.scriptCode}'),
            // On Android, Platform.localeName will not change while Application
            // is running, even if user adjusts their language setting. User must force-kill and
            // restart the App. Platform.localeName not reliable if change occurs while App is running.
            Text('Platform locale: ${Platform.localeName}'),
            Text('Current date:'),
            Text('${Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)?.formatFullDate(DateTime.now())}'),
            Text('Current time zone:'),
            Text('${DateTime.now().timeZoneName} (offset ${DateTime.now().timeZoneOffset})'),
            const SizedBox(height: 100),
            Text(AppLocalizations.of(context)!.main_label_times_button_pushed),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: AppLocalizations.of(context)!.main_counter_increment_tool_tip,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
