import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:motorcity_tracking/providers/requests.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatelessWidget {

  static const String routeName = "/settings";

  final TextEditingController _mg = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    Provider.of<Requests>(context).getServerIP().then((tmp){
      _mg.text = tmp;
    });

    return Scaffold(
            
            appBar: AppBar(
              title: Text("Settings", style: TextStyle(fontSize: 25),),
              ),
            body: Container(
              padding: EdgeInsets.only(right: 60, left: 60, top: 30),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
              Container(
                width: double.infinity,
                child: Text("MG Server IP", 
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      )
                    ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: TextField(
                  controller: _mg,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  onSubmitted: null,
                ),
              ),

               Container(
                width: double.infinity,
                child: Builder(
                  builder: (context2) => RaisedButton(
                  color: Colors.blue,
                  child: Text("Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    ),
                  ),
                  onPressed: ()  {
                    Provider.of<Requests>(context).serverIP=_mg.text;
                    Navigator.pop(context2);
                  }
                ),
              )
             )
            ],
          )
        )
      );
  }

}