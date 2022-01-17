import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_appliance_controller/authentication_screen/authentication_screen.dart';
import 'package:home_appliance_controller/machine_detail_screen/machine_detail_screen.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'components/custom_bottom_sheet.dart';
import 'components/machine_card.dart';

class MainScreen extends StatefulWidget {
  static String routeName = "/MainScreen";

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  final Stream<QuerySnapshot> _machineCollectionStream = FirebaseFirestore
      .instance
      .collection('machines')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  var box;

  List<String> deviceNames = [];

  Future<void> recognizer() async {
    stt.SpeechToText speech = stt.SpeechToText();
    bool available = await speech.initialize(onStatus: (statusListener) {
      print('main_screen statusListener : $statusListener');
    }, onError: (errorListener) {
      print('main_screen errorListener : $errorListener');
    });
    if (available) {
      speech.listen(onResult: (resultListener) {
        print('main_screen resultListener : ${resultListener}');
        print('main_screen resultListener : ${resultListener.recognizedWords}');
        if (resultListener.isConfident(
                threshold: SpeechRecognitionWords.confidenceThreshold) &&
            resultListener.finalResult) {
          EasyLoading.showToast('${resultListener.recognizedWords}');
          checkCommands('${resultListener.recognizedWords}');
        }
      });
    } else {
      print("The user has denied the use of speech recognition.");
    }
    // // some time later...
    // speech.stop();
  }

  @override
  void initState() {
    super.initState();
  }

  void _logout() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Want to logout?'),
            content: Text('You will redirected to Login Page'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _auth.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AuthenticationScreen.routeName, (route) => false);
                  });
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 170,
        centerTitle: true,
        // elevation: 10,
        title: const Text(
          'Home Appliance Controller',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _machineCollectionStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data!.size == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    "No Machine Added",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: 10,
                ),
                ...snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  deviceNames.add(data['machineName']);
                  return MachineCard(
                      deviceId: data['machineID'],
                      machineName: data['machineName'].toString().toUpperCase(),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          MachineDetailsScreen.routeName,
                          arguments: data['machineID'],
                        );
                      });
                }).toList(),
              ]),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: recognizer,
            child: Icon(Icons.mic),
          ),
          SizedBox(
            height: 28,
          ),
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _showTransactionModalSheet(context);
            },
            heroTag: null,
          ),
          SizedBox(
            height: 28,
          ),
          FloatingActionButton(
            child: Icon(Icons.power_settings_new_outlined),
            onPressed: () => _logout(),
            heroTag: null,
          ),
        ]),
      ),
    );
  }

  void checkCommands(String voiceMsg) {
    voiceMsg = voiceMsg.toLowerCase();
    deviceNames.forEach((element) {
      element = element.toLowerCase();
      if (voiceMsg.contains(element)) {
        print('Matched');
        if (voiceMsg.contains('turn on')) {
          print('Matched turn on');
          updateDataAccordingToCondition(state: true, deviceName: element);
        }
        if (voiceMsg.contains('turn off')) {
          print('Matched turn off');
          updateDataAccordingToCondition(state: false, deviceName: element);
        }
      }
    });
  }

  void updateDataAccordingToCondition(
      {required String deviceName, required bool state}) {
    final CollectionReference _deviceCollection =
        FirebaseFirestore.instance.collection('machines');
    print("UserID: "+FirebaseAuth.instance.currentUser!.uid);
    print("Device Name: " + deviceName);
    _deviceCollection
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('machineName', isEqualTo: '$deviceName')
        .get()
        .then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        // print(data['machineID']);
        updateMachine(
            docRef: _deviceCollection.doc('${data["machineID"]}'),
            map: {
              'state': state,
            });
      });
    }).whenComplete(
      () => EasyLoading.dismiss(),
    );
  }

  Future<void> updateMachine({
    required DocumentReference docRef,
    required Map<String, dynamic> map,
  }) async {
    showProgress();
    await docRef.get().then(
      (doc) {
        if (doc.exists) {
          // Call the user's CollectionReference
          return docRef.update(map).then((value) {
            EasyLoading.showSuccess('Changes updated');
          }).catchError((error) {
            EasyLoading.showError('Changes updated');
            print('main_screen: $error');
          });
        } else {
          print('can\'t able to update name');
        }
      },
    );
  }

  //Show Bottom Sheet~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showTransactionModalSheet(BuildContext ctx) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: CustomBottomSheet(),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void showProgress() {
    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
  }
}
