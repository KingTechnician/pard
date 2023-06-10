
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:pard/main.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'color_schemes.g.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const LandingPage(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  static const snackBar = SnackBar(content:Text("Welcome to the Pard application!"));
  
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var items =[];
  var questChoices = [];
  Future<void> readJson() async
  {
    final String response = await rootBundle.loadString('assets/fullQuests.json');
    final data = await json.decode(response);
    setState(()
    {
      var grabItems = Map.from(data);
      for ( var i in grabItems.keys)
      {
        items.add(grabItems[i]);
      }
    });
  }
  // This widget is the root of your application.
  @override
  void initState()
  {
    super.initState();
    readJson();
  }
  @override
  Widget build(BuildContext context) {
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
        floatingActionButton:
            FloatingActionButton(onPressed: () => {Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return NewQuestModal(quests:items,filteredQuests:items);}))}, tooltip: 'Add Quest',child: const Icon(Icons.add),),
            drawer:
            Drawer(
                child: ListView(
    // Important: Remove any padding from the ListView.
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        child: Text("Menu"),
      ),
      Text("Open Quests",style:TextStyle(fontWeight:FontWeight.bold,fontSize:20)),
      Divider(color:darkColorScheme.primary),
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
      Divider(color:darkColorScheme.primary),
      ListTile(leading:const Icon(Icons.person),title:const Text("Equipment"),onTap:(){}),
      ListTile(leading:const Icon(Icons.settings),title:const Text("Settings"),onTap:(){}),
      ListTile(leading:const Icon(Icons.change_circle),title:const Text("Changelog"),onTap:(){}),
      ListTile(leading:const Icon(Icons.info),title:const Text("About"),onTap:(){}),
      ListTile(leading:const Icon(Icons.logout),title:const Text("Logout"),onTap:(){LandingPage.auth.signOut();Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Login();}));}),
    ],
  ),
            )
            );
  }
}

class LandingPage extends StatefulWidget{
  const LandingPage({Key? key}) : super(key: key);
  static final auth = FirebaseAuth.instance;
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body:LayoutBuilder(
        builder:(BuildContext context, BoxConstraints constraints)
        {
          if(constraints.maxWidth <=600)
          {
            return buildMobileLayout(context);
          }
          else
          {
            return buildDesktopLayout(context);
          }
        }
      )
    );
  }
}

Widget QuestList(List items)
{
  return ListView.builder(
    itemCount:items.length,
    itemBuilder:(context,index)
    {
      final item = items[index];

      return ListTile(title:item["name"],onTap:(){});
    }
  );
}


class NewQuestModal extends StatefulWidget {
  List<dynamic> quests;
  List<dynamic> filteredQuests;
  NewQuestModal({required this.quests,required this.filteredQuests});

  @override
  State<NewQuestModal> createState() => _NewQuestModalState();
}

class _NewQuestModalState extends State<NewQuestModal> {
  List<dynamic> get quests => widget.quests;
  List<dynamic> get filteredQuests => widget.filteredQuests;

  set quests(List<dynamic> value) {
    widget.quests = value;
  }

  set filteredQuests(List<dynamic> value)
  {
    widget.filteredQuests = value;
  }

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  int nextIndex = 0;
  int batchSize = 20;
  var subTitleStyle = TextStyle(fontSize:15,fontWeight:FontWeight.bold);

  void scrollListener()
  {
    if(scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange)
    {
      setState(()
      {
        nextIndex += batchSize;
      });
    }
  }

  void loadMoreData()
  {
    setState(()
    {
      nextIndex += batchSize;
    });
  }

  @override
  void initState()
  {
    super.initState();
    scrollController.addListener(scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:TextFormField(
          controller:searchController,
          decoration:InputDecoration(labelText:"Search here..."),
          onChanged:(value)
          {
            setState(()
            {
              filteredQuests = quests.where((element) => element["name"].contains(searchController.text)).toList();
            });
          }),
        actions:
        [
          IconButton(onPressed:(){},icon:const Icon(Icons.filter_alt)),
        ]
      ),
      body: Container(
        height:1300,
        child: ListView.builder(
          itemCount:filteredQuests.length,
          itemBuilder:(context,index)
          {
            
            return ExpansionTile(title:Text(filteredQuests[index]["name"]),children:
            [
              Container(
                color:Colors.black12,
                padding:EdgeInsets.all(20),
                width:double.infinity,
                child: Column(
                  children: [
                    Row(children:
                    [
                      Text(filteredQuests[index]["stars"].toString()),
                      Icon(Icons.star),
                      Text("${" "+filteredQuests[index]["rank"]+" "+filteredQuests[index]["category"]+" "+filteredQuests[index]["quest_type"]} quest")
                    ],
                    ),
                    Text("Location: "+filteredQuests[index]["location"],style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
                    Text("Monsters",style:subTitleStyle),
                    ListView.builder(
                      shrinkWrap:true,
                      physics:ClampingScrollPhysics(),
                      itemCount:filteredQuests[index]["monsters"].length,
                      itemBuilder:(monsterContext,monsterIndex)
                      {
                        if(monsterIndex==filteredQuests[index]["monsters"].length)
                        {
                          if(quests[index]["monsters"].length<100)
                          {
                            return const Center(child:CircularProgressIndicator(),);
                          }
                          else
                          {
                            return const SizedBox.shrink();
                          }
                        }
                        String required = filteredQuests[index]["monsters"][monsterIndex]["is_objective"] ? "Required" : "Not Required";
                        return ListTile(
                          title:Text("${filteredQuests[index]["monsters"][monsterIndex]["monster_name"]} (${required})"),
                          leading: Image.asset("assets/images/${filteredQuests[index]["monsters"][monsterIndex]["monster_id"]}.png"));
                      }
                    ),
                    Text("Prize: "+filteredQuests[index]["zenny"].toString()+" zenny"),
                    ElevatedButton(onPressed:(){},child:Text("Choose this quest")),
                  ],
                ),
              )
            ]);
          }
        ),
      )
    );
  }
}

class ForgotPassword extends StatelessWidget
{
  const ForgotPassword({Key? key}) : super(key:key);
  @override
  Widget build(BuildContext context)
  {
    return Stack(
      children:[buildBackgroundImage(),ForgotPasswordContent()]);
  }
}

class ForgotPasswordContent extends  StatefulWidget
{
  const ForgotPasswordContent({Key? key}) : super(key:key);
  static final TextEditingController _emailController=  TextEditingController();

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  Future<void> sendPasswordResetEmail(BuildContext context) async
  {
    await LandingPage.auth.sendPasswordResetEmail(email:ForgotPasswordContent._emailController.text)
    .then((value)
    {
      AnimatedSnackBar.rectangle("Success",
      "Reset email sent!",
      type:AnimatedSnackBarType.success,
      brightness:Brightness.dark).show(context);
      Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Login();}));
    })
    .then((error)
    {
      AnimatedSnackBar.rectangle("Error",
      error.toString(),
      type:AnimatedSnackBarType.error,
      brightness:Brightness.dark).show(context);
    });
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title:Text("Forgot Password"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              TextFormField(
                controller:ForgotPasswordContent._emailController,
                decoration:InputDecoration(
                  labelText:"Email",
                )
              ),
              SizedBox(height:16.0),
              ElevatedButton(
                child:Text("Send Reset Email"),
                onPressed:()
                {
                  sendPasswordResetEmail(context);
                },
              )
            ]
          )
        )
      )
    );
  }
}



class Register extends StatelessWidget
{
  const Register({Key? key}) : super(key:key);
  @override
  Widget build(BuildContext context)
  {
    return Stack(
      children:[buildBackgroundImage(),RegisterContent()]);
  }
}

class RegisterContent extends StatefulWidget {
  const RegisterContent({super.key});
  static bool termsAgreed = false;
  static bool showPassword = false;
  static final _auth = FirebaseAuth.instance;
  static final TextEditingController _emailController = TextEditingController();
  static final String emailChoice = _emailController.text;

  static final TextEditingController _passwordController = TextEditingController();
  static String passwordChoice = _passwordController.text;

  static final TextEditingController _confirmPasswordController = TextEditingController();
  static String confirmPasswordChoice = _confirmPasswordController.text;

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  void registerFirebaseAccount(String email, String password, String confirmPassword,BuildContext context)
async{
  if(password.compareTo(confirmPassword)==0)
  {
    try
    {
      await LandingPage.auth.createUserWithEmailAndPassword(email:email,password:password);
      Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Login();}));
    }
    catch(e)
    {
      AnimatedSnackBar.rectangle("Error",
      e.toString(),
      type:AnimatedSnackBarType.error,
      brightness:Brightness.dark).show(context);
    }
    return;
  }
}

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar:AppBar(title:Text("Register")),
      body:Center(
        child: Padding(padding: const EdgeInsets.all(16.0),
          child:Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:
            [
              TextFormField(
                controller: RegisterContent._emailController,
                decoration:InputDecoration(
                  labelText:'Email',
                ),
              ),
              SizedBox(height:16.0),
              TextFormField(
                controller: RegisterContent._passwordController,
                decoration:InputDecoration(
                  labelText:'Password',
                ),
                obscureText:!RegisterContent.showPassword,
              ),
              SizedBox(height:16.0),
              TextFormField(
                controller: RegisterContent._confirmPasswordController,
                decoration:InputDecoration(
                  labelText:'Confirm Password',
                ),
                obscureText:!RegisterContent.showPassword,
              ),
              SizedBox(height:16.0),
              Row(
                children:
                [
                  Checkbox(value:RegisterContent.showPassword,onChanged:(value){setState((){RegisterContent.showPassword=value!;});}),
                  Text("Show password")
                ]
              ),
              Row(
                children:
                [
                  Checkbox(
                    value:RegisterContent.termsAgreed,
                    onChanged:(value){setState((){RegisterContent.termsAgreed=value!;});},
                  ),
                  Text('I agree to the Terms of Service'),
                ],
              ),
              SizedBox(height:16.0),
              // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
              TextButton(onPressed:(){Navigator.push(context, MaterialPageRoute(builder:(BuildContext context){return Login();}));}, child:Text("Already have an account? Login here!")),
              ElevatedButton(
                onPressed:()
                {
                  registerFirebaseAccount(RegisterContent.emailChoice,RegisterContent._passwordController.text,RegisterContent._confirmPasswordController.text,context);
                  //Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Home();}));
                  // Implement sign-in functionality here
                  // Perform sign-in logic
                },
                child:Text('Sign Up'),
              ),
            ],
            )),));
  }
}

class Login extends StatelessWidget
{
  const Login({Key? key}) : super(key:key);
  @override
  Widget build(BuildContext context)
  {
    return Stack(
      children:[buildBackgroundImage(),LoginContent()]);
  }
}

class LoginContent extends StatefulWidget {
  
  static bool showPassword = false;
  static final TextEditingController _emailController = TextEditingController();
  static final String emailChoice = _emailController.text;
  static final TextEditingController _passwordController = TextEditingController();
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
  Future<void> loginFirebaseAccount(String username,String password, BuildContext context)
  async {
    await LandingPage.auth.signInWithEmailAndPassword(email:LoginContent._emailController.text,password:LoginContent._passwordController.text)
    .then((value) {
      LoginContent._emailController.text = "";
      LoginContent._passwordController.text = "";
      AnimatedSnackBar.rectangle("Success",
      "Successfully signed in!",
      type:AnimatedSnackBarType.success,
      brightness:Brightness.dark,).show(context);
      Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Home();}));
    },)
    .catchError((error)
    {
      AnimatedSnackBar.rectangle("Error",
      error.toString(),
      type:AnimatedSnackBarType.error,
      brightness:Brightness.dark).show(context);
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
                controller:LoginContent._emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller:LoginContent._passwordController,
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
                    onChanged: (value) {setState((){LoginContent.showPassword=value!;});},
                  ),
                  Text('Show password'),
                ],
              ),
              SizedBox(height: 16.0),
              // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
              TextButton(onPressed:(){Navigator.push(context, MaterialPageRoute(builder:(BuildContext context){return Register();}));}, child:Text("Don't have an account? Sign up here!")),
              TextButton(onPressed:(){Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return ForgotPassword();}));}, child:Text("Forgot Password?"),),
              ElevatedButton(
                onPressed: () {
                  loginFirebaseAccount(LoginContent.emailChoice,LoginContent.passwordChoice,context);
                  // Implement sign-in functionality here
                  // Perform sign-in logic
                },
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildMobileLayout(BuildContext context)
{
  return Stack(
    children:[
      buildBackgroundImage(),
      landingPageContent(context,CrossAxisAlignment.center)
    ]
  );
}

Widget buildDesktopLayout(BuildContext context)
{
  return Stack(
    children: [
      buildBackgroundImage(),
      Center(
        child: ConstrainedBox(
          constraints:const BoxConstraints(maxWidth:1200),
          child: landingPageContent(context,CrossAxisAlignment.center),
        ),)
    ],);
}


Widget buildBackgroundImage(){
return Container(
  decoration:const BoxDecoration(
    image:DecorationImage(
      image:AssetImage('assets/images/background.jpg'),
      fit:BoxFit.fitHeight,
    ),
    ),
    child:BackdropFilter(
      filter:ImageFilter.blur(sigmaX:0,sigmaY:0),
      child:Container(color:darkColorScheme.onPrimary.withOpacity(0.7))
    )
  );
}

Widget landingPageContent(BuildContext context, CrossAxisAlignment crossAxisAlignemnt)
{
  return Padding(
    padding:const EdgeInsets.all(32.0),
    child:Column(
      crossAxisAlignment: crossAxisAlignemnt,
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        SizedBox(height:16),
        SentMessage(message:"Need some advice for your next quest? Click or tap the button below to get started!"),
        SizedBox(height:32),
        ButtonTheme(minWidth:300.0,height:100.0,child:ElevatedButton(onPressed: ()
        {
          if(LandingPage.auth.currentUser!=null)
          {
            Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Home();}));
          }
          else
          {
            Navigator.push(context,MaterialPageRoute(builder: (context) => const Login()));
          }
        }, child:Text("Get Started")))
      ]
    ));
}




class SentMessage extends StatelessWidget {
  final String message;
  const SentMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: TypewriterText(
              duration:Duration(milliseconds:2000),
              text:message,
              style: TextStyle(color: Colors.white, fontFamily: 'Monstserrat', fontSize: 14),
            ),
          ),
        ),
        CustomPaint(painter: Triangle(Colors.grey[900]!)),
      ],
    ));

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

  TypewriterText({required this.text, required this.style, required this.duration});

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _textAnimation = IntTween(begin: 0, end: widget.text.length).animate(_controller);
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