import 'package:app/contract.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ntp/ntp.dart';
import 'funcs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  List<String> text = [];
  String textAlert = '';
  dynamic contract;
  ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);


  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as List;
    
    contract = args[0] as Contract;
    text = args[1].split('\n\n');
    if(text.length<3){
        text = args[1].split(' ');
        if(text.length<3){
          text = args[1].split('');
          
        }
    }

    var box = await Hive.openBox<Contract>('contracts');
    var contractHive = box.get(contract.id) as Contract;

    
    _scrollController.jumpTo(contractHive.scroll);
    _scrollController.addListener(() {
      if (_scrollTimer != null && _scrollTimer!.isActive) {
        _scrollTimer!.cancel(); // Отменить предыдущий таймер
      }
      _scrollTimer = Timer(Duration(milliseconds: 1000), ()async {
        addScroll(contract.id, _scrollController.offset);

      });
    });
    setState(() {
      text;
      contract;
    });
  }


  void addScroll(String id, double y)async {
      var box = await Hive.openBox<Contract>('contracts');
      var contract = box.get(id);
      if (contract != null) {
        contract.scroll = y;
        box.put(id, contract);
    } else {
      print('Контракт с id $id не найден.');
    }

  }



// Contract_1698256633413
  void addCheckpoint(id, newPar) async {
    if(await checkConection()){
      var box = await Hive.openBox<Contract>('contracts');
      var contract = box.get(id);
      dynamic dateNow = await NTP.now();
      if (contract != null) {
        if (contract.days > dateNow.millisecondsSinceEpoch) {
          print('time is');
          contract.paragraphs = newPar;
          box.put(id, contract);
        } else {
          print('время истекло');
        }
      } else {
        // Обработка случая, если объект не найден
        print('Контракт с id $id не найден.');
      }
    }else{
      print('no internet');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Установите цвет фона здесь

      body: Column(
        children: [
          Expanded(
            child: 
            ListView.builder(
              controller: _scrollController, 
          


              itemCount: text.length ,
              itemBuilder: (context, index) {
                final paragraph = text[index];
                if (contract != null && contract.paragraphs.length>0) {
                  final List<dynamic> paragraphs = contract.paragraphs;
                  var indexPar = paragraphs.indexWhere((p) => p == paragraph);
                  if (indexPar != -1) {
                    return ListTile(
                      title: Text('$paragraph checkpoint', style: GoogleFonts.roboto(),),
                      onTap: ()async {
                        bool isConnect = await checkConection();
                        if(isConnect){
                          paragraphs.removeAt(indexPar);
                          addCheckpoint(contract.id, paragraphs);
                          setState(() {
                            contract.paragraphs = paragraphs;
                          });
                          final snackBar = SnackBar(
                            content: const Text('checkpoint found', style: TextStyle(fontSize: 15),),
                            action: SnackBarAction(
                              label: 'close',
                              textColor: Colors.white,
                              onPressed: () {
                                // Some code to undo the change.
                              },
                            ),
                            duration: const Duration(milliseconds: 1500),
                            width: 280.0, // Width of the SnackBar.
                            padding: const EdgeInsets.symmetric(
                              horizontal:
                                  18.0, // Inner padding for SnackBar content.
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Colors.green,
                          );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        }else{
                          return _dialogBuilder(context);
                        }

                      },
                    );
                  }
                }
                return ListTile(
                  title: Text(paragraph),
                );
              },
            ),
          
          
          ),
        ],
      ),
    );
  }

  @override 
  void dispose() {
    // Восстанавливаем видимость статус-бара при уничтожении виджета
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

}




Future<void> _dialogBuilder(
    BuildContext context) async {
      

await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Connect to internet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
        'To record the location of a checkpoint, you must find out the correct time. To do this you need to connect to the Internet. The rest of the time the Internet is not required.',
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
         
            
            ],
          ),
        ],
      );
    },
  );

}
