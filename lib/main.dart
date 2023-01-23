import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:diacritic/diacritic.dart';

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

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "verb_$typeListe");
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
        designSize: const Size(1920, 1080),
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
                    centerTitle: true,
                            toolbarHeight: 50,
                            leadingWidth: 50,
                            leading: Builder(
                              builder: (BuildContext context) {
                                return (_choseListVers
                                    ? IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          setState(() {
                                            _compteurInterstitial=0;
                                            _choseListVers = false;
                                          });
                                        },
                                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                                      )
                                    : SizedBox());
                              },
                            ),
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 50.0),
                                        child:Image.asset(
                                       'assets/images/logo.png',
                                        fit: BoxFit.contain,
                                        height: 180,
                                    ),
                                  )
                              ],
                            ),

                          )
                  :
                  AppBar(
                            toolbarHeight: 50,
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Image.asset(
                                   'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    height: 180,
                                ),
                              ],

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
                                    TextFormVireg(ControlerField:controllerFrancais,StockField: StockFrancais,labelField: "Français",firstField: true),
                                    TextFormVireg(ControlerField:controllerInfinitif,StockField: StockInfinitif,labelField: "Infinitif" ),
                                    TextFormVireg(ControlerField:controllerPastSimple,StockField: StockPastSimple,labelField: "Past simple" ),
                                    TextFormVireg(ControlerField:controllerPastParticipe,StockField: StockPastParticipe,labelField: "Past participe" ),
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
                                    Padding(
                                      padding: const EdgeInsets.only( top: 10.00),
                                      child:InkWell(
                                        child:boxCard(
                                          colorBackground: Colors.green,
                                          titleCard:"DEBUTANT",
                                          sousTitre: "TOP 20 des verbes irréguliers les plus utilisés",

                                        ),
                                      onTap: () {
                                        readJson(typeListe: 'listDebutant');
                                        },
                                      )
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

  Widget TextFormVireg({required String StockField,required TextEditingController ControlerField, required String labelField,bool firstField =false}){
   return Padding(
      padding:  EdgeInsets.only(left: 10.0, right: 10.0, top: (firstField ? 25.00 : 10.00)),

          child:TextFormField(

            enabled: !getSuccesField(stockValue: StockField,controllerField: ControlerField),
            controller: ControlerField,
            maxLength: StockField.length,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            onChanged: (value) {
              if (ControlerField.text.length <= StockField.length) {
                setState(() {});
              }
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                icon: writeContentAndStyleIcon(controllerField: ControlerField, stockValue: StockField),
                hintText: labelField,
                labelText: labelField,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder:OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: ControlerField, stockValue: StockField))),
                focusedBorder:OutlineInputBorder(borderSide: BorderSide(width: 2, color: getBorderColor(controllerField: ControlerField, stockValue: StockField))),
                disabledBorder: OutlineInputBorder(borderSide: const BorderSide(width: 2, color: Colors.green),borderRadius: BorderRadius.circular(5),),
                suffixIcon: (ControlerField.text.toUpperCase() == StockField.toUpperCase()
                    ? null
                    : IconButton(
                        icon: Icon(Icons.visibility, color: getBorderColor(controllerField: ControlerField, stockValue: StockField)),
                        onPressed: () {
                          ControlerField.text = StockField;
                          setState(() {
                          });
                        },
                      ))),

          )

    );
  }
}


Container boxCard({required Color colorBackground,required String titleCard,required String sousTitre}){
  return Container(
    padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.00),
        child: Card(
          shadowColor: Colors.grey,
          color: colorBackground,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
             child:Padding(
                 padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.00,bottom:5.00),
                 child:ListTile(
                    leading: const Icon (
                        Icons.list,
                        color: Colors.white,
                        size: 40.00
                    ),
                    title: Text(
                      titleCard,
                      style: GoogleFonts.sourceSansPro(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 100.sp,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                    ),
                    subtitle: Text(
                      sousTitre,
                      style: GoogleFonts.kanit(
                            textStyle: GoogleFonts.sourceSansPro(
                              color: Colors.white,
                              fontSize: 60.sp,
                              height:5.sp
                            )
                        ),
                    ),
                  ),
                 )
          ),
    );
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

Icon writeContentAndStyleIcon({required TextEditingController controllerField, required String stockValue}) {
  if(stockValue.indexOf("/")>=0){
    dynamic arrayVerb=stockValueNoDescription(stockValue:stockValue).split(" / ");
    for (var verb in arrayVerb) {
      if(controllerField.text.toUpperCase().indexOf(' / ')>0){
        int posNewSaisiVerbe=controllerField.text.toUpperCase().indexOf(' / ')+3;
        int nbSeparatorVerb = '/'.allMatches(stockValue).length;
        //JUSTE SECON VERB
        if(nbSeparatorVerb>'/'.allMatches(controllerField.text).length) {
          String newText = controllerField.text.substring(posNewSaisiVerbe, controllerField.text.length);
          if (newText.toUpperCase() == verb.toUpperCase()) {
            controllerField.value = TextEditingValue(
              text: "${controllerField.text} / ",
              selection: TextSelection.collapsed(offset: "${controllerField.text} / ".length),
            );
          }
        }
      }
      else {
        if (controllerField.text.toUpperCase() == verb.toUpperCase()) {
          controllerField.value = TextEditingValue(
            text: "$verb / ",
            selection: TextSelection.collapsed(offset: "$verb / ".length),
          );
        }
      }
    }
  }
  if (controllerField.text != '') {
    if (getErrorField(controllerField:controllerField,stockValue:stockValue)){
      return const Icon(Icons.error, color: Colors.red);
    }
  }
  if (controllerField.text == "") {
    return const Icon(Icons.question_answer, color: Colors.blue);
  }
  if (getSuccesField(controllerField:controllerField,stockValue:stockValue)) {
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
  dynamic arrayVerb=stockValueNoDescription(stockValue:stockValue).split(" / ");
  if(stockValue.indexOf("/")>=0){
    if(controllerField.text.indexOf("/")<0) {
     ///FIRST VERB EN SAISIE IN THE FIELD
      for (var verb in arrayVerb) {
        if(verb.length>=stockValueNoDescription(stockValue:controllerValue).length){
           if (verb.substring(0, stockValueNoDescription(stockValue: controllerValue).length) == stockValueNoDescription(stockValue: controllerValue)) {
                return false;
              }
          }
      }
      return true;
    }
    else{
       dynamic arrayVerbControllerField = stockValueNoDescription(stockValue: controllerField.text).split(" / ");
      ///SECOND VERB EN SAISIE IN THE FIELD
      for (var verb in arrayVerb) {
         int positionSaisie2=stockValueNoDescription(stockValue: controllerValue).indexOf(' / ')+3;
         if(controllerValue.length>positionSaisie2) {
            String saisie2=stockValueNoDescription(stockValue: controllerValue).substring(positionSaisie2,stockValueNoDescription(stockValue: controllerValue).length);
            if(saisie2.indexOf('/')>0){
             // saisie 3
              int positionSaisie3=saisie2.indexOf(' / ')+3;
              String saisie3=saisie2.substring(positionSaisie3,saisie2.length);
              for (var verb in arrayVerb) {
                  if (verb.indexOf(saisie3) >= 0) {
                    return false;
                  }
                }
               return true;
            }
            else {
                //saisie 2
                for (var verb in arrayVerb) {
                  if (verb.indexOf(saisie2) >= 0) {
                    int nbSeparatorVerb = '/'.allMatches(stockValue).length;
                    return false;
                  }
                }
                return true;
            }
         }
         else{
           return false;
         }
      }
    }
  }
  else {
   return stockValueNoDescription(stockValue: stockValue).substring(0, stockValueNoDescription(stockValue: controllerValue).length) != stockValueNoDescription(stockValue: controllerValue);
  }
  return false;
}

bool getSuccesField({required TextEditingController controllerField, required String stockValue}) {
  String controllerValue = controllerField.text.toUpperCase();
  stockValue = stockValue.toUpperCase();
  dynamic arrayVerb=stockValueNoDescription(stockValue:stockValue).split(" / ");
  if(stockValue.indexOf("/")>=0){
    if(controllerField.text.indexOf("/")<0) {
     ///FIRST VERB EN SAISIE IN THE FIELD
      for (var verb in arrayVerb) {
        if(verb.length>=stockValueNoDescription(stockValue:controllerValue).length) {
          if (verb.substring(0, stockValueNoDescription(stockValue: controllerValue).length) == stockValueNoDescription(stockValue: controllerValue)) {
            return false;
          }
        }
      }
    }
    else{
      ///SECOND VERB EN SAISIE IN THE FIELD
      dynamic arrayVerbControllerField = stockValueNoDescription(stockValue: controllerField.text).split(" / ");
      for (var verb in arrayVerb) {
         int positionSaisie2=stockValueNoDescription(stockValue: controllerValue).indexOf(' / ')+3;
         if(controllerValue.length>positionSaisie2) {
            String saisie2=stockValueNoDescription(stockValue: controllerValue).substring(positionSaisie2,stockValueNoDescription(stockValue: controllerValue).length);
            if(saisie2.indexOf('/')>0){
              //saisie 3
              int positionSaisie3=saisie2.indexOf(' / ')+3;
              String saisie3=saisie2.substring(positionSaisie3,saisie2.length);
              for (var verb in arrayVerb) {
                  if (saisie3!="" && verb.toUpperCase() == saisie3.toUpperCase()) {
                    return true;
                  }
                }
              return false;
            }
            else {
                for (var verb in arrayVerb) {
                  if (verb.toUpperCase()==saisie2.toUpperCase()) {
                    int nbSeparatorVerb = '/'.allMatches(stockValue).length;
                    if(nbSeparatorVerb==1) {
                      return true;
                    }
                  }
                }
            }
            return false;
         }
         else{
          return false;
         }
      }
    return false;
    }
    return false;
  }
  return stockValueNoDescription(stockValue:controllerValue) == stockValueNoDescription(stockValue:stockValue);
}

String stockValueNoDescription({required stockValue}){
  if(stockValue.indexOf('(')>=0) {
    int nbDescriptionVerb = '('.allMatches(stockValue).length;
    String newStockValue=stockValue;
      for (var i = 0; i < nbDescriptionVerb; i = i + 1) {
          int positionBeginDescription = newStockValue.indexOf('(')-1;
          int positionEndDescription = newStockValue.indexOf(')')+1;
          String stringDelete=newStockValue.substring(positionBeginDescription, positionEndDescription);
          newStockValue = newStockValue.replaceAll(stringDelete, '');
    }
    return removeDiacritics(newStockValue);
  }
  else {
    return removeDiacritics(stockValue);
  }
}



