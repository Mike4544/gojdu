import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gojdu/others/options.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../widgets/Event.dart';

/// A variation of the [print] method that prints only in [Debug mode]
///
/// Made it so that there won't be any bottlenecks
void m_debugPrint(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

/// Just a [User] to get from the [Pending] state
class User {
  final String name, email, type, token;
  User(
      {required this.name,
      required this.email,
      required this.type,
      required this.token});

  static const _user = 'user';
  static const _email = 'email';
  static const _type = 'type';
  static const _token = 'token';

  static User fromJson(Map json) => User(
      name: json[_user],
      email: json[_email],
      type: json[_type],
      token: json[_token]);
}

/// A class that handles all the connections to the database and back
///
/// TODO: Add all the remaining functions + organizing the files on the server
class Api {
  final BuildContext context;
  Api({required this.context});

  ///  Loads the [Pending] teachers from the database
  Future<List<User>> loadUsers() async {
    List<User> users = [];

    try {
      var url =
          Uri.parse('${Misc.link}/${Misc.appName}/users/select_users.php');
      final response = await http.post(url, body: {
        'state': 'Pending',
      });
      //debugPrint(response.statusCode);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        //  //debugPrint(jsondata.toString());

        if (jsondata[0]["error"]) {
          // setState(() {
          //   //nameError = jsondata["message"];
          // });
        } else {
          if (jsondata[0]["success"]) {
            // _names.clear();
            // _emails.clear();
            // _types.clear();
            // _tokens.clear();

            for (int i = 1; i <= jsondata.length; i++) {
              users.add(User.fromJson(jsondata[i]));
            }
          } else {
            ////debugPrint(jsondata["1"]["message"]);
          }
        }
      }
    } catch (e) {
      //debugPrint(e);
    }

    //  return 0;
    return users;
  }

  /// Notifies a user through the [token] param
  ///
  Future<void> notifyUser(String? token) async {
    try {
      var ulr2 = Uri.parse('${Misc.link}/${Misc.appName}/notifications.php');
      final response2 = await http.post(ulr2, body: {
        "action": "Verify",
        "token": token,
      });

      if (response2.statusCode == 200) {
        //  var jsondata2 = json.decode(response2.body);
        ////debugPrint(jsondata2);

      }
    } catch (e) {
      //debugPrint(e);
    }
  }

  Future verifyUser(User user, List data, int index) async {
    try {
      var ulr2 = Uri.parse('${Misc.link}/${Misc.appName}/verify_accounts.php');
      final response2 = await http.post(ulr2, body: {
        "email": user.email,
        "code": "NO_CODE"
      }).timeout(const Duration(seconds: 15));

      if (response2.statusCode == 200) {
        var jsondata2 = json.decode(response2.body);
        ////debugPrint(jsondata2);
        if (jsondata2['error'] == false) {
          m_debugPrint("Success");
          notifyUser(user.token);

          data.removeAt(index);
        }
      } else {
        return throw Exception('Couldn\'t connect');
      }
    } on TimeoutException catch (e) {
      return throw Exception('Timeout');
      //debugPrint(e);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
