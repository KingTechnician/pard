
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'color_schemes.g.dart';

void main() {
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
            FloatingActionButton(onPressed: () => {Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return NewQuestModal();}))}, tooltip: 'Increment',child: const Icon(Icons.add),),
            drawer:
            Drawer(
                child: ListView(
    // Important: Remove any padding from the ListView.
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        child: Text('Menu'),
      ),
      Text("Quests",style:TextStyle(fontWeight:FontWeight.bold,fontSize:20)),
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

class LoginContent extends StatelessWidget {
  const LoginContent({
    super.key,
  });

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
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  Text('I agree to the Terms of Service'),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder:(BuildContext context){return Home();}));
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