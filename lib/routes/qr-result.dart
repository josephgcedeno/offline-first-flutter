import 'package:flutter/material.dart';

import '../widgets/header.dart';

class QRResult extends StatelessWidget {
  final qrData;
  final Function rescan;

  QRResult(this.qrData, this.rescan);

  final _headerTitle = "QR Data";
  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    final _theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        rescan();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: Header(_headerTitle),
        body: Container(
          margin: EdgeInsets.only(
            left: _mediaQuery.size.width * 0.15,
            right: _mediaQuery.size.width * 0.15,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(_mediaQuery.size.height * 0.02),
                        child: Text(
                          qrData,
                          style: _theme.textTheme.bodyText1
                              .copyWith(color: Colors.black, fontSize: 22),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_mediaQuery.size.height * 0.02),
                        child: Text(
                          '[unique_id]',
                          style: _theme.textTheme.headline4.copyWith(
                            fontSize: 18,
                          ),
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [_theme.primaryColor, _theme.accentColor],
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        rescan();
                      },
                      label: Text('Scan again',
                          style: TextStyle(color: Colors.white)),
                      icon: Icon(
                        Icons.center_focus_weak,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
