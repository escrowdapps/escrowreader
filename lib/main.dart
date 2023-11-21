// -*- coding: utf-8 -*-



import 'package:app/contract.dart';
import 'package:app/spravka.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'allContracts.dart';
import 'contractScreen.dart';
import 'read.dart';
import 'funcs.dart';






void main() async {

  await Hive.initFlutter();
  Hive.registerAdapter(ContractAdapter());    
  var box = await openEncryptedBoxContracts();

  runApp(const MyApp());




}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: 
        MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          iconTheme: IconThemeData(color:Colors.white),
          dividerColor: Colors.grey,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
          useMaterial3: true,
          textTheme: const TextTheme(
              bodyMedium: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
              titleSmall: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w200,
                fontSize: 13,
              ),
              displayLarge: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),


        
              
              )),
      routes: {
        '/allcontracts': (context) => AllContracts(title: 'escrow reader'),
        '/contractScreen': (context) => ContractScreen(),
        '/read': (context) => Read(),
        '/spravka': (context) => Spravka(),

      },
      initialRoute: '/allcontracts',
    )
  
    );
    

  
  }
}
