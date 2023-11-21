
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CustomAppBar.dart';




                      List<String> spravka = [

"Upload the document in .txt format, estimate how long it will take you to read it and create contract. On the contract page you will see the Bitcoin wallet address. Deposit any amount of Bitcoin and start reading. The essence of the deal is that if you manage to read this text on time, you can get your money back. If you don't make it in time, you will lose your money.",
"",
"To complete the task, read so carefully that you don't miss the word checkpoint in a random sentence, like this one. When you come across this word, just click on it and it will disappear. There will be 3 checkpoints in total - at the beginning, middle and end of the text.",
"",
"When you find all 3 checkpoints, you can withdraw the entire balance. If you get tired of reading after the first checkpoint, you can withdraw 1/3 of the balance. If after the second checkpoint, then 2/3 of the balance. The rest of the balance will become the app's profit. ",
"",
"If you don't find any checkpoints, then you can delete the application on the eve of the deadline, and no one will get the money, because the contract wallet is stored exclusively on your device.",
"",
"The Escrow reader code is open, its behavior is absolutely predictable and does not imply any other possibility of interaction with money."

                      ];



class Spravka extends StatelessWidget {



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: CustomAppBar(
        title: 'instruction',
      ),
       body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/f6.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.transparent.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 254, 254),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (String text in spravka)
                    Text(
                      text,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




