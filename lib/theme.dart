import 'package:flutter/material.dart';

ThemeData EscrowAppTheme = ThemeData(
    iconTheme: const IconThemeData(color: Colors.white),
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
    ));
