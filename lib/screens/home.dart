import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motorcity_tracking/providers/requests.dart';
import 'package:motorcity_tracking/widgets/request.dart';
import 'package:fab_menu/fab_menu.dart';
import 'package:motorcity_tracking/screens/settings.dart';
import 'package:motorcity_tracking/screens/login.dart';
import 'package:motorcity_tracking/providers/auth.dart';

//Home Screen with all in-pending requests

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  List<MenuData> menuDataList = [];

  _refreshPage(BuildContext context){

    return Provider.of<Requests>(context).loadRequests(force: true);

  }

  @override
  void initState(){
    super.initState();
    menuDataList = [
      //Settings Menu Item
      new MenuData(Icons.settings, (context, menuData){
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
      },
      labelText: "Settings"),
    //Logout Menu Item
    new MenuData(Icons.lock_outline, (context, menuData){
        Provider.of<Auth>(context).logout();
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }, labelText: "Logout"),
    
    ];
  }
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Provider.of<Requests>(context).loadRequests();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Motorcity Tracking"),
      ),
      floatingActionButton: new FabMenu(
          menus: menuDataList,
          maskColor: Colors.black,
        ),
        floatingActionButtonLocation: fabMenuLocation,
      body: RefreshIndicator(
            onRefresh: () => _refreshPage(context),
              child: Center(
          child: Container(
            child: (_isLoading)
                ? CircularProgressIndicator()
                : Consumer<Requests>(
                    builder: (context, requestsProv, _){
                      return ListView(
                      children: requestsProv.requests.map((tmp){
                        return RequestItem(tmp);
                      }).toList()
                    );
                    },
     
                ),
          ),
        ),
      ),
    );
  }
}
