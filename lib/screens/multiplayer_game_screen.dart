import 'dart:async';

import 'package:flutter/material.dart';
import '../constants/colors.dart';

import 'package:google_fonts/google_fonts.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  bool oTurn = true;
  List<String> list = ['', '', '', '', '', '', '', '', ''];
  List<int> winningIndex = [];
  String result = "";
  int oScore = 0;
  int xScore = 0;
  bool stopped = false;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer? timer;
  int attempts = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // player name
                  Text(
                    "Player 1",
                    style: GoogleFonts.varelaRound(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.redAccent),
                  ),

                  // both scores
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        // user score
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              oScore.toString(),
                              style: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Text("-", style: GoogleFonts.inter(fontSize: 45)),
                        // computer score
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              xScore.toString(),
                              style: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ai name
                  Text(
                    "Player 2",
                    style: GoogleFonts.varelaRound(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              // board
              SizedBox(
                // flex: 3,
                height: MediaQuery.of(context).size.height - 450,
                child: GridView.builder(
                  itemCount: 9,
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _tapped(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: winningIndex.contains(index) ? Border.all(color: Colors.black87, width: 2) : null,
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(2, -2)),
                            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
                          ],
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            list[index],
                            style: GoogleFonts.varelaRound(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: (list[index] == 'O') ? CustomColors.redColor : CustomColors.blueColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        result.isNotEmpty ? result : "",
                        style: TextStyle(
                          fontSize: 30,
                          color: result == 'O Wins' ? Colors.pinkAccent : Colors.deepPurpleAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      buildTimer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTimer() {
    final isRunning = timer == null ? false : timer!.isActive;
    return isRunning
        ? Center(
          child: (SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1 - seconds / maxSeconds,
                  valueColor: AlwaysStoppedAnimation(Colors.green[400]),
                  strokeWidth: 7,
                  backgroundColor: Colors.green.withOpacity(.4),
                  // CustomColors.firstGradientColor.withOpacity(.35),
                ),
                Center(
                  child: Text(
                    seconds.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )),
        )
        : (ElevatedButton(
          onPressed: () {
            setState(() {
              startTimer();
              list = ['', '', '', '', '', '', '', '', ''];
              result = "";
              attempts++;
              winningIndex = [];
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            attempts == 0 ? "Start" : "Play Again!",
            style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ));
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          stopTimer();
        }
      });
    });
  }

  // on dispose cancel the timer
  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void stopTimer() {
    resetTimer();
    timer?.cancel();
  }

  void resetTimer() {
    seconds = maxSeconds;
  }

  void _tapped(index) {
    final isRunning = timer == null ? false : timer!.isActive;
    if (result == '' && isRunning) {
      setState(() {
        if (oTurn && list[index] == '') {
          list[index] = 'O';
          oTurn = !oTurn;
        } else if (!oTurn && list[index] == '') {
          list[index] = 'X';
          oTurn = !oTurn;
        }
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    // 1st row
    if (list[0] == list[1] && list[0] == list[2] && list[0] != '') {
      setState(() {
        result = "${list[0]} wins";
        winningIndex = [0, 1, 2];
      });
    }

    // 2nd row
    if (list[3] == list[4] && list[3] == list[5] && list[3] != '') {
      setState(() {
        result = "${list[3]} wins";
        winningIndex = [3, 4, 5];
      });
    }

    // 3rd row
    if (list[6] == list[7] && list[6] == list[8] && list[6] != '') {
      setState(() {
        result = "${list[6]} wins";
        winningIndex = [6, 7, 8];
      });
    }

    // 1st column
    if (list[0] == list[3] && list[0] == list[6] && list[0] != '') {
      setState(() {
        result = "${list[0]} wins";
        winningIndex = [0, 3, 6];
      });
    }

    // 2nd column
    if (list[1] == list[4] && list[1] == list[7] && list[1] != '') {
      setState(() {
        result = "${list[1]} wins";
        winningIndex = [1, 4, 7];
      });
    }

    // 3rd column
    if (list[2] == list[5] && list[2] == list[8] && list[2] != '') {
      setState(() {
        result = "${list[2]} wins";
        winningIndex = [2, 5, 8];
      });
    }

    // 1st diagonal
    if (list[0] == list[4] && list[0] == list[8] && list[0] != '') {
      setState(() {
        result = "${list[0]} wins";
        winningIndex = [0, 4, 8];
      });
    }

    // 2nd diagonal
    if (list[2] == list[4] && list[2] == list[6] && list[2] != '') {
      setState(() {
        result = "${list[2]} wins";
        winningIndex = [2, 4, 6];
      });
    }

    int filled = 0;

    for (int i = 0; i < 9; i++) {
      if (list[i] != '') {
        filled++;
      }
    }

    if (filled == 9 && result == '') {
      setState(() {
        result = "Game Draw";
        return;
      });
    }

    if (oTurn && result == "X wins") {
      _updateScore('X');
    } else if (!oTurn && result == "O wins") {
      _updateScore('O');
    }

    if (result == "Game Draw" || result == "X wins" || result == "O wins") {
      stopTimer();
    }
  }

  void _updateScore(winner) {
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
  }
}
