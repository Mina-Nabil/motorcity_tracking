import 'package:motorcity_tracking/models/truckrequest.dart';

import 'package:flutter/material.dart';
import '../screens/map.dart';

class RequestItem extends StatelessWidget {
  final TruckRequest req;

  RequestItem(this.req);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(5),
        color: (req.status == '1') ? Colors.green[100] : Colors.blue[50],
        child: FlatButton(
            onPressed: () => Navigator.of(context)
                .pushNamed(MapScreen.routeName, arguments: req.id),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: Image.asset((req.status == '1')
                          ? "assets/images/new.png"
                          : "assets/images/in-progress.png"),
                    ),
                    Flexible(
                      flex: 8,
                      fit: FlexFit.loose,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 15),
                                child: Text('Request# ${req.id}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    'since ${req.reqDate}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 5,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  padding: EdgeInsets.only(top: 5, left: 15),
                                  child: Text(
                                    'Driver: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text('${req.driverName}',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.left),
                                ))
                              ],
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 5,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  padding: EdgeInsets.only(top: 5, left: 15),
                                  child: Text(
                                    'From: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text('${req.from}',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.justify),
                                ))
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                 padding: EdgeInsets.only(left: 15, top: 5),
                                 width: 70,
                                  child: Text(
                                    'To: ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  '${req.to}',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.left,
                                ))
                              ],
                            ),
                          ),
                          Row(children: <Widget>[
                            Container(
                                width: 70,
                                padding: EdgeInsets.only(left: 15, top: 5),
                                child: Text(
                                  "Car: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )),
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${req.chassis} - ${req.model}',
                                    style: TextStyle(fontSize: 16),
                                  )),
                            )
                          ]),
                        ],
                      ),
                    ),
                  ]),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 15, top: 5),
                    child: Text(
                      '${req.comment}',
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )));
  }
}
