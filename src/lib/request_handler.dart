import 'package:requests/requests.dart';
import 'dart:convert';
import 'dart:async';

class SurveyRequest {
  Map<String, dynamic> data;

  void makeRequest() async {
    String url = "https://z5vplyleb9.execute-api.ap-southeast-2.amazonaws.com/release/createAudit";
    var request = await Requests.post(
     url,
     body: jsonEncode(data),
     bodyEncoding: RequestBodyEncoding.FormURLEncoded
    );
    request.raiseForStatus();
    dynamic json = request.json();
    print(json["id"]);
  }
}
