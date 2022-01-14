import 'package:flutter/material.dart';

class CustomEditDialog {
  static var _withFormValue;

  static final GlobalKey<FormState> _formKey = GlobalKey();

  static get textData => _withFormValue;

  static bool trySubmit() {
    bool isCorrect = false;
    isCorrect = _formKey.currentState!.validate();
    return isCorrect;
  }

  // Show simple Edit Dialog~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  static void showSimpleEditDialog({
    required final GestureTapCallback onPressed,
    required final String title,
    required final String message,
    required final BuildContext context,
    required final String buttonText,
    required final String hintText,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        // backgroundColor: Colors.white.withOpacity(0.8),
        // backgroundColor: Colors.black.withOpacity(0.5),
        title: Text('$title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != '') Text('$message'),
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value!.length > 20) {
                    return 'Max length is 20';
                  }
                  if (value.length < 3) {
                    return 'Min length is 3';
                  }
                  if (value.isEmpty) {
                    return 'Enter name to continue';
                  }
                  return null;
                },
                onChanged: (value) {
                  _withFormValue = value.trim();
                },
                maxLength: 20,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '$hintText',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: MaterialButton(
              textColor: Theme.of(context).primaryColor,
              // OPTIONAL BUTTON
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: Colors.white,
              child: Text('$buttonText'),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }

  // Show simple Edit Dialog~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  static void showScaleEditDialog({
    required final GestureTapCallback onPressed,
    required final String title,
    required final String message,
    required final BuildContext context,
    required final String buttonText,
    required final String hintText,
  }) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue =
            Curves.fastOutSlowIn.transform(animation.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
              // backgroundColor: Colors.white.withOpacity(0.8),
              // backgroundColor: Colors.black.withOpacity(0.5),
              title: Text('$title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message != '') Text('$message'),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter name to continue';
                        }
                        if (value.length > 20) {
                          return 'Max length is 20';
                        }
                        if (value.length < 3) {
                          return 'Min length is 3';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _withFormValue = value.trim();
                      },
                      maxLength: 20,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: '$hintText',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                    textColor: Theme.of(context).primaryColor,
                    // OPTIONAL BUTTON
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    color: Colors.white,
                    child: Text('$buttonText'),
                    onPressed: onPressed),
              ],
            ),
          ),
        );
      },
    );
  }
}
