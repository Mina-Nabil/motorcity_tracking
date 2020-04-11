import 'package:page_transition/page_transition.dart';
import 'package:motorcity_tracking/models/truckrequest.dart';

import 'package:flutter/material.dart';
import '../screens/map.dart';

class RequestItem extends StatefulWidget {
  final TruckRequest req;

  RequestItem(this.req);

  @override
  _RequestItemState createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {

  bool isLoaded = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await widget.req.fillTimeDistance();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      color: (widget.req.status == '1') ? Colors.green[100] : Colors.blue[50],
      child: FlatButton(
        onPressed: () {
          if (widget.req.status == '2') {
            Navigator.push(
                context,
                PageTransition(
                    child: MapScreen(widget.req.id),
                    type: PageTransitionType.leftToRight,
                    duration: Duration(milliseconds: 600)));
          } else {
            Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text(
                    "Oops! No driver data available, Request is new.")));
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Image.asset((widget.req.status == '1')
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
                            child: Text('Request# ${widget.req.id}',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topRight,
                              child: Text(
                                'since ${widget.req.reqDate}',
                                textAlign: TextAlign.right,
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
                              width: 80,
                              padding: EdgeInsets.only(top: 5, left: 15),
                              child: Text(
                                'Driver:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Text('${widget.req.driverName}',
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
                              width: 80,
                              padding: EdgeInsets.only(top: 5, left: 15),
                              child: Text(
                                'From: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Text('${widget.req.from}',
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
                              width: 80,
                              child: Text(
                                'To: ',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: Text(
                              '${widget.req.to}',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ))
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                              width: 80,
                              padding: EdgeInsets.only(left: 15, top: 5),
                              child: Text(
                                "Car: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.only(top: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${widget.req.chassis} - ${widget.req.model}',
                                  style: TextStyle(fontSize: 16),
                                )),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.only(top: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  (isLoaded) ? '${widget.req.distanceStr}' : "Loading..",
                                  style: TextStyle(fontSize: 16),
                                )),
                          ),
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.only(top: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  (isLoaded) ?  '${widget.req.timeStr}' :  "Loading..",
                                  style: TextStyle(fontSize: 16),
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 15, top: 5),
                child: Text(
                  '${widget.req.comment}',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
