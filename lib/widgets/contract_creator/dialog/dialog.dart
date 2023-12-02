import 'package:flutter/material.dart';

class CreateContractDialog extends StatelessWidget {
  const CreateContractDialog({super.key, required this.selectedDate});

  final DateTime selectedDate;

  void onDateSaved(DateTime dateTime) {
    print(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        child: Column(
      children: [
        AppBar(
          backgroundColor: Colors.pink[50],
          title: const Text("create contract"),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: InputDatePickerFormField(
              onDateSaved: onDateSaved,
              acceptEmptyDate: false,
              errorInvalidText: "test",
              fieldHintText: "test3",
              fieldLabelText: 'deadline date',
              errorFormatText: "test2",
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now()),
        ),
      ],
    ));
  }
}
