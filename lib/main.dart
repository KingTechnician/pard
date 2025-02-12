
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:encrypt/encrypt.dart' as cryptLibrary;
import 'package:encrypt/encrypt_io.dart';
import 'package:pard/quest_models.dart';

import 'dart:ui';
import 'package:basic_utils/basic_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:pard/main.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'discord_options.dart';
import 'firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'color_schemes.g.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import 'storage_item.dart';
import 'storage_service.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const devEnv = false;
  void discordLoginAndHandle(Map<String,dynamic> value)
  {
    var uriData = Uri.parse(html.window.location.href); 
    LandingPage.auth.signInWithCustomToken(value["custom_token"]);
    if(uriData.queryParameters["code"] != null && uriData.queryParameters["state"] != null) {
    {
      var newUri = uriData.replace(queryParameters:{});
      html.window.history.pushState(null,'Pard',newUri.toString());
      //launchUrlString(Uri.base.origin,webOnlyWindowName:'_self');
      //exchangeCode(uriData.queryParameters["code"]!,uriData.queryParameters["state"]!).then((value) => {LandingPage.auth.signInWithCustomToken(value["custom_token"])});
    }}
  }
    Future<Map<String, dynamic>> exchangeCode(String code,String state) async {
   
  var data = json.encode(<String,String>{
    'code': code,
    'state':state,
    'redirect_uri': Uri.base.origin
  });
  var headers = <String,String>{
    'Content-Type': 'application/json'
  };
  const apiPath = MyApp.devEnv ? "http://127.0.0.1:5000" : "https://pard-rest.onrender.com";
  var response = await http.post(
    Uri.parse('$apiPath/discordLogin'),
    body: data,
    headers: headers,
    // Basic authentication
    // The credentials are encoded in base64
    // clientId:clientSecret
  );

  if (response.statusCode == 200) {
    print("Response body:");
    return json.decode(response.body);
  } else {
    throw Exception(response.body);
  }
}
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const LandingPage(),
       onGenerateRoute: (RouteSettings settings) {
    Widget? pageView;
    if (settings.name != null) {
      var uriData = Uri.parse(settings.name!);
      exchangeCode(uriData.queryParameters["code"]!,uriData.queryParameters["state"]!).then(
        (value) => 
        {
          discordLoginAndHandle(value)
        });
        //Check if code and state are present
      //exchangeCode
      //uriData.path will be your path and uriData.queryParameters will hold query-params values
 
      switch (uriData.path) {
        case '/':
          pageView = LandingPage();
          break;
        //....
      }
    }
    if (pageView != null) {
      return MaterialPageRoute(
          builder: (BuildContext context) => pageView!);
    }
  },
    );
  }
}

class Equipment extends StatefulWidget {
  const Equipment({Key? key}) : super(key: key);
  @override
  State<Equipment> createState() => _EquipmentState();
}


class _EquipmentState extends State<Equipment>{
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex:0,
      length:4,
      child: Scaffold(
        drawer: const MainMenu(),
        appBar: AppBar(
          title: Text("Equipment"),
          bottom: TabBar(
          tabs: [
            Tab(
              text: "Weapons",
            ),
            Tab(
              text: "Armor",
            ),
            Tab(
              text: "Summary",
            ),
            Tab(
              text:"Sets"
            )
          ],
        ),
        ),
        //ArmorSelectionScreen
        body: TabBarView(children: [
          Center(child:Text("Weapons will be displayed here. You'll be able to see attack, rarity, and other cool stuff like that.")),
          ArmorSearch(),
          EquipmentSummary(),
          Center(child:Text("This will be the sets page. You can see your saved sets here."))
        ],)
      ),
    );
  }
}

class ArmorSearch extends StatefulWidget {
  ArmorSearch({
    super.key,
  });

  @override
  State<ArmorSearch> createState() => _ArmorSearchState();
}

class _ArmorSearchState extends State<ArmorSearch> {
  List<dynamic> armorData = [];
  List<dynamic> filteredArmorData = [];
  void loadArmor() async{
  var armor = await rootBundle.loadString("assets/data/armorPieceFrame.json");
  var armorDecoded = json.decode(armor);
  print(armorDecoded[0]);
  setState((){armorData = json.decode(armor); filteredArmorData = armorData;});
  
  }

  final TextEditingController searchController = TextEditingController();


  @override
  void initState()
  {
    super.initState();
    loadArmor();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false,
        title: TextFormField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Search here..."),
                onChanged: (value) {
                  setState(() {
                    filteredArmorData = armorData
                        .where((element) =>
                            element["name_en"].contains(searchController.text))
                        .toList();
                  });                  
                }),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.filter_alt)),
            ]
      ),
      body: 
      ListView.builder(
        itemCount:filteredArmorData.length,
        itemBuilder: (context,index){
          Map<String,String> iconMap = {
            "head":"assets/images/equipment/ic_equipment_head_base.svg",
            "chest":"assets/images/equipment/ic_equipment_chest_base.svg",
            "arms": "assets/images/equipment/ic_equipment_arm_base.svg",
            "waist":"assets/images/equipment/ic_equipment_waist_base.svg",
            "legs":"assets/images/equipment/ic_equipment_leg_base.svg"

          };
          var alpha = 180;
          var rarityColors = [Color.fromARGB(alpha, 204,199,205),Color.fromARGB(alpha, 193,189,193),Color.fromARGB(alpha, 149,172,101),Color.fromARGB(alpha, 111,152,111),Color.fromARGB(alpha,178,220,245),Color.fromARGB(alpha,107,104,208),Color.fromARGB(alpha,93,22,103),Color.fromARGB(alpha,181,125,83),Color.fromARGB(alpha,167,75,77),Color.fromARGB(alpha,134,207,241),Color.fromARGB(alpha,196,171,96),Color.fromARGB(alpha,220,236,249)];
          var type = filteredArmorData[index]["type"];
          var textStyle = TextStyle(fontSize:15,fontWeight:FontWeight.bold);
          return ExpansionTile(
            title: Text(filteredArmorData[index]["name_en"],style:TextStyle(color:rarityColors[filteredArmorData[index]["rarity"]-1])),
            children:[
              Container(
                color:Colors.black12,
                padding:EdgeInsets.all(20),
                width:double.infinity,
                child:Column(
                  children:[
                    Text("Stats",style:TextStyle(fontSize:20,fontWeight:FontWeight.bold),textAlign: TextAlign.left),
                    Divider(color:rarityColors[filteredArmorData[index]["rarity"]-1]),
                    Row(children:[Text("Rarity "+filteredArmorData[index]["rarity"].toString(),style:TextStyle(fontSize:15,fontWeight:FontWeight.bold,color:rarityColors[filteredArmorData[index]["rarity"]-1]))]),
                    Row(children:[SvgPicture.asset("assets/images/ui/ic_ui_defense.svg",width:20,height:20),Text("Defense: "+filteredArmorData[index]["defense_base"].toString(),style:textStyle)]),
                    Row(children:[SvgPicture.asset("assets/images/ui/ic_element_fire.svg",width:20,height:20),Text("Vs. Fire: "+filteredArmorData[index]["defense_fire"].toString(),style:textStyle)]),
                    Row(children:[SvgPicture.asset("assets/images/ui/ic_element_water.svg",width:20,height:20),Text("Vs. Water: "+filteredArmorData[index]["defense_water"].toString(),style:textStyle)]),
                    Row(children:[SvgPicture.asset("assets/images/ui/ic_element_thunder.svg",width:20,height:20),Text("Vs. Thunder: "+filteredArmorData[index]["defense_thunder"].toString(),style:textStyle)]),
                    Row(children:[SvgPicture.asset("assets/images/ui/ic_element_ice.svg",width:20,height:20),Text("Vs. Ice: "+filteredArmorData[index]["defense_ice"].toString(),style:textStyle)]),
                    Row(children:[SvgPicture.asset("assets/images/ui/ic_element_dragon.svg",width:20,height:20),Text("Vs. Dragon: "+filteredArmorData[index]["defense_dragon"].toString(),style:textStyle)]),

                  ]
                )
              )
            ]
          );
        }
      ));
  }
}

class EquipmentSummary extends StatelessWidget {
  const EquipmentSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[ArmorSelectionScreen(),ToolSelectionScreen()]);
  }
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);
  static const snackBar =
      SnackBar(content: Text("Welcome to the Pard application!"));

  @override
  State<Home> createState() => _HomeState();
}



class _HomeState extends State<Home> {
  List<Quest> items = [];
  List<Quest> questChoices = [];
  User? user = LandingPage.auth.currentUser;
  StorageService asyncStorage = StorageService();
  String token = "";
  var db = FirebaseFirestore.instance;
  bool runOnce = true;
  String apiPath = MyApp.devEnv ? "http://127.0.0.1:5000" : "https://pard-rest.onrender.com";
  String localPath = "http://127.0.0.1:5000/";
  //Asynchronous function for grabbing user token
  void getToken() async {
    await user!.getIdToken().then((value) {
      setState(() {});
    });
  }


  void readPublicKey(String token) {
    var keyPair = CryptoUtils.generateRSAKeyPair(keySize:2048);
    //var currentPublicKey = await asyncStorage.readSecureData("publicKey");
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/fullQuests.json');
    final data = await json.decode(response);
    setState(() {
      var grabItems = Map.from(data);
      items = grabItems.entries.map((entry) => 
        Quest.fromJson(entry.value as Map<String, dynamic>, entry.key)
      ).toList();
    });
  }

  void checkUserInformation() {
    final documentRef = db.collection("users").doc(user!.uid);
    documentRef.get().then((doc) {
      if (doc.data() == null) {
        user!.getIdToken().then((value) async {
        });
      } else {
        user!.getIdToken().then((value) async {
        });
        setState(() {
          AnimatedSnackBar.rectangle(
                  "Success", "Data integrated. Welcome back!",
                  type: AnimatedSnackBarType.success,
                  brightness: Brightness.dark)
              .show(context);
        });
      }
    });
  }

  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    if (runOnce) {
      checkUserInformation();
      runOnce = false;
    }
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: Text("Pard"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Welcome! Click the button on the bottom right and get started.',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return NewQuestModal(quests: items, filteredQuests: items);
            }))
          },
          tooltip: 'Add Quest',
          child: const Icon(Icons.add),
        ),
        drawer: MainMenu());
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text("Menu"),
          ),
          Text("Open Quests",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Divider(color: darkColorScheme.primary),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          Divider(color: darkColorScheme.primary),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return Home();
              }));
            },
          ),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Equipment"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return Equipment();
                }));
              }),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.change_circle),
              title: const Text("Changelog"),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                LandingPage.auth.signOut();
                //Pop all previous history
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false);
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return Login();
                }));
              }),
        ],
      ),
    );
  }
}


String randomPassword() {
  final random = Random();
  String finalPassword = '';
  
  for (int i = 0; i < 35; i++) {
    bool useLetter = random.nextInt(2) == 1;
    String randomLetter = String.fromCharCode(random.nextInt(26) + (random.nextBool() ? 65 : 97));
    String randomNumber = random.nextInt(10).toString();
    finalPassword += useLetter ? randomLetter : randomNumber;
  }

  return finalPassword;
}


class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);
  static final auth = FirebaseAuth.instance;
  //Set redirectUri to current domain
  static final String redirectUri = Uri.base.origin;
  @override
  State<LandingPage> createState() => _LandingPageState();


}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth <= 600) {
        return buildMobileLayout(context);
      } else {
        return buildDesktopLayout(context);
      }
    }));
  }
}

Widget QuestList(List items) {
  return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(title: item["name"], onTap: () {});
      });
}

class ArmorSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0), // Adjust padding as needed
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.0), // Slightly transparent black background
      ),
      child: Column(
        children: <Widget>[
          const EquipmentMenuItem(iconPath: 'assets/images/equipment/ic_equipment_head_empty.svg', title: '[Head not selected]'),
          const EquipmentMenuItem(iconPath:'assets/images/equipment/ic_equipment_chest_empty.svg', title: '[Chest not selected]'),
          const EquipmentMenuItem(iconPath:"assets/images/equipment/ic_equipment_waist_empty.svg", title: '[Waist not selected]'),
          const EquipmentMenuItem(iconPath:"assets/images/equipment/ic_equipment_leg_empty.svg", title: '[Legs not selected]'),

        ]
      ),
    );
  }
}

class ToolSelectionScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding:EdgeInsets.all(16.0),
      decoration:BoxDecoration(
        color:Colors.black.withOpacity(0.0)
      ),
      child:Column(
        children: <Widget>[
          const EquipmentMenuItem(iconPath:"assets/images/equipment/ic_equipment_weapon_empty.svg",title:"[Weapon not selected]"),
          const EquipmentMenuItem(iconPath:"assets/images/equipment/ic_equipment_charm_empty.svg",title:"[Charm not selected]"),
          const EquipmentMenuItem(iconPath:"assets/images/equipment/ic_equipment_mantle_base.svg",title:"[Mantle not selected]"),
          const EquipmentMenuItem(iconPath:"assets/images/equipment/ic_equipment_weapon_empty.svg",title:"[Tool not selected]"),
        ]
      )
    );
  }
}

class EquipmentMenuItem extends StatelessWidget {
  final String iconPath;
  final String title;

  const EquipmentMenuItem({Key? key, required this.iconPath, required this.title}) : super(key: key);

    @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            iconPath,
            width: MediaQuery.of(context).size.width*0.02, // Adjust size as needed
            height: MediaQuery.of(context).size.height*0.02, // Adjust size as needed
            placeholderBuilder: (BuildContext context) => Container(
              padding: const EdgeInsets.all(10.0),
              child: const CircularProgressIndicator(),
            ),
          ),
          SizedBox(width: 16.0),
          Text(title, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class NewQuestModal extends StatefulWidget {
  List<Quest> quests;
  List<Quest> filteredQuests;
  NewQuestModal({required this.quests, required this.filteredQuests});

  @override
  State<NewQuestModal> createState() => _NewQuestModalState();
}

class _NewQuestModalState extends State<NewQuestModal> {
  List<Quest> get quests => widget.quests;
  List<Quest> get filteredQuests => widget.filteredQuests;

  set quests(List<Quest> value) {
    widget.quests = value;
  }

  set filteredQuests(List<Quest> value) {
    widget.filteredQuests = value;
  }

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  int nextIndex = 0;
  int batchSize = 20;
  var subTitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        nextIndex += batchSize;
      });
    }
  }

  void loadMoreData() {
    setState(() {
      nextIndex += batchSize;
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: TextFormField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Search here..."),
                onChanged: (value) {
                  setState(() {
                    filteredQuests = quests
                        .where((element) =>
                            element.name.contains(searchController.text))
                        .toList();
                  });
                }),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.filter_alt)),
            ]),
        body: Container(
          height: 1300,
          child: ListView.builder(
              itemCount: filteredQuests.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                    title: Text(filteredQuests[index].name),
                    children: [
                      Container(
                        color: Colors.black12,
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(filteredQuests[index].stars.toString()),
                                Icon(Icons.star),
                                Text(
                                    "${" " + filteredQuests[index].rank + " " + filteredQuests[index].category + " " + filteredQuests[index].questType} quest")
                              ],
                            ),
                            Text(
                                "Location: " +
                                    filteredQuests[index].location,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Monsters", style: subTitleStyle),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount:
                                    filteredQuests[index].monsters.length,
                                itemBuilder: (monsterContext, monsterIndex) {
                                  if (monsterIndex ==
                                      filteredQuests[index].monsters.length) {
                                    if (filteredQuests[index].monsters.length <
                                        100) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }
                                  String required = filteredQuests[index]
                                          .monsters[monsterIndex]
                                          .isObjective
                                      ? "Required"
                                      : "Not Required";
                                  return ListTile(
                                      title: Text(
                                          "${filteredQuests[index].monsters[monsterIndex].monsterName} (${required})"),
                                      leading: Image.asset(
                                          "assets/images/monster/${filteredQuests[index].monsters[monsterIndex].monsterId}.png"));
                                }),
                            Text("Prize: " +
                                filteredQuests[index].zenny.toString() +
                                " zenny"),
                            ElevatedButton(
                              onPressed: () => {
                                showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(filteredQuests[index].name),
                                  content: const Text(
                                      'Create a chat for this quest?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                    quest:
                                                        filteredQuests[index],
                                                    title:
                                                        "${filteredQuests[index].name}",
                                                    id: filteredQuests[index].id),
                                                    ));
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              )},
                              child: const Text('Choose this quest'),
                            )
                          ],
                        ),
                      )
                    ]);
              }),
        ));
  }
}

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [buildBackgroundImage(), ForgotPasswordContent()]);
  }
}

class ForgotPasswordContent extends StatefulWidget {
  const ForgotPasswordContent({Key? key}) : super(key: key);
  static final TextEditingController _emailController = TextEditingController();

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  Future<void> sendPasswordResetEmail(BuildContext context) async {
    await LandingPage.auth
        .sendPasswordResetEmail(
            email: ForgotPasswordContent._emailController.text)
        .then((value) {
      AnimatedSnackBar.rectangle("Success", "Reset email sent!",
              type: AnimatedSnackBarType.success, brightness: Brightness.dark)
          .show(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return Login();
      }));
    }).then((error) {
      AnimatedSnackBar.rectangle("Error", error.toString(),
              type: AnimatedSnackBarType.error, brightness: Brightness.dark)
          .show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password"),
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                          controller: ForgotPasswordContent._emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                          )),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        child: Text("Send Reset Email"),
                        onPressed: () {
                          sendPasswordResetEmail(context);
                        },
                      )
                    ]))));
  }
}

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [buildBackgroundImage(), RegisterContent()]);
  }
}

class RegisterContent extends StatefulWidget {
  const RegisterContent({super.key});
  static bool termsAgreed = false;
  static bool showPassword = false;
  static final _auth = FirebaseAuth.instance;
  static final TextEditingController _emailController = TextEditingController();
  static final String emailChoice = _emailController.text;

  static final TextEditingController _passwordController =
      TextEditingController();
  static String passwordChoice = _passwordController.text;

  static final TextEditingController _confirmPasswordController =
      TextEditingController();
  static String confirmPasswordChoice = _confirmPasswordController.text;

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  void registerFirebaseAccount(String email, String password,
      String confirmPassword, BuildContext context) async {
    if (password.compareTo(confirmPassword) == 0) {
      try {
        await LandingPage.auth
            .createUserWithEmailAndPassword(email: email, password: password);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Login();
        }));
      } catch (e) {
        AnimatedSnackBar.rectangle("Error", e.toString(),
                type: AnimatedSnackBarType.error, brightness: Brightness.dark)
            .show(context);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Register")),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: RegisterContent._emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: RegisterContent._passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: !RegisterContent.showPassword,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: RegisterContent._confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: !RegisterContent.showPassword,
                  ),
                  SizedBox(height: 16.0),
                  Row(children: [
                    Checkbox(
                        value: RegisterContent.showPassword,
                        onChanged: (value) {
                          setState(() {
                            RegisterContent.showPassword = value!;
                          });
                        }),
                    Text("Show password")
                  ]),
                  Row(
                    children: [
                      Checkbox(
                        value: RegisterContent.termsAgreed,
                        onChanged: (value) {
                          setState(() {
                            RegisterContent.termsAgreed = value!;
                          });
                        },
                      ),
                      Text('I agree to the Terms of Service'),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
                  TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return Login();
                        }));
                      },
                      child: Text("Already have an account? Login here!")),
                  ElevatedButton(
                    onPressed: () {
                      registerFirebaseAccount(
                          RegisterContent.emailChoice,
                          RegisterContent._passwordController.text,
                          RegisterContent._confirmPasswordController.text,
                          context);
                      //Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Home();}));
                      // Implement sign-in functionality here
                      // Perform sign-in logic
                    },
                    child: Text('Sign Up'),
                  ),
                ],
              )),
        ));
  }
}

class Login extends StatelessWidget {
  Login({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [buildBackgroundImage(), LoginContent()]);
  }
}

class LoginContent extends StatefulWidget {
  static bool showPassword = false;
  static final TextEditingController _emailController = TextEditingController();
  static final String emailChoice = _emailController.text;
  static final TextEditingController _passwordController =
      TextEditingController();
  static String passwordChoice = _passwordController.text;
  const LoginContent({
    super.key,
  });

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  get auth => FirebaseAuth.instance;
  get snackBar => AnimatedSnackBar;
  //Read query parameters
  //Set redirectUri to current domain
  String redirectUri = Uri.base.origin;
  var user = null;

  
  void loginWithDiscord()
  {
    const apiPath = MyApp.devEnv ? "http://127.0.0.1:5000" : "https://pard-rest.onrender.com";
    var data = json.encode(<String,String>{
    'redirect_uri': Uri.base.origin
  });
  var headers = <String,String>{
    'Content-Type': 'application/json'
  };
    http.post(Uri.parse(apiPath+"/discordAuthLink"),body:data,headers:headers).then((value) => value.body).then((value) => launchUrlString(json.decode(value)["url"],webOnlyWindowName:"_self"));
  }


  Future<void> loginFirebaseAccount(
      String username, String password, BuildContext context) async {
      //FlutterWebAuth2.authenticate(url:discordUrl, callbackUrlScheme: "localhost")
      //.then((value)=>{print(value)});
    await LandingPage.auth
        .signInWithEmailAndPassword(
            email: LoginContent._emailController.text,
            password: LoginContent._passwordController.text)
        .then(
      (value) {
        setState(() {
          user = value.user;
        });
        LoginContent._emailController.text = "";
        LoginContent._passwordController.text = "";
        AnimatedSnackBar.rectangle(
          "Success",
          "Successfully signed in!",
          type: AnimatedSnackBarType.success,
          brightness: Brightness.dark,
        ).show(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return const Home();
        }));
      },
    ).catchError((error) {
      AnimatedSnackBar.rectangle("Error", error.toString(),
              type: AnimatedSnackBarType.error, brightness: Brightness.dark)
          .show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: LoginContent._emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: LoginContent._passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: !LoginContent.showPassword,
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: LoginContent.showPassword,
                    onChanged: (value) {
                      setState(() {
                        LoginContent.showPassword = value!;
                      });
                    },
                  ),
                  Text('Show password'),
                ],
              ),
              SizedBox(height: 16.0),
              // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Register();
                    }));
                  },
                  child: Text("Don't have an account? Sign up here!")),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return ForgotPassword();
                  }));
                },
                child: Text("Forgot Password?"),
              ),
              ElevatedButton(
                onPressed: () {
                  loginFirebaseAccount(LoginContent.emailChoice,
                      LoginContent.passwordChoice, context);
                  // Implement sign-in functionality here
                  // Perform sign-in logic
                },
                child: Text('Sign In'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed:() {
                  loginWithDiscord();
                },
                child:Text("Sign in with Discord (recommended)"),
                style:ElevatedButton.styleFrom(
                  disabledBackgroundColor:Color(0x005865f2),
                  backgroundColor: Color.fromARGB(0, 46, 61, 231),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildMobileLayout(BuildContext context) {
  return Stack(children: [
    buildBackgroundImage(),
    landingPageContent(context, CrossAxisAlignment.center)
  ]);
}

Widget buildDesktopLayout(BuildContext context) {
  return Stack(
    children: [
      buildBackgroundImage(),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: landingPageContent(context, CrossAxisAlignment.center),
        ),
      )
    ],
  );
}

Widget buildBackgroundImage() {
  return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(color: darkColorScheme.onPrimary.withOpacity(0.7))));
}

Widget landingPageContent(
    BuildContext context, CrossAxisAlignment crossAxisAlignemnt) {
  return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
          crossAxisAlignment: crossAxisAlignemnt,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            SentMessage(
                message:
                    "Need some advice for your next quest? Click or tap the button below to get started!",
                fromUser: false),
            SizedBox(height: 32),
            ButtonTheme(
                minWidth: 300.0,
                height: 100.0,
                child: ElevatedButton(
                    onPressed: () {
                      if (LandingPage.auth.currentUser != null) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return const Home();
                        }));
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      }
                    },
                    child: Text("Get Started")))
          ]));
}

class SentMessage extends StatelessWidget {
  final String message;
  final bool fromUser;
  const SentMessage({
    Key? key,
    required this.message,
    required this.fromUser,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var messageTextGroup = null;
    if (!fromUser) {
      messageTextGroup = Flexible(
          child: Row(
        mainAxisAlignment:
            fromUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment:
            fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: fromUser
                    ? lightColorScheme.tertiary
                    : Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: TypewriterText(
                duration: Duration(milliseconds: 2000),
                text: message,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Monstserrat',
                    fontSize: 14),
              ),
            ),
          ),
          CustomPaint(
              painter: Triangle(fromUser
                  ? lightColorScheme.tertiary
                  : Theme.of(context).primaryColorDark)),
        ],
      ));
    } else {
      messageTextGroup = Flexible(
          child: Row(
        mainAxisAlignment:
            fromUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment:
            fromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          CustomPaint(
              painter: Triangle(fromUser
                  ? lightColorScheme.tertiary
                  : Theme.of(context).primaryColorDark)),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: fromUser
                    ? lightColorScheme.tertiary
                    : Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: TypewriterText(
                duration: Duration(milliseconds: 1000),
                text: message,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Monstserrat',
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ));
    }

    return Padding(
      padding: EdgeInsets.only(right: 18.0, left: 50, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}

class Triangle extends CustomPainter {
  final Color bgColor;

  Triangle(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  TypewriterText(
      {required this.text, required this.style, required this.duration});

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _textAnimation =
        IntTween(begin: 0, end: widget.text.length).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        String text = widget.text.substring(0, _textAnimation.value);
        return Text(
          text,
          style: widget.style,
        );
      },
    );
  }
}

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.title, required this.quest, required this.id})
      : super(key: key);

  final String title;
  final Quest quest;
  final String id;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  get title => widget.title;
  get quest => widget.quest;
  get id => widget.id;
  var db = FirebaseFirestore.instance;
  String currentPublicKey = "";
  String apiPath = MyApp.devEnv ? "http://127.0.0.1:5000" : "https://pard-rest.onrender.com";
  String localPath = "http://127.0.0.1:5000/";
  bool isLoading = false;
  List<List<dynamic>> chatHistory = [];
  TextEditingController messageController = TextEditingController();
  var chatChildren = <Widget>[];
  ScrollController scrollController = ScrollController();
  void scrollToEnd() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent + 100);
  }

  Future<void> startConversationChain() async {
    setState((){isLoading=true;});
    LandingPage.auth.currentUser!.getIdToken().then((value) async {
      var uri = Uri.parse("$apiPath/startChain");
      var response = await http.post(uri,
          body: json.encode({"token": value, "quest": title}));
      var data = json.decode(response.body);
      setState(() {
        chatChildren.removeLast();
        chatChildren.add(SentMessage(message: data["answer"], fromUser: false));
        scrollToEnd();
        isLoading = false;
      });
    });
  }
  void sendMessage(String value, TextEditingController messageController) {
    setState(() {
      var uri = Uri.parse("$apiPath/sendAndReceive");
      isLoading = true;
      chatChildren.add(SentMessage(message: value, fromUser: true));
      scrollToEnd();
      chatChildren.add(CircularProgressIndicator());
      scrollToEnd();
      //Wait 2 seconds before receivign a response
      LandingPage.auth.currentUser!.getIdToken().then((token)
      async {    
        var response = await http.post(uri,
            body:json.encode({"token":token,"questId":id,"message":value}));
        var data = json.decode(response.body);
        
      setState(() {
          chatChildren.removeLast();
          chatChildren.add(SentMessage(message: data["answer"], fromUser: false));
          scrollToEnd();
          isLoading = false;
        });
      });
      messageController.clear();
      
    });
  }

  @override
  void initState() {
    chatChildren.add(questInformation(quest, context));
    chatChildren.add(CircularProgressIndicator());
    startConversationChain();
    // Scroll to the end of the SingleChildScrollView after the UI is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("Save Quest?"),
              content: const Text('Save this quest?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Yes');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Home()));
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'No');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return const Home();
                    }));
                  },
                  child: const Text('No'),
                ),
              ],
            ),
          ),
        ),
        title: Text(widget.title),
      ),
      body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: chatChildren,
            ),
          )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                maxLength:720,
                autofocus:true,
                enabled:isLoading ? false : true,
                maxLines: 2,
                controller: messageController,
                decoration: InputDecoration(
                    labelText: 'Type your message here',
                    border: OutlineInputBorder(),
                    suffix: ElevatedButton(
                        child: Icon(Icons.send),
                        onPressed: () {
                          sendMessage(messageController.text,messageController);
                        })),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget questInformation(Quest quest, BuildContext context) {
  var subTitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
  return Container(
    color: Colors.black12,
    padding: EdgeInsets.all(20),
    width: double.infinity,
    child: Column(
      children: [
        Row(
          children: [
            Text(quest.stars.toString()),
            Icon(Icons.star),
            Text(
                "${" " + quest.rank + " " + quest.category + " " + quest.questType} quest")
          ],
        ),
        Text("Location: " + quest.location,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Monsters", style: subTitleStyle),
        ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: quest.monsters.length,
            itemBuilder: (monsterContext, monsterIndex) {
              if (monsterIndex == quest.monsters.length) {
                if (quest.monsters.length < 100) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }
              String required = quest.monsters[monsterIndex].isObjective
                  ? "Required"
                  : "Not Required";
              return ListTile(
                  title: Text(
                      "${quest.monsters[monsterIndex].monsterName} (${required})"),
                  leading: Image.asset(
                      "assets/images/monster/${quest.monsters[monsterIndex].monsterId}.png"));
            }),
        Text("Prize: " + quest.zenny.toString() + " zenny"),
      ],
    ),
  );
}
