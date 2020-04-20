import 'package:flutter/material.dart';
import 'package:motorcity_tracking/widgets/request.dart';
import 'package:provider/provider.dart';
import 'package:motorcity_tracking/providers/requests.dart';

bool _isLoading = true;

class HistoryScreen extends StatefulWidget {
  static const String routeName = "/history";

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _refreshPage(BuildContext context) {
    return Provider.of<Requests>(context).loadHistory();
  }

  @override
  void didChangeDependencies() async {
    await Provider.of<Requests>(context).loadHistory();
    _isLoading = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshPage(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("History"),
        ),
        body: Center(
          child: Container(
            child: (_isLoading)
                ? CircularProgressIndicator()
                : Consumer<Requests>(
                    builder: (context, requestsProv, _) {
                      if (requestsProv.history.length > 0) {
                        return ListView.builder(
                          itemBuilder: (ctx, index) {
                            return RequestItem(requestsProv.history[index]);
                          },
                          itemCount: requestsProv.history.length,
                        );
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
                                          child: Text("...no history...")),
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
