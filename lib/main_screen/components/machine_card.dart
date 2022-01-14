import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MachineCard extends StatelessWidget {
  final String deviceId;
  final String machineName;
  final GestureTapCallback onPressed;

  const MachineCard(
      {Key? key,
      required this.deviceId,
      required this.machineName,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 7),
      child: Card(
        elevation: 7,
        shadowColor: Colors.blue,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.indigo),
        ),
        color: Colors.blue.shade200,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.microchip,
                      size: 35,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appliance Name: $machineName',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Device ID: $deviceId',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
