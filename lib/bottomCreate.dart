import 'dart:typed_data';
import 'package:app/contract.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'funcs.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:windows1251/windows1251.dart';


class bottomCreate extends StatefulWidget {
  const bottomCreate({Key? key}) : super(key: key);

  @override
  _bottomCreateState createState() => _bottomCreateState();
}

class _bottomCreateState extends State<bottomCreate> {
  String documentName = '';
  String textAlert = '';
  String dateAlert = '';
  bool createAlert = false;
  int date = 0;
  List<dynamic> paragraphs = [];
  bool isTxtDocument = false;
  String uri = '';
  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != date && pickedDate != 0) {
      setState(() {
        date = pickedDate.millisecondsSinceEpoch + 86400000 - 1000;
      });
    } else {
      setState(() {
        dateAlert = 'select date';
      });
    }
  }



  Future<dynamic> uploadDocument() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'text',
      extensions: <String>['txt'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      if (file != null) {
      Uint8List bytes = await file.readAsBytes();
      late String text;

      try {
        text = utf8.decode(bytes);
      } catch (e) {
        text = windows1251.decode(bytes, allowInvalid: false);
      }


      paragraphs = getRandomParagraphs(text);
      if(paragraphs.length == 0){
        textAlert = 'text too small';
      }else{
        textAlert = '';

        documentName = Uri.decodeFull(file.name).split('/').last;
          if (documentName.contains('primary:')) {
          documentName = documentName.replaceFirst('primary:', '');
        }
        saveFile(text, documentName);
      }
    } else {
        textAlert = 'select file';
    }

    setState(() {
      documentName;
      textAlert;
      paragraphs;
    });
  }






  Future hiveWrite(String nameContract, int days, List<dynamic> paragraphs,
    String uri, double scroll) async {
    // final wallet = Wallet.random(testnet);
    final wallet = Wallet.random(bitcoin);

    dynamic walletMap = {
      'privKey': wallet.privKey,
      'pubKey': wallet.pubKey,
      'wif': wallet.wif,
      'address': wallet.address
    };

    var box = await Hive.openBox<Contract>('contracts');
    int nowDate = DateTime.now().millisecondsSinceEpoch;
    String id = 'Contract_$nowDate';
    box.put('Contract_$nowDate',
        Contract(id, nameContract, days, paragraphs, walletMap, uri, scroll));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            const Color.fromARGB(255, 255, 254, 254), // Серый цвет контейнера

        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Color.fromARGB(255, 199, 199, 199),
              offset: Offset(1, 1),
              blurRadius: 10,
              spreadRadius: 1),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 20),
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Text(
                      '${textAlert == '' ? documentName : textAlert}',
                                  style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal)),



                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Text(
                      '${date == 0 ? dateAlert : getFormatDate(date).split(' ')[0]}',
                      style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.normal)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 0.80,
                  child: ElevatedButton(
                    child:
                        AutoSizeText('document',
                         style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal))
                        ),
                    onPressed: () async {
                      await uploadDocument();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 3,
                      foregroundColor: Colors.grey,
                      disabledForegroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white,
                      shadowColor: Colors.black,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 185, 185, 185), // Цвет границы
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 0.80,
                  child: ElevatedButton(
                    child: AutoSizeText('deadline',
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal)
                                )
                              ),
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 3,
                      foregroundColor: Colors.grey,
                      disabledForegroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white,
                      shadowColor: Colors.black,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                                      side: BorderSide(
                        color:
                            Color.fromARGB(255, 185, 185, 185),
                        width: 1.0,
                      ),
                      ),

                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.white,
            thickness: 0,
          ),
          FractionallySizedBox(
            widthFactor: 0.9,

            child: ElevatedButton(
              onPressed: () async {
                if (date > 0 && documentName != '') {
                  hiveWrite(documentName, date, paragraphs, 'uri', 0);

                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/allcontracts', (route) => false);
                }
                if (date == 0) {
                  dateAlert = 'select date';
                }
                if (documentName == '') {
                  textAlert = 'select file';
                }
                setState(() {
                  dateAlert;
                  textAlert;
                });
              },
              child: Text('create contract',
                                           style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal))
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 3,
                foregroundColor: Colors.grey,
                disabledForegroundColor: Colors.white,
                disabledBackgroundColor: Colors.white,
                shadowColor: Colors.black,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                side: BorderSide(
                  color: Color.fromARGB(255, 185, 185, 185),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
