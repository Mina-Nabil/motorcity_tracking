import 'dart:convert';

import "package:http/http.dart" as http;

const DISTANCE_TIME_GOOGLE_API_KEY = 'AIzaSyAN3Ba5-MW6y8g2eyL57Ls9IFDDC9mwf8E';

class GoogleDistanceTime {

  static Future<String> getResponse (double startLatt,double startLong,double endLatt,double endLong) async{
    final request = await http.get('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$startLatt,$startLong&destinations=$endLatt,$endLong&key=$DISTANCE_TIME_GOOGLE_API_KEY');
    if(request.statusCode == 200)
    {
      // dynamic body = jsonDecode(request.body);
      // print(body["rows"][0]["elements"][0]["distance"]["text"]);
      // print(body["rows"][0]["elements"][0]["duration"]["text"]);

      return request.body;
    }else 
    {
      return "";
    }
  }
  
}
