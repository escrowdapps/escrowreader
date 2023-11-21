import 'package:flutter/material.dart';
import 'funcs.dart';
import 'package:flutter/services.dart';
import 'package:app/contract.dart';
import 'package:hive/hive.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'bitcoin.dart';
import 'CustomAppBar.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';


dynamic getHiveContract(String id) async {
  var box = await Hive.openBox<Contract>('contracts');
  return box.get(id);
}

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen>  with WidgetsBindingObserver {
  bool isCopying = false;
  late Future<dynamic>? balance;
  late TextEditingController controllerWallet;
  late Contract contract;
  bool bobo = false;
  List<dynamic> text = [];
  String textAlert = '';
  dynamic responseBitcoin = '';
  bool isConnect = true;
  int checkpoints = 0;
  List<String> successTx = [];
  bool isLoading = false;

  bool isKeyboardVisible = true;

  @override
  void initState() {
    super.initState();
    controllerWallet = TextEditingController();
    balance = null;
    WidgetsBinding.instance?.addObserver(this);

  }
GlobalKey _buttonKey = GlobalKey();

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    controllerWallet.dispose();
    super.dispose();
  }

    void _onFocusChange() {
      print(isKeyboardVisible);
      setState(() {
        isKeyboardVisible = !isKeyboardVisible;
      });
  }
    @override
  void didChangeMetrics() {
    final bool newIsKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardVisible != newIsKeyboardVisible) {
      setState(() {
        isKeyboardVisible = newIsKeyboardVisible;
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    contract = ModalRoute.of(context)!.settings.arguments as Contract;
    checkpoints = 3 - contract.paragraphs.length;
    if (contract.uri != 'timeOff' && contract.uri != 'uri') {
      print(contract.uri);
      successTx = contract.uri.split('_');
    }

    if (balance == null) {
      balance = getBalance('${contract.walletMap['address']}');
    }
    setState(() {
      contract;
      balance;
      checkpoints;
      successTx;
    });
  }

  Widget _buildTextContainer(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
            textStyle: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.normal)),
            textAlign: TextAlign.left,
          ),
          if(title == 'deadline')
            InkWell(
                key: _buttonKey,

              onTap: () {
                showTooltip(context);
              },
                child: Row(children: [
                        Text(
                          "$content",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal)),
                        ),
                        Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 20.0,
                        )
                ],)

                
            )else
              Text(
                  content,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.normal)),
                ),
      
          ]
          )
        );
          

  }

void showTooltip(BuildContext context) {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 75, 
        top: position.dy - 50, 

        child: Tooltip(
          preferBelow: false,
          message: '',
          child: Container(
            padding: EdgeInsets.all(9),
              decoration: BoxDecoration(
            color: Colors.white,

              border: Border.all(
                color: Colors.black, 
                width: 1.0, 
              ),
              borderRadius:
                  BorderRadius.circular(13.0), 
            ),
            child: Center(
              child: Text(
                'before ${getFormatDate(contract.days).split(' ')[1]} ${getLocalTimeZoneOffset()}',
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Закрыть подсказку через 2 секунды
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }


  Widget _buildDivider() {
    return Divider();
  }

  @override
  Widget build(BuildContext context) {
    void changeIconTemporarily(String copyString) {
      setState(() {
        isCopying = true;
      });

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isCopying = false;
        });
      });
      print(copyString);
      final textToCopy = copyString;
      Clipboard.setData(ClipboardData(text: textToCopy));
    }

    return Scaffold(
      appBar: isLoading ? null : CustomAppBar(title: contract.name),

      body: isLoading ? Center(child: Text('loading...'),):
      Column(
            children: [
              Expanded(
                child: Container(
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
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: FutureBuilder<dynamic>(
                      future: balance,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('An error has occurred!'),
                          );
                        } else if (snapshot.hasData) {
                          dynamic balance = snapshot.data / 100000000;
                          double availableBalance = contract.uri == 'timeOff'
                              ? balance
                              : double.parse((balance *
                                      ((3 - contract.paragraphs.length) / 3))
                                  .toStringAsFixed(8));

                          return SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 254,
                                          254), 
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 3,
                                          offset: Offset(0,
                                              3), 
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 15, 10, 15),
                                    child: Column(children: [
                                      _buildTextContainer(
                                        "deadline",
                                        '${getFormatDate(contract.days).split(' ')[0]} ',
                                      ),

                                      _buildDivider(),
                                      _buildTextContainer(
                                        "checkpoints",
                                        "$checkpoints/3",
                                      ),
                                      _buildDivider(),
                                      _buildTextContainer(
                                          "balance",
                                          successTx.length == 2
                                              ? "${balance == 404 ? 'error' : '(-${successTx[1]}) $balance ₿'}"
                                              : "${balance == 404 ? 'error' : '$balance ₿'}"),

                                    ])),
                                Visibility(
                                  visible: (contract.uri == 'uri' ||
                                      contract.uri == 'timeOff'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 254,
                                          254), 

                                      borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 3,
                                              offset: Offset(0,
                                                  3), 
                                            ),
                                          ],
                                    ),
                                    padding:
                                        EdgeInsets.fromLTRB(20, 10, 10, 20),
                                    margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons
                                                    .settings, // Иконка настройки
                                                color: Colors.transparent,
                                              ),
                                              onPressed: () {
                                                // Добавьте обработчик нажатия для кнопки настройки
                                              },
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Wallet for deposit',
                                                  style: GoogleFonts.quicksand(
                                                      textStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold)
                                                              ), 
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: AutoSizeText(
                                              '${contract.walletMap['address']}',
                                              style: TextStyle(
                                                fontSize: 5.0,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                            )),
                                            IconButton(
                                              icon: isCopying
                                                  ? Icon(
                                                      Icons
                                                          .check, 
                                                      color: Colors
                                                          .green, 
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .content_copy, 
                                                      color: Colors.black,
                                                    ),
                                              onPressed: () {
                                                changeIconTemporarily(contract
                                                    .walletMap['address']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: (contract.uri == 'uri' ||
                                      contract.uri == 'timeOff'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 254, 254),
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
                                    padding:
                                        EdgeInsets.fromLTRB(20, 10, 10, 30),
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                icon: Icon(
                                                  Icons
                                                      .settings, 
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  _showInputDialog(context);
                                                  print('press');
                                                }),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Wallet to receive',
                                                  style: GoogleFonts.quicksand(
                                                      textStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold)), 
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: AutoSizeTextField(
                                                controller: controllerWallet,
                                                decoration: InputDecoration(
                                                  hintText: 'address',
                                                ),
                                                style: GoogleFonts.quicksand(
                                                    textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold)), 
                                                maxLines: 1,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.send,
                                                color: Colors.black,
                                              ),
                                              onPressed: () async {
                                                bool isConnect =
                                                    await checkConection();
                                                dynamic response;
                                                if (isConnect) {
                                                  response =
                                                      await _dialogBuilder(
                                                          context,
                                                          contract,
                                                          controllerWallet.text,
                                                          balance);
                                                } else {
                                                  response = 'no internet';
                                                }

                                                setState(() {
                                                  responseBitcoin = response;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: Text(
                                              '${responseBitcoin == null ? '' : responseBitcoin}',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.green),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: !(contract.uri == 'uri' ||
                                      contract.uri == 'timeOff'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 254,
                                          254), 
                                      borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 3,
                                              offset: Offset(0,
                                                  3), 
                                            ),
                                          ],
                                    ),
                                    padding:
                                        EdgeInsets.fromLTRB(20, 10, 10, 10),
                                    margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Transaction success',
                                          style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)), 
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: AutoSizeText(
                                              '${successTx.length == 2 ? successTx[0] : responseBitcoin}',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                            )),
                                            IconButton(
                                              icon: isCopying
                                                  ? Icon(
                                                      Icons
                                                          .check, 
                                                      color: Colors
                                                          .green, 
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .content_copy, 
                                                      color: Colors.black,
                                                    ),
                                              onPressed: () {
                                                changeIconTemporarily(
                                                    successTx[0]);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.grey),
                          );
                        }
                      }),
                ),
              ),
              if(isKeyboardVisible)
              FractionallySizedBox(
                widthFactor: 1,
                child: TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final dynamic text = await readFile(contract.name);
                    Navigator.of(context)
                        .pushReplacementNamed('/read', arguments: [contract, text]);
                  },
                  child: Text('start reading',
                      style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),                       
                      ),

                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white,
                    shadowColor: Colors.black,
                    surfaceTintColor: Colors.white,
                  ),
                ),
              )
            ],
          ));


    
  }
}

Future<dynamic> _dialogBuilder(
    BuildContext context, contract, wallet, balance) async {
  dynamic contractHive = await getHiveContract(contract.id);
  dynamic availableBalance = contractHive.uri == 'timeOff'
      ? balance * 100000000
      : (balance * 100000000 * ((3 - contractHive.paragraphs.length) / 3))
          .floor();

  print(balance);
  print(availableBalance);

  var result = await showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Send bitcoin',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          textAlign: TextAlign.center,
          contractHive.paragraphs.length == 3
              ? 'Available for send 0.'
              : contractHive.uri == 'timeOff'
                  ? '${balance} ₿ \nSend to wallet:\n $wallet '
                  : '${availableBalance / 100000000} ₿ \nSend to wallet:\n $wallet ',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text('Send'),
                onPressed: availableBalance == 0
                    ? null
                    : () async {
                        dynamic res =
                            await bitcoin(contractHive, wallet);

                        Navigator.of(context).pop(res);


                      },
              ),
            ],
          ),
        ],
      );
    },
  );

  return result;
}

_showInputDialog(BuildContext context) async {
  print('1');
  dynamic box = await Hive.openBox('settings');
  dynamic feeHive = box.get('fee');
  dynamic utxo = box.get('utxo');
  dynamic tx = box.get('tx');

  if (utxo == '' || utxo == null) {
    utxo = 'https://blockstream.info/api/address/wallet/utxo';
  }
  if (tx == '' || tx == null) {
    tx = 'http://blockstream.info/api/tx';
  }

  Future<String> setFeeInTextField() async {
    dynamic fee = await getFee();
    return fee.toString();
  }

  if (feeHive == '' || feeHive == null) {
    feeHive =  await setFeeInTextField();
  }

  TextEditingController _textFieldController1 =
      TextEditingController(text: utxo);
  TextEditingController _textFieldController2 =
      TextEditingController(text: feeHive);
  TextEditingController _textFieldController3 = TextEditingController(text: tx);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Transaction settings'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textFieldController1,
                decoration: InputDecoration(
                  // hintText: 'utxo url',
                  labelText: 'utxo url',
                ),
              ),
              Text(
                'the path must contain the substring /wallet/',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
              TextButton(
                onPressed: () {
                  _textFieldController1.text =
                      // 'http://blockstream.info/testnet/api/address/wallet/utxo';
                  'http://blockstream.info/api/address/wallet/utxo';
                },
                child: Text('use default'),
              ),
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _textFieldController2,
                decoration: InputDecoration(labelText: 'fee per byte'),
              ),
              TextButton(
                onPressed: feeHive != '0'
                    ? () {
                        setFeeInTextField(); 
                      }
                    : null,
                child: Text('use default'),
              ),
              TextField(
                controller: _textFieldController3,
                decoration: InputDecoration(labelText: 'post tx url'),
              ),
              TextButton(
                onPressed: () {
                  _textFieldController3.text =
                      // 'http://blockstream.info/testnet/api/tx';
                  "http://blockstream.info/api/tx";
                },
                child: Text('use default'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String utxo = _textFieldController1.text;
                  String fee = _textFieldController2.text;
                  String tx = _textFieldController3.text;

                  final box = await Hive.openBox('settings');
                  box.put('utxo', utxo);
                  box.put('fee', fee);
                  box.put('tx', tx);

                  await box.close();
                  Navigator.of(context).pop(); 
                },
                child: Text('save'),
              ),
            ],
          ),
        ],
      
      
      
      );
    },
  );
}
