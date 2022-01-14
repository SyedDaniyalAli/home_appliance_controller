import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_picker/flutter_picker.dart';

import '../custom_edit_dialog.dart';

class MachineDetailsScreen extends StatefulWidget {
  static String routeName = "/MachineDetailsScreen";

  const MachineDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  String machineID = '';
  String machineName = '';
  bool machineState = false;

  // Create a CollectionReference called users that references the firestore collection
  CollectionReference machinesCollection =
      FirebaseFirestore.instance.collection('machines');

  void updateData() {
    final machineIdLocal = ModalRoute.of(context)!.settings.arguments as String;
    showProgress();

    machinesCollection
        .where('machineID', isEqualTo: machineIdLocal)
        .limit(1)
        .get()
        .then((snapShot) => {
              snapShot.docs.forEach((element) {
                print(element['machineID']);
                setState(() {
                  machineID = element['machineID'];
                  machineName = element['machineName'];
                  machineState = element['state'];
                });
              })
            })
        .whenComplete(() => EasyLoading.dismiss());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Settings'),
        centerTitle: true,
        toolbarHeight: 120,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Icon(
              FontAwesomeIcons.microchip,
              size: 122,
            ),
            SizedBox(
              height: 21,
            ),
            Text(
              'Machine ID: $machineID',
              style: TextStyle(color: Colors.red),
            ),
            Container(
              margin: EdgeInsets.only(top: 28, bottom: 28),
              width: 280,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showNameDialogBox(machineID);
                    },
                    child: Row(
                      children: [
                        Text(
                          "Machine Name: " + machineName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4.0),
                        Icon(
                          Icons.edit,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 21,
                  ),
                  Row(
                    children: [
                      Text(
                        'Machine State ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FlutterSwitch(
                        width: 70.0,
                        height: 27.0,
                        valueFontSize: 10.0,
                        toggleSize: 40.0,
                        value: machineState,
                        borderRadius: 30.0,
                        padding: 8.0,
                        toggleColor: Colors.black,
                        activeColor: Theme.of(context).primaryColor,
                        activeTextColor: Colors.black,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            machineState = val;
                            updateMachine(
                              docRef: machinesCollection.doc('$machineID'),
                              map: {
                                'state': val,
                              },
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 21,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
        onPressed: () {
          deleteMachine(
            docRef: machinesCollection.doc('$machineID'),
          );
        },
      ),
    );
  }

  Future<void> deleteMachine({
    required DocumentReference docRef,
  }) async {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Remove this Device?'),
            content: Text('This will remove your Device'),
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
                  showProgress();
                  docRef.delete().then((value) => {
                        EasyLoading.dismiss(),
                        Navigator.pop(context),
                        Navigator.pop(context),
                      });
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
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
            print('machine_detail_screen: $error');
          });
        } else {
          print('can\'t able to update name');
        }
      },
    );
  }

  void showNameDialogBox(String uid) {
    CustomEditDialog.showScaleEditDialog(
      hintText: 'Machine Name',
      context: context,
      message: '',
      title: 'Machine Name',
      buttonText: 'Change it',
      onPressed: () {
        //Check if Form is Valid
        var _isFormValid = CustomEditDialog.trySubmit();
        if (CustomEditDialog.textData != null && _isFormValid) {
          setState(() {
            machineName = CustomEditDialog.textData;
          });
          updateMachine(
            docRef: machinesCollection.doc('$uid'),
            map: {
              'machineName': CustomEditDialog.textData,
            },
          ).onError(
            (error, stackTrace) {
              EasyLoading.showError('Can\'t able to update name');
            },
          );
          Navigator.of(context).pop();
        }
      },
    );
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
