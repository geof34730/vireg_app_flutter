import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Verbes irréguliers en anglais'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InterstitialAd? _interstitialAd;
  final String _adUnitId = (Platform.isAndroid ? dotenv.get("GOOGLE_ADD_ANDROID_INTERSTITIAL") : dotenv.get("GOOGLE_ADD_IOS_INTERSTITIAL"));
  int _showInterstitialNbVerbs = 5;
  int _compteurInterstitial = 0;

  bool _choseListVers = false;

  TextEditingController controllerFrancais = TextEditingController();
  TextEditingController controllerInfinitif = TextEditingController();
  TextEditingController controllerPastSimple = TextEditingController();
  TextEditingController controllerPastParticipe = TextEditingController();

  String StockFrancais = "";
  String StockInfinitif = "";
  String StockPastSimple = "";
  String StockPastParticipe = "";

  List _verb = [];
  String? ListTypeVerbSelect = null;

  bool defaultFrancais=false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  void _loadAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void manageInsterstitial() {
    if (_compteurInterstitial == 1) {
      _loadAd();
    }
    if (_compteurInterstitial == 0) {
      _interstitialAd?.show();
    }
    if (_compteurInterstitial == _showInterstitialNbVerbs - 1) {
      _compteurInterstitial = 0;
    } else {
      _compteurInterstitial++;
    }
  }

  Future<void> readJson({required typeListe, required}) async {
    manageInsterstitial();
    final String response = await rootBundle.loadString('assets/data/$typeListe.json');
    final dynamic data = await json.decode(response);
    List _verbs = [];
    int numberVerbData = 0;
    ListTypeVerbSelect = typeListe;
    int randomNumberCarbData = Random().nextInt(data.length);
    StockFrancais = data[randomNumberCarbData]['francais'];
    StockInfinitif = data[randomNumberCarbData]['infinitif'];
    StockPastSimple = data[randomNumberCarbData]['pastSimple'];
    StockPastParticipe = data[randomNumberCarbData]['pastParticipe'];

    controllerFrancais.text = "";
    controllerInfinitif.text = "";
    controllerPastSimple.text = "";
    controllerPastParticipe.text = "";



    switch (Random().nextInt(4)) {
      case 0:
        controllerFrancais.text = data[randomNumberCarbData]['francais'];
        defaultFrancais=true;
        break;
      case 1:
        controllerInfinitif.text = data[randomNumberCarbData]['infinitif'];
        break;
      case 2:
        controllerPastSimple.text = data[randomNumberCarbData]['pastSimple'];
        break;
      case 3:
        controllerPastParticipe.text = data[randomNumberCarbData]['pastParticipe'];
        break;
    }
    setState(() {
      _choseListVers = true;
    });
  }

  bool goNextVerb() {
    if (controllerFrancais.text.toUpperCase() == StockFrancais.toUpperCase() &&
        controllerInfinitif.text.toUpperCase() == StockInfinitif.toUpperCase() &&
        controllerPastSimple.text.toUpperCase() == StockPastSimple.toUpperCase() &&
        controllerPastParticipe.text.toUpperCase() == StockPastParticipe.toUpperCase()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
              theme: ThemeData(
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 12.00, bottom: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Colors.blue),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Colors.transparent),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Colors.red),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Color(0xFF455A64)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Color(0xFF455A64)),
                      borderRadius: BorderRadius.circular(5),
                    )),
                brightness: Brightness.light,
                primarySwatch: Colors.blue,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.blue,
                  iconTheme: IconThemeData(color: Colors.white),
                  actionsIconTheme: IconThemeData(color: Colors.white),
                  centerTitle: true,
                  elevation: 15,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                timePickerTheme: const TimePickerThemeData(
                  backgroundColor: Colors.red,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                dataTableTheme:
                    DataTableThemeData(headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue), headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.red,
                  elevation: 15.00,
                ),
              ),
              title: 'Vireg',
              home: Scaffold(
                  appBar: (_choseListVers
                  ?
                  AppBar(
                            toolbarHeight: 50.0,
                            leading: Builder(
                              builder: (BuildContext context) {
                                return (_choseListVers
                                    ? IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          setState(() {
                                            _choseListVers = false;
                                          });
                                        },
                                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                                      )
                                    : SizedBox());
                              },
                            ),
                            title: Text(
                              widget.title,
                              style: GoogleFonts.pacifico(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                  )
                              ),
                            ),
                          )
                  :
                  AppBar(
                            toolbarHeight: 50.0,
                            title: Text(
                              widget.title,
                              style: GoogleFonts.pacifico(
                                  textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                              )),
                            ),
                          )
                  ),
                  body: SingleChildScrollView(
                      child: (
                          _choseListVers
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 30.00),
                                      child: TextFormField(
                                        controller: controllerFrancais,
                                        maxLength: StockFrancais.length,
                                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                        onChanged: (value) {
                                          if (controllerFrancais.text.length <= StockFrancais.length) {
                                            setState(() {});
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            icon: writeContentAndStyleIcon(controllerField: controllerFrancais, stockValue: StockFrancais),
                                            hintText: 'Français',
                                            labelText: 'Français',
                                            enabledBorder:OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerFrancais, stockValue: StockFrancais))),
                                            focusedBorder:OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerFrancais, stockValue: StockFrancais))),
                                            suffixIcon: (controllerFrancais.text.toUpperCase() == StockFrancais.toUpperCase()
                                                ? null
                                                : IconButton(
                                                    icon: Icon(Icons.visibility, color: getBorderColor(controllerField: controllerFrancais, stockValue: StockFrancais)),
                                                    onPressed: () {
                                                      setState(() {
                                                        controllerFrancais.text = StockFrancais;
                                                      });
                                                    },
                                                  ))),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00),
                                      child: TextFormField(
                                        controller: controllerInfinitif,
                                        maxLength: StockInfinitif.length,
                                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                        onChanged: (value) {
                                          if (controllerInfinitif.text.length <= StockInfinitif.length) {
                                            setState(() {});
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            icon: writeContentAndStyleIcon(controllerField: controllerInfinitif, stockValue: StockInfinitif),
                                            hintText: 'Infinitif',
                                            labelText: 'Infinitif',
                                            enabledBorder:
                                                OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerInfinitif, stockValue: StockInfinitif))),
                                            focusedBorder:
                                                OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerInfinitif, stockValue: StockInfinitif))),
                                            suffixIcon: (controllerInfinitif.text.toUpperCase() == StockInfinitif.toUpperCase()
                                                ? null
                                                : IconButton(
                                                    icon: Icon(Icons.visibility, color: getBorderColor(controllerField: controllerInfinitif, stockValue: StockInfinitif)),
                                                    onPressed: () {
                                                      setState(() {
                                                        controllerInfinitif.text = StockInfinitif;
                                                      });
                                                    },
                                                  ))),
                                        validator: (val) => val == '' ? "Merci de saisir l'Infinitif" : null,
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00),
                                      child: TextFormField(
                                        controller: controllerPastSimple,
                                        maxLength: StockPastSimple.length,
                                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                        onChanged: (value) {
                                          if (controllerPastSimple.text.length <= StockPastSimple.length) {
                                            setState(() {});
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            icon: writeContentAndStyleIcon(controllerField: controllerPastSimple, stockValue: StockPastSimple),
                                            hintText: 'Past simple',
                                            labelText: 'Past simple',
                                            enabledBorder:
                                                OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerPastSimple, stockValue: StockPastSimple))),
                                            focusedBorder:
                                                OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerPastSimple, stockValue: StockPastSimple))),
                                            suffixIcon: (controllerPastSimple.text.toUpperCase() == StockPastSimple.toUpperCase()
                                                ? null
                                                : IconButton(
                                                    icon: Icon(Icons.visibility, color: getBorderColor(controllerField: controllerPastSimple, stockValue: StockPastSimple)),
                                                    onPressed: () {
                                                      setState(() {
                                                        controllerPastSimple.text = StockPastSimple;
                                                      });
                                                    },
                                                  ))),
                                        validator: (val) => val == '' ? "Merci de saisir le Past simple" : null,
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00),
                                      child: TextFormField(
                                        controller: controllerPastParticipe,
                                        maxLength: StockPastParticipe.length,
                                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                        onChanged: (value) {
                                          if (controllerPastParticipe.text.length <= StockPastParticipe.length) {
                                            setState(() {});
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            icon: writeContentAndStyleIcon(controllerField: controllerPastParticipe, stockValue: StockPastParticipe),
                                            hintText: 'Past participe',
                                            labelText: 'Past participe',
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerPastParticipe, stockValue: StockPastParticipe))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: controllerPastParticipe, stockValue: StockPastParticipe))),
                                            suffixIcon: (controllerPastParticipe.text.toUpperCase() == StockPastParticipe.toUpperCase()
                                                ? null
                                                : IconButton(
                                                    icon: Icon(Icons.visibility, color: getBorderColor(controllerField: controllerPastParticipe, stockValue: StockPastParticipe)),
                                                    onPressed: () {
                                                      setState(() {
                                                        controllerPastParticipe.text = StockPastParticipe;
                                                      });
                                                    },
                                                  ))),
                                        validator: (val) => val == '' ? "Merci de saisir le Past participe" : null,
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            controllerFrancais.text = StockFrancais;
                                            controllerInfinitif.text = StockInfinitif;
                                            controllerPastSimple.text = StockPastSimple;
                                            controllerPastParticipe.text = StockPastParticipe;
                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.visibility,
                                            size: 19.0,
                                          ),
                                          label: const Text("Solution", style: TextStyle(fontSize: 19)),
                                        ),
                                        (goNextVerb()
                                            ? Padding(
                                                padding: const EdgeInsets.only(left: 20.0),
                                                child: ElevatedButton.icon(
                                                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green), foregroundColor: MaterialStatePropertyAll(Colors.white)),
                                                  onPressed: () {
                                                    readJson(typeListe: ListTypeVerbSelect);
                                                  },
                                                  icon: const Icon(
                                                    Icons.check,
                                                    size: 19.0,
                                                  ),
                                                  label: const Text("Suivant", style: TextStyle(fontSize: 19)),
                                                ))
                                            : Padding(
                                                padding: const EdgeInsets.only(left: 20.0),
                                                child: ElevatedButton.icon(
                                                  style: ButtonStyle(),
                                                  onPressed: null,
                                                  icon: const Icon(
                                                    Icons.check,
                                                    size: 19.0,
                                                  ),
                                                  label: const Text("Suivant", style: TextStyle(fontSize: 19)),
                                                )))
                                      ]))
                                ],
                              ),
                            )
                          : Center(
                              child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      child:boxCard(
                                        colorBackground: Colors.green,
                                        titleCard:"DEBUTANT",
                                        sousTitre: "TOP 20 des verbes irréguliers les plus utilisés",
                                      ),
                                    onTap: () {
                                      readJson(typeListe: 'listDebutant');
                                      },
                                    ),
                                    InkWell(
                                      child:boxCard(
                                      colorBackground: Colors.deepOrange,
                                      titleCard:"INTERMEDIAIRE",
                                      sousTitre: "TOP 100 des verbes irréguliers les plus utilisés"
                                    ),
                                    onTap: () {
                                      readJson(typeListe: 'listIntermediaire');
                                      },
                                    ),
                                    InkWell(
                                      child:boxCard(
                                      colorBackground: Colors.red,
                                      titleCard:"AVANCE",
                                      sousTitre: "Tous Les verbes irréguliers"
                                    ),
                                    onTap: () {
                                      readJson(typeListe: 'listAvance');
                                      },
                                    ),
                                  ]
                              )
                          )
                      )
                  )
              )
          );
        });
  }
}

Container boxCard({required Color colorBackground,required String titleCard,required String sousTitre,}){
  return Container(
    padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 20.00),
        child: Card(
          shadowColor: Colors.grey,
          color: colorBackground,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
             child:Padding(
                 padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.00,bottom:10.00),
                 child:ListTile(
                    leading: const Icon (
                        Icons.list,
                        color: Colors.white,
                        size: 40
                    ),
                    title: Text(
                      titleCard,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      sousTitre,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                      ),
                    ),
                  ),
                 )
          ),
    );
}

String stockValueNoDescription({required stockValue}){
  if(stockValue.indexOf('(')>=0) {
    int positionBeginDescription = stockValue.indexOf('(')-1;
    int positionEndDescription = stockValue.indexOf(')');
    String newStockValue = stockValue.substring(0, positionBeginDescription);
    return newStockValue;
  }
  else {
    return stockValue;
  }
}

Icon writeContentAndStyleIcon({required TextEditingController controllerField, required String stockValue}) {
  if (controllerField.text != '') {
    if (getErrorField(controllerField:controllerField,stockValue:stockValue )){
      return const Icon(Icons.error, color: Colors.red);
    }
  }
  if (controllerField.text == "") {
    return const Icon(Icons.question_answer, color: Colors.blue);
  }
  if (getSuccesField(controllerField:controllerField,stockValue:stockValue )) {
    controllerField.value = TextEditingValue(
      text: stockValue,
      selection: TextSelection.collapsed(offset: stockValue.length),
    );

    return const Icon(Icons.check, color: Colors.green);
  } else {
    return const Icon(Icons.question_answer, color: Colors.blue);
  }
}

bool getErrorField({required TextEditingController controllerField, required String stockValue}){
  String controllerValue = controllerField.text.toUpperCase();
  stockValue = stockValue.toUpperCase();
  return stockValueNoDescription(stockValue:stockValue).substring(0, stockValueNoDescription(stockValue:controllerValue).length)!=stockValueNoDescription(stockValue:controllerValue);
}

bool getSuccesField({required TextEditingController controllerField, required String stockValue}) {
  String controllerValue = controllerField.text.toUpperCase();
  stockValue = stockValue.toUpperCase();
  return stockValueNoDescription(stockValue:controllerValue) == stockValueNoDescription(stockValue:stockValue);
}

Color getBorderColor({required TextEditingController controllerField, required String stockValue}) {
  if (controllerField.text != '') {
    if (getErrorField(controllerField:controllerField,stockValue:stockValue )){
      return Colors.red;
    }
  }
  if (controllerField.text == "") {
    return Colors.blue;
  }
  if (getSuccesField(controllerField:controllerField,stockValue:stockValue )) {
    return Colors.green;
  } else {
    return Colors.blue;
  }
}


