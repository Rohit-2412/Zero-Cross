import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/bg.jpg'), opacity: 0.45),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //header
              Text('Tic', style: GoogleFonts.lora(fontSize: 60, fontWeight: FontWeight.w700, color: Colors.redAccent)),
              Text('Tac', style: GoogleFonts.lora(fontSize: 60, fontWeight: FontWeight.w700, color: Colors.pinkAccent)),
              Text(
                'Toe',
                style: GoogleFonts.lora(fontSize: 60, fontWeight: FontWeight.w700, color: Colors.orangeAccent),
              ),

              // const SizedBox(height: 30),

              // image
              // Image.asset(
              //   'assets/logo.png',
              //   height: 150,
              //   width: 150,
              //   color: Colors.redAccent,
              // ),
              const SizedBox(height: 20),
              Text(
                "Choose your game mode",
                style: GoogleFonts.inter(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),

              // player vs computer
              SizedBox(
                width: 200,
                height: 60,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: () {
                    // move to single player game screen when pressed
                    Navigator.pushNamed(context, "/singleplayer");
                  },
                  child: Text("With AI", style: GoogleFonts.inter(fontSize: 30, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              // player vs player
              Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: () {
                    // move to multiplayer game screen when pressed
                    Navigator.pushNamed(context, '/multiplayer');
                  },
                  child: Text("With a friend", style: GoogleFonts.inter(fontSize: 30, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
