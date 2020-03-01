import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:motorcity_tracking/screens/newRequest.dart';
import 'package:provider/provider.dart';
import 'package:motorcity_tracking/providers/requests.dart';
import 'package:motorcity_tracking/widgets/request.dart';
import 'package:fab_menu/fab_menu.dart';
import 'package:motorcity_tracking/screens/settings.dart';
import 'package:motorcity_tracking/screens/login.dart';
import 'package:motorcity_tracking/providers/auth.dart';

//Home Screen with all in-pending requests
bool _isLoading = true;

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MenuData> menuDataList = [];

  _refreshPage(BuildContext context) {
    return Provider.of<Requests>(context, listen: false).loadRequests(force: true);
  }

  @override
  void initState() {
    super.initState();
    menuDataList = [
      //Settings Menu Item
      new MenuData(Icons.refresh, (context, menuData) {
       _refreshPage(context);
      }, labelText: "Refresh"),
      //New Request Menu Item
      new MenuData(Icons.add_location, (context, menuData) {
        Navigator.push(context,  PageTransition( child: NewRequestScreen(), type: PageTransitionType.upToDown, duration: Duration(milliseconds: 500)) );
      }, labelText: "New Request"),
      //Settings Menu Item
      new MenuData(Icons.settings, (context, menuData) {
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
      }, labelText: "Settings"),
      //Logout Menu Item
      new MenuData(Icons.lock_outline, (context, menuData) {
        Provider.of<Auth>(context, listen: false).logout();
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }, labelText: "Logout"),
    ];
  }

  @override
  void didChangeDependencies() async {
    await Provider.of<Requests>(context).loadRequests();
    _isLoading = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("In-Progess"),
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
                    builder: (context, requestsProv, _) {
                      if (requestsProv.requests.length > 0) {
                        return ListView(
                            children: requestsProv.requests.map((tmp) {
                          return RequestItem(tmp);
                        }).toList());
                      } else {
                        return SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height - 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  flex: 8,
                                  child: Opacity(
                                    opacity: 0.2,
                                    child: Image.asset(
                                        "assets/images/noRequests.png"),
                                  ),
                                ),
                                Flexible(
                                    flex: 3,
                                    child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Opacity(
                                          opacity: 0.4,
                                          child: Text("...no requests...")),
                                    ))
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
