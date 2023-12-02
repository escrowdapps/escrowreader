// -*- coding: utf-8 -*-

import 'package:app/contract.dart';
import 'package:app/routes.dart';
import 'package:app/spravka.dart';
import 'package:app/theme.dart';
import 'package:app/widgets/contract_creator/contract_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'allContracts.dart';
import 'contractScreen.dart';
import 'read.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    return SafeArea(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Flutter Demo',
          theme: EscrowAppTheme,
          routes: {
        Routes.allContracts: (context) => const AllContracts(title: 'escrow reader'),
        Routes.contract: (context) => ContractScreen(),
        Routes.read: (context) => Read(),
        Routes.info: (context) => Spravka(),
        },
          initialRoute: Routes.allContracts,
        ));
  }
}
