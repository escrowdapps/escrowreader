import 'package:app/widgets/contract_creator/dialog/dialog.dart';
import 'package:flutter/material.dart';

import 'package:app/entities/book/book.dart';

class ContractCreator extends StatefulWidget {
  const ContractCreator({super.key});

  @override
  State<ContractCreator> createState() => _ContractCreatorState();
}

class _ContractCreatorState extends State<ContractCreator> {
  DateTime _deadline = DateTime.now();
  late Book _book;
  bool dialogOpen = false;

  void _onChangeDate(DateTime newDeadline) {
    setState(() => _deadline = newDeadline);
  }

  void _toggleDialog() {
    setState(() => dialogOpen = !dialogOpen);
  }

  @override
  Widget build(BuildContext context) {
    return CreateContractDialog(
      selectedDate: _deadline,
    );
  }
}
