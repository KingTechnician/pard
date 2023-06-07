
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'color_schemes.g.dart';

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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  static const snackBar = SnackBar(content:Text("Welcome to the Pard application!"));

  
  // This widget is the root of your application.
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
            FloatingActionButton(onPressed: () => {Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return NewQuestModal();}))}, tooltip: 'Add Quest',child: const Icon(Icons.add),),
            drawer:
            Drawer(
                child: ListView(
    // Important: Remove any padding from the ListView.
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        child: Text('Menu'),
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
      ListTile(leading:const Icon(Icons.logout),title:const Text("Logout"),onTap:(){Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Login();}));}),
    ],
  ),
            )
            );
  }
}

class LandingPage extends StatelessWidget{
  const LandingPage({Key? key}) : super(key: key);
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


class NewQuestModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modal Dialog'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ),
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

class ForgotPasswordContent extends  StatelessWidget
{
  const ForgotPasswordContent({Key? key}) : super(key:key);
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
                decoration:InputDecoration(
                  labelText:"Email",
                )
              ),
              SizedBox(height:16.0),
              ElevatedButton(
                child:Text("Send Reset Email"),
                onPressed:(){Navigator.push(context, MaterialPageRoute(builder:(BuildContext context){return Login();}));},
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
  void registerFirebaseAccount(String email, String password, String confirmPassword,FirebaseAuth auth,BuildContext context)
async{
  if(password.compareTo(confirmPassword)==0)
  {
    try
    {
      await auth.createUserWithEmailAndPassword(email:email,password:password);
      Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Login();}));
    }
    catch(e)
    {
      print(e);
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
                  registerFirebaseAccount(RegisterContent.emailChoice,RegisterContent._passwordController.text,RegisterContent._confirmPasswordController.text,RegisterContent._auth,context);
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
  static final _auth = FirebaseAuth.instance;
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
  void loginFirebaseAccount(String username,String password, BuildContext context)
  {
    try
    {
      LoginContent._auth.signInWithEmailAndPassword(email:username,password:password);
      Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Home();}));
    }
    catch(e)
    {
      print(e);
    }
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
        ButtonTheme(minWidth:300.0,height:100.0,child:ElevatedButton(onPressed: (){Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );}, child:Text("Get Started")))
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