import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_comp/easy_comp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/number_model.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with Loader, Messages {
  late FirebaseFirestore _firestore;
  late CollectionReference _numbersCollection;
  List<NumberModel> _numbers = List.generate(100, (index) => NumberModel(index + 1));
  late StreamSubscription<QuerySnapshot> _subscription;

  String usuario = "usuario_teste";

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _numbersCollection = _firestore.collection('numbers');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ec = TextEditingController();
      Utils.dialogFuture<String>(
        context: context,
        title: const Text("Seu Nome"),
        message: WillPopScope(
          onWillPop: () async {
            return Future.value(false);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                controller: ec,
                placeholder: "Coloque seu nome...",
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    child: const Text("Salvar"),
                    onPressed: () async {
                      if (ec.text.isEmpty) {
                        showError("Nome vazio, preencha seu nome!");
                        return;
                      }
                      Nav.back(context, ec.text);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ).then((value) {
        if (value != null) {
          usuario = value;
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chá Rifa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomStreamBuilder(
                stream: _firestore.collection('numbers').snapshots(),
                withLoading: true,
                withError: true,
                builder: (snapshot) {
                  for (var doc in (snapshot?.docs ?? [])) {
                    int index = int.parse(doc.id);
                    _numbers[index] = NumberModel.fromSnapshot(doc);
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      NumberModel currentNumber = _numbers[index];
                      return InkWell(
                        onTap: () async {
                          if (currentNumber.selectedBy != null && currentNumber.selectedBy!.isNotEmpty && currentNumber.selectedBy != usuario) {
                            return;
                          }
                          if (!currentNumber.selected && currentNumber.reserveTimestamp == null) {
                            currentNumber.selected = true;
                            currentNumber.selectedBy = usuario; // Substitua pelo nome do usuário real
                            currentNumber.reserveTimestamp = DateTime.now();
                            await _numbersCollection.doc(index.toString()).set(currentNumber.toMap());
                          } else if (currentNumber.selected && currentNumber.idFirebase != null) {
                            await _numbersCollection.doc(index.toString()).delete();
                            _numbers[index] = NumberModel(currentNumber.number);
                          }
                        },
                        child: Container(
                          color: (currentNumber.selectedBy != null && currentNumber.selectedBy!.isNotEmpty && currentNumber.selectedBy != usuario)
                              ? Colors.redAccent
                              : currentNumber.selected
                                  ? Colors.green
                                  : Colors.blue,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (currentNumber.number).toString(),
                                  style: TextStyle(
                                    color: currentNumber.selected ? Colors.black : Colors.white,
                                  ),
                                ),
                                if (currentNumber.reserveTimestamp != null)
                                  Text(
                                    '${(currentNumber.reserveTimestamp?.difference(DateTime.now()).inSeconds)}s',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
