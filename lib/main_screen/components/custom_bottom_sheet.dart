import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({Key? key}) : super(key: key);

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var _user = FirebaseAuth.instance.currentUser;

  CollectionReference machinesCollection =
      FirebaseFirestore.instance.collection('machines');

  final _machineNameTC = TextEditingController();
  final _machineIDTC = TextEditingController();

  String _machineName = '';
  String _machineID = '';

  Future<void> _addMachine() {
    // Call the user's CollectionReference to add a new user
    return machinesCollection
        .doc('$_machineID')
        .set({
          'uid': '${_user!.uid}', // John Doe
          'machineName': _machineName,
          'machineID': _machineID,
          'state': false,
        })
        .then((value) => print("Machine Added"))
        .catchError((error) => print("Failed to add Machine: $error"));
  }

  Future<bool> isAlreadyExists(String collection, String record) async {
    return await FirebaseFirestore.instance
        .collection('$collection')
        .doc('$record')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document exists on the database');
        return true;
      }
      return false;
    });
  }

  void _addRecord() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    showProgress();

    isAlreadyExists('machines', _machineID).then((value) => {
          if (value)
            {
              EasyLoading.showToast('Machine Already Attached'),
            }
          else
            {
              _addMachine().then(
                (value) {
                  EasyLoading.showSuccess('$_machineName Added');
                  Navigator.pop(context);
                },
              )
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 25,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
              ),

              Text(
                'Add Machine',
                style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Machine Name'),
                controller: _machineNameTC,
                keyboardType: TextInputType.text,
                onSaved: (value) {
                  _machineName = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Machine Name";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Machine ID'),
                controller: _machineIDTC,
                keyboardType: TextInputType.numberWithOptions(signed: false),
                maxLength: 6,
                onSaved: (value) {
                  _machineID = value!;
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value)!.isNegative) {
                    return "Enter Machine ID";
                  }
                  if (value.length > 6 || value.length < 6) {
                    return "Enter 6 digit Machine ID";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 30,
              ),
              //  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              MaterialButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: const Text(
                        "Add new machine",
                        style: TextStyle(fontSize: 20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                    ),
                    Icon(FontAwesomeIcons.cashRegister),
                  ],
                ),
                onPressed: _addRecord,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
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
