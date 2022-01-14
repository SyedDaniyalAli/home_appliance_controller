import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_appliance_controller/authentication_screen/authentication_screen.dart';
import 'package:home_appliance_controller/machine_detail_screen/machine_detail_screen.dart';

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
                  return MachineCard(
                      deviceId: data['machineID'],
                      machineName: data['machineName'],
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
            child: Icon(Icons.add),
            onPressed: () {
              _showTransactionModalSheet(context);
            },
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.power_settings_new_outlined),
            onPressed: () => _logout(),
            heroTag: null,
          )
        ]),
      ),
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
