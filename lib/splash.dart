import 'package:flutter/material.dart'; // flutter ki basic UI library import ki hai
import 'dart:async'; // async operations (jaise Timer) ke liye import
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication use karne ke liye

import 'home.dart'; // home screen file import
import 'login.dart'; // login screen file import

class SplashScreen extends StatefulWidget { // class splashscreen ka mtlb ha k hmari screen jo app ma show hogi us ka name splashscreen ha or extend kisi chez ki properties inherit karny k lye use hota ha mtlb splashscreen statefulwidget ki properties inherit kar rahi ha or statefulwidget dynamic changes k lye use kea ha kun k hmari app ma animations han to dynamic app ha hamri is lye
  const SplashScreen({super.key}); // ye constructor constructor ha jis ma super.key ka mtlb ha parent class ki key yahan parent class statefulwidget ha or key us ko uniquely identify kar rahi ha ta k confusion na ho or app dynamic ho

  @override
  State<SplashScreen> createState() => _SplashScreenState(); // override bta raha ha k createState aik function ha jo statefulwidget ma already hota ha bas hum usy apni class ma ues kar rahy han
} //State<SplashScreen> ka matlab hai ye State class SplashScreen widget ke liye ha

class _SplashScreenState extends State<SplashScreen>//_splashscreenstate aik class ha jo dynamic bhaviour ko handle kary gi splash screen ma or underscore ka mtlb ha k ye private ha
    with SingleTickerProviderStateMixin { // animation ke liye ticker provider use kiya, ticker time ko handle karta ha

  late AnimationController _controller; // animation control karne ke liye controller
  late Animation<double> _fadeAnimation; // fade (opacity) animation
  late Animation<double> _scaleAnimation; // scale (zoom in/out) animation

  @override
  void initState() {
    super.initState(); // parent class ka initState call kiya

    _controller = AnimationController(
      vsync: this, // screen ke frame ke sath sync karta hai animation ko
      duration: const Duration(milliseconds: 1800), // animation ka total time (1.8 sec)
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(//tween means in between mtlb animation ka start or end btany k lye begin 0 means invisible and end 1 means fully visible
      CurvedAnimation(parent: _controller, curve: Curves.easeIn), // or _controller bta raha ha k controller kon ha animation ka yahan contorller wo ha jis ma 1800 ms time rakha ha easein means aram aram  visible hone wali animation
    );

    _scaleAnimation = Tween<double>(begin: 1.08, end: 1.0).animate(// start ma image zoom out ho k thori bari hogi phir screen py set ho jaye gi
      CurvedAnimation(parent: _controller, curve: Curves.easeOut), // easeout means fast start and slow end.
    );

    _controller.forward(); // animation start kar di

    Timer(const Duration(seconds: 4), () { // 4 second ke baad next screen pe jana hai
      final user = FirebaseAuth.instance.currentUser; // check karte hain user login hai ya nahi
      Navigator.pushReplacement(// mtlb splash screen sy next screen replace ho jaye gi
        context, // current context (splash screen's context means flutter ko pata chaly ga k splash screen sy agy new screen py jana ha
        MaterialPageRoute( // next screen ko animate kar k open karta ha
          builder: (_) => user == null ? const LoginPage() : const HomePage(),
          // agar user null hai to login page, warna home page
        ),
      );
    });
  }

  @override
  void dispose() {// this is used to free resources consumed by splash screen after moving to next screen
    _controller.dispose(); // animation controller ko free kar diya (memory leak se bachne ke liye)
    super.dispose(); // parent dispose call
  }

  @override
  Widget build(BuildContext context) {// this method acutally start everything that we have set earlier
    return Scaffold( // basic screen structure
      body: SizedBox.expand( // poori screen cover karega
        child: FadeTransition(
          opacity: _fadeAnimation, // opacity animation apply ho rahi hai
          child: ScaleTransition(
            scale: _scaleAnimation, // scale animation apply ho rahi hai
            child: Image.asset(
              "assets/splash.png", // splash image load ho rahi hai assets se
              fit: BoxFit.cover, // image full screen me stretch ho jayegi
            ),
          ),
        ),
      ),
    );
  }
}
// statefulwidget sirf structure deta ha or state UI or logic bnata ha or phir us UI ko actual ma show karny k lye build use hota ha