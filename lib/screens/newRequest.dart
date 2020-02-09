import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/driver.dart';
import '../models/location.dart';
import '../models/model.dart';
import '../providers/formData.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import '../screens/home.dart';

class NewRequestScreen extends StatefulWidget {
  static String routeName = "/newRequest";

  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  String _apiKey = "AIzaSyDXX99ZU6zY1RMsTrAMpQxC5rRk8_LrwQ4";
  //load form data
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<FormDataProvider>(context, listen: false).loadModels();
    });
    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<FormDataProvider>(context, listen: false).loadDrivers();
    });
    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<FormDataProvider>(context, listen: false)
          .loadLocations();
    });
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  //Drop down list vars
  String _selectedDriver;
  String _selectedModel;
  String _selectedStartLocation;
  String _selectedEndLocation;

  String _startLocation = "N/A";
  String _endLocation = "N/A";

  //TextControllers vars
  TextEditingController _chassisController = new TextEditingController();
  TextEditingController _kmsController = new TextEditingController();
  TextEditingController _priorityController =
      new TextEditingController(text: '500');
  TextEditingController _startLongController = new TextEditingController();
  TextEditingController _startLattController = new TextEditingController();
  TextEditingController _endLongController = new TextEditingController();
  TextEditingController _endLattController = new TextEditingController();
  TextEditingController _commentController = new TextEditingController();

  static InputDecoration textDecorators(String label) => InputDecoration(
      labelText: label,
      errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      alignLabelWithHint: true,
      labelStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white)),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[300], width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[300], width: 2),
        borderRadius: BorderRadius.circular(15),
      ));

  static double textContainersPadding = 5;
  static double dropContainersPadding = 5;
  static double textContainersHeight = 90;
  static double dropContainersHeight = 40;

  static TextStyle textFormStyle = TextStyle(fontSize: 16, color: Colors.white);
  static TextStyle dropSelectedFormStyle =
      TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold);
  static TextStyle textDropStyle = TextStyle(
    fontSize: 16,
    color: Color.fromRGBO(0, 46, 72, 1),
    fontWeight: FontWeight.bold,
  );

  static Container textFormFieldContainer(
      label, TextEditingController controller, Function validator,
      {TextInputType keyboard = TextInputType.text}) {
    return Container(
      padding: EdgeInsets.only(
          top: textContainersPadding, bottom: textContainersPadding),
      width: double.infinity,
      height: textContainersHeight,
      child: TextFormField(
          controller: controller,
          cursorColor: Colors.white,
          decoration: textDecorators(label),
          validator: validator,
          keyboardType: keyboard,
          style: textFormStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Create New Request"),
        backgroundColor: Color.fromRGBO(0, 46, 72, 0.5),
      ),
      body: Builder(builder: (context) {
        return Container(
          color: Color.fromRGBO(0, 46, 72, 0.5),
          height: MediaQuery.of(context).size.height - 0,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(5),
            child: Form(
              key: _formKey,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: EdgeInsets.only(bottom: textContainersPadding),
                        width: double.infinity,
                        child: Text("Pick the Model: ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: EdgeInsets.only(bottom: dropContainersPadding),
                        width: double.infinity,
                        height: dropContainersHeight,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          style: textFormStyle,
                          underline: Container(
                              margin: EdgeInsets.only(top: 30),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.white)))),
                          selectedItemBuilder: (BuildContext context) {
                            return Provider.of<FormDataProvider>(context)
                                .models
                                .map<Widget>((Model item) {
                              return Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  item.name,
                                  textAlign: TextAlign.left,
                                  style: dropSelectedFormStyle,
                                ),
                              );
                            }).toList();
                          },
                          items: Provider.of<FormDataProvider>(context)
                              .models
                              .map((Model mod) {
                            return DropdownMenuItem<String>(
                              value: mod.id,
                              child: Container(
                                  child: Text(mod.name, style: textDropStyle),
                                  width: 200),
                            );
                          }).toList(),
                          onChanged: onModelDropChange,
                          value: _selectedModel,
                        ),
                      ),
                    ),
                    Flexible(
                        fit: FlexFit.loose,
                        child: textFormFieldContainer(
                            "Chassis", _chassisController, (value) {
                          if (value.isEmpty) {
                            return "Please enter a Chassis Number";
                          }
                          return null;
                        })),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(width: 1, color: Colors.white)),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: textContainersPadding),
                              width: double.infinity,
                              child: Text("Pick the Start Location: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  flex: 8,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    style: textFormStyle,
                                    underline: Container(
                                        margin: EdgeInsets.only(top: 20),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.white)))),
                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return Provider.of<FormDataProvider>(
                                              context)
                                          .locations
                                          .map<Widget>((Location item) {
                                        return Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(
                                            item.name,
                                            textAlign: TextAlign.left,
                                            style: dropSelectedFormStyle,
                                          ),
                                        );
                                      }).toList();
                                    },
                                    items:
                                        Provider.of<FormDataProvider>(context)
                                            .locations
                                            .map((Location loc) {
                                      return DropdownMenuItem<String>(
                                        value: loc.id,
                                        child: Container(
                                            child: Text(loc.name,
                                                style: textDropStyle),
                                            width: 200),
                                      );
                                    }).toList(),
                                    onChanged: onStartLocationDropChange,
                                    value: _selectedStartLocation,
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: Center(
                                      child: FloatingActionButton(
                                        backgroundColor:
                                            Color.fromRGBO(0, 46, 72, .9),
                                        onPressed: () async {
                                          LocationResult result =
                                              await showLocationPicker(
                                                  context, _apiKey);
                                          print("result = $result");
                                          setState(() {
                                            if (result != null) {
                                              _startLocation = "N/A";
                                              _startLattController.text = result
                                                  .latLng.latitude
                                                  .toString();
                                              _startLongController.text = result
                                                  .latLng.longitude
                                                  .toString();
                                            }
                                          });
                                        },
                                        child: Center(
                                            child: Icon(Icons.location_on)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Color.fromRGBO(0, 46, 72, 0.2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      margin: EdgeInsets.all(2.5),
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        style: textFormStyle,
                                        controller: _startLattController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        readOnly: true,
                                      ),
                                    )),
                                Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Color.fromRGBO(0, 46, 72, 0.2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      margin: EdgeInsets.all(2.5),
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        controller: _startLongController,
                                        style: textFormStyle,
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        readOnly: true,
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(width: 1, color: Colors.white)),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: textContainersPadding),
                              width: double.infinity,
                              child: Text("Pick the End Location: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.loose,
                                  flex: 8,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    style: textFormStyle,
                                    underline: Container(
                                        margin: EdgeInsets.only(top: 20),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.white)))),
                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return Provider.of<FormDataProvider>(
                                              context)
                                          .locations
                                          .map<Widget>((Location item) {
                                        return Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(
                                            item.name,
                                            textAlign: TextAlign.left,
                                            style: dropSelectedFormStyle,
                                          ),
                                        );
                                      }).toList();
                                    },
                                    items:
                                        Provider.of<FormDataProvider>(context)
                                            .locations
                                            .map((Location loc) {
                                      return DropdownMenuItem<String>(
                                        value: loc.id,
                                        child: Container(
                                            child: Text(loc.name,
                                                style: textDropStyle),
                                            width: 200),
                                      );
                                    }).toList(),
                                    onChanged: onEndLocationDropChange,
                                    value: _selectedEndLocation,
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: Center(
                                      child: FloatingActionButton(
                                        heroTag: "end",
                                        backgroundColor:
                                            Color.fromRGBO(0, 46, 72, .9),
                                        onPressed: () async {
                                          LocationResult result =
                                              await showLocationPicker(
                                                  context, _apiKey);
                                          setState(() {
                                            if (result != null) {
                                              _endLocation = "N/A";
                                              _endLattController.text = result
                                                  .latLng.latitude
                                                  .toString();
                                              _endLongController.text = result
                                                  .latLng.longitude
                                                  .toString();
                                            }
                                          });
                                        },
                                        child: Center(
                                            child: Icon(Icons.location_on)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Color.fromRGBO(0, 46, 72, 0.2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      margin: EdgeInsets.all(2.5),
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        style: textFormStyle,
                                        controller: _endLattController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        readOnly: true,
                                      ),
                                    )),
                                Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Color.fromRGBO(0, 46, 72, 0.2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      margin: EdgeInsets.all(2.5),
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        controller: _endLongController,
                                        style: textFormStyle,
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        readOnly: true,
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: textFormFieldContainer("KMs", _kmsController,
                          (value) {
                        if (value.isEmpty) {
                          return "Please enter Number of KMs";
                        } else if (!isNumeric(value)) {
                          return "Please enter a valid number";
                        }
                        return null;
                      }),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: EdgeInsets.only(bottom: textContainersPadding),
                        width: double.infinity,
                        child: Text("Pick the Driver: ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: EdgeInsets.only(bottom: dropContainersPadding),
                        width: double.infinity,
                        height: dropContainersHeight,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          style: textFormStyle,
                          underline: Container(
                              margin: EdgeInsets.only(top: 20),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.white)))),
                          selectedItemBuilder: (BuildContext context) {
                            return Provider.of<FormDataProvider>(context)
                                .drivers
                                .map<Widget>((Driver item) {
                              return Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  item.name,
                                  textAlign: TextAlign.left,
                                  style: dropSelectedFormStyle,
                                ),
                              );
                            }).toList();
                          },
                          items: Provider.of<FormDataProvider>(context)
                              .drivers
                              .map((Driver driver) {
                            return DropdownMenuItem<String>(
                              value: driver.id,
                              child: Container(
                                  child:
                                      Text(driver.name, style: textDropStyle),
                                  width: 200),
                            );
                          }).toList(),
                          onChanged: onDriverDropChange,
                          value: _selectedDriver,
                        ),
                      ),
                    ),
                    Flexible(
                        fit: FlexFit.loose,
                        child: textFormFieldContainer(
                            "Priority", _priorityController, (value) {
                          if (value.isEmpty) {
                            return "Please enter the Priotity Number";
                          } else if (!isNumeric(value)) {
                            return "Please enter a valid number";
                          }
                          return null;
                        })),
                    Flexible(
                        fit: FlexFit.loose,
                        child: textFormFieldContainer(
                            "Comment", _commentController, null,
                            keyboard: TextInputType.multiline)),
                    Container(
                        width: 200,
                        height: 40,
                        child: new RaisedButton(
                          color: Color.fromRGBO(0, 46, 72, .9),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          onPressed: () => submitForm(context),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void onDriverDropChange(String value) {
    setState(() {
      _selectedDriver = value;
    });
  }

  void onStartLocationDropChange(String value) {
    setState(() {
      _selectedStartLocation = value;
      Location tmp = Provider.of<FormDataProvider>(context, listen: false)
          .getLocationByID(value);
      _startLocation = tmp.name;
      _startLattController.text = tmp.latt;
      _startLongController.text = tmp.long;
    });
  }

  void onEndLocationDropChange(String value) {
    setState(() {
      _selectedEndLocation = value;
      Location tmp = Provider.of<FormDataProvider>(context, listen: false)
          .getLocationByID(value);
      _endLocation = tmp.name;
      _endLattController.text = tmp.latt;
      _endLongController.text = tmp.long;
    });
  }

  void onModelDropChange(String value) {
    setState(() {
      _selectedModel = value;
    });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    try {
      return double.parse(s) is double;
    } catch (e) {
      return false;
    }
  }

  Future<Null> submitForm(context) async {
    if (_formKey.currentState.validate()) {
      String modelID = this._selectedModel;
      if (modelID == null) {
        _showMessage("Please pick a model!", context);
        return;
      }
      if (_startLocation == null ||
          _startLongController.text == '' ||
          _startLattController.text == '') {
        _startLocation = "N/A";
      }
      if (_endLocation == null ||
          _endLongController.text == '' ||
          _endLattController.text == '') {
        _endLocation = "N/A";
      }
      String driverID = this._selectedDriver;
      if (driverID == null) {
        _showMessage("Please pick a driver!", context);
        return;
      }
      bool formResult =
          await Provider.of<FormDataProvider>(context, listen: false)
              .postRequest(
                  chassis: _chassisController.text,
                  comment: _commentController.text,
                  driverID: driverID,
                  endLatt: _endLattController.text,
                  endLocationName: _endLocation,
                  endLong: _endLongController.text,
                  kms: _kmsController.text,
                  modelID: modelID,
                  priority: _priorityController.text,
                  startLatt: _startLattController.text,
                  startLocationName: _startLocation,
                  startLong: _startLongController.text);
      if (formResult) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [new Text("Request Saved!")]),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed( HomeScreen.routeName);
                  },
                ),
              ],
            );
          },
        );

      } else {
        _showMessage(
            "We are sorry but Request Failed! Please check your data and try again.",
            context);
      }
    }
  }

  void _showMessage(String msg, context) {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(msg)));
  }
}
