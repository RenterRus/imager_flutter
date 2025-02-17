import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';

void main() {
 // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
     // home:  const InitPage(),
      home:  const MyHomePage(title: "title"),
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
  State<MyHomePage> createState() => FullScreenPage();
}






class FullScreenPage extends State<MyHomePage>  {
  late String adr = "";
  late int timeSleep;



ImageProvider im = AssetImage("assets/images/white.jpg"); 
Timer? timer;
Timer? rtime;
bool view = false;
bool floatVisible = false;
bool settingView = true;
var battery = Battery();
String data = TimeOfDay.now().toString() ;
var percentage = 100;

Color? textColor = Color.fromARGB(255, 78, 6, 233);
 


void getBatteryPercentage() async {
  final batteryLevel = await battery.batteryLevel;
  this.percentage= batteryLevel;
}


void updStat(){
  // Обновляем статистику по батарее и времени
  getBatteryPercentage();
  view = true;
  data = '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year} ${TimeOfDay.now().hour}:${TimeOfDay.now().minute} $percentage%';
  NetworkImage bufImage = NetworkImage('http://$adr/img?${DateTime.now().millisecondsSinceEpoch.toString()}');
  // Рябим черный и белый
  Timer.run(() =>  setState(() {
    floatVisible = false;
    im = AssetImage("assets/images/black.jpg");
    textColor =  Color.fromARGB(255, 0, 0, 0);   
  }));
    
  Timer(const Duration(seconds: 2), () => setState(() {
    im = AssetImage("assets/images/black.jpg");
    textColor =  Color.fromARGB(255, 255, 255, 255);   
  }));

  Timer(const Duration(seconds: 5), () => setState(() {
    im = AssetImage("assets/images/white.jpeg");
    textColor =  Color.fromARGB(255, 0, 0, 0);
  }));

  Timer(const Duration(seconds: 8), () => setState(() {
    im = AssetImage("assets/images/white.jpeg");
    textColor =  Color.fromARGB(255, 255, 255, 255);
  }));

  Timer(const Duration(seconds: 10), () => setState(() {
    im = bufImage;
    textColor =  Color.fromARGB(0, 255, 255, 255);
    floatVisible = true;
  }));
}


@override
  void initState() {
    super.initState();
}


@override
void dispose() {
  timer?.cancel();
  super.dispose();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);  // to re-show bars

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(     
      decoration: BoxDecoration(
        image:  DecorationImage(
          image: im,
          fit: BoxFit.fill
        ) ,
      ),


    child: Column(
      children: [
        Container(
          padding: EdgeInsets.only(top:250, bottom: 10, left: 20, right: 20),
          child:     Visibility(
            visible: view,
            child: Align(
              alignment: Alignment.center,
                child: Text(
                  data,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 40,
                  ),
                ),
              ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top:50, bottom: 10, left: 20, right: 20),
          child:     Visibility(
          visible: settingView,
          
          child: Column(
            children: [
        TextField(
                decoration: InputDecoration(
                  hintText: "addr"
                ),
                textAlign: TextAlign.center,
                onChanged: (text){
                  adr = text;
                },
            ),
             
        TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "time in minutes"
                ),
                textAlign: TextAlign.center,
                onChanged: (text){
                  timeSleep = int.parse(text);
                },
            ), 
            
        ElevatedButton(onPressed: ()=>setState((){
                settingView = false;
                view = true;
                floatVisible = true;
                updStat();
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
                  SystemUiOverlay.bottom
                ]);  

                timer = Timer.periodic(Duration(minutes: timeSleep), (timer) {
                  setState(() {
                    updStat();
                  });
                });

                rtime = Timer.periodic(const Duration(seconds: 20), (rtime) {
                    setState(() {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
                      SystemUiOverlay.bottom
                    ]);  // to only hide the status bar
                  });
                });
              }), child: Text("start"))
             
            ],
        ),
       ),
        ),
    
      
      ],
    ),
    ),
     floatingActionButton: Visibility(
      visible: floatVisible,
      child: FloatingActionButton(
        onPressed: updStat,
        tooltip: 'Next',
        backgroundColor: Color.fromARGB(0, 237, 237, 237),
        foregroundColor: Color.fromARGB(104, 26, 25, 25),
        focusColor: Color.fromARGB(0, 26, 25, 25),
        hoverColor: Color.fromARGB(38, 237, 237, 237),
        splashColor: Color.fromARGB(0, 26, 25, 25),
        child: const Icon(Icons.skip_next),
      ),
     ),
    );
    
    
  }
}