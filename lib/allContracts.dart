import 'package:app/bitcoin.dart';
import 'package:app/contract.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'funcs.dart';
import 'bottomCreate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ntp/ntp.dart';
import 'CustomAppBar.dart';
import 'package:google_fonts/google_fonts.dart';

class AllContracts extends StatefulWidget {
  const AllContracts({super.key, required this.title});

  final String title;

  @override
  State<AllContracts> createState() => _AllContractsState();
}

class _AllContractsState extends State<AllContracts> {
  late Future<List<dynamic>> contractsFuture;

  @override
  void initState() {
    super.initState();
    contractsFuture = loadContracts();
    checkTime();
  }

  Future<List<dynamic>> loadContracts() async {
    var box = await Hive.openBox<Contract>('contracts');
    final contracts = box.values.toList();

    return contracts;
  }

  Future<void> checkTime() async {
    if (await checkConection()) {
      List<dynamic> contracts = await contractsFuture;
      dynamic dateNow = await NTP.now();
      int currentTimeMillis = dateNow.millisecondsSinceEpoch;
      print(currentTimeMillis);

      for (int i = 0; i < contracts.length; i++) {
        final element = contracts[i];
        print(element.days);
        if (element.days < currentTimeMillis && element.uri == 'uri') {
          await bitcoin(element, element.walletMap['address'], true);
        }
      }
    }
  }

  Future<void> deleteContracts(Contract i) async {
    var box = await Hive.openBox<Contract>('contracts');
    box.delete(i.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'escrow reader',
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/f6.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.transparent.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: contractsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Ошибка: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      final contracts = snapshot.data!;
                      if (contracts.isEmpty) {
                        return const Center(
                          child: Text('no contracts'),
                        );
                      }
                      return ListView.builder(
                        itemCount: contracts.length,
                        itemBuilder: (context, i) {
                          final contract = contracts[i];
                          return Slidable(
                              key: UniqueKey(),
                              closeOnScroll: true,
                              startActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext context) =>
                                        _dialogBuilder(context, contract),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'delete',
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: const BoxDecoration(),
                                child: Card(
                                  elevation: 5,
                                  surfaceTintColor: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                      contract.name,
                                      style: GoogleFonts.quicksand(
                                          textStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.normal)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                        'dL: ${getFormatDate(contract.days).split(' ')[0]}',
                                        style: GoogleFonts.quicksand(
                                            textStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.normal))),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          '/contractScreen',
                                          arguments: contract);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ));
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
              const bottomCreate()
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _dialogBuilder(BuildContext context, Contract contract) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Delete contract?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'deleting a contract permanently deletes the contract wallet and all funds stored on it.',
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
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Delete'),
                onPressed: () async {
                  var box = await Hive.openBox<Contract>('contracts');
                  box.delete(contract.id);

                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/allcontracts', (route) => false);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
