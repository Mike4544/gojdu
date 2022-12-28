//  Import material
import 'package:flutter/material.dart';
import 'package:gojdu/others/api.dart';
import 'package:gojdu/others/colors.dart';

// Import the news and oppotunity pages
import '../others/options.dart';
import './news.dart' as ns;
import './opportunities.dart' as op;

// Import http and dart:convert
import 'package:http/http.dart' as http;
import 'dart:convert';

// This will have a future builder that will show a post or an opportunity,
// depending on the type of notification
class SeePostNotif extends StatelessWidget {
  final int id;
  final int uid;
  const SeePostNotif({Key? key, required this.id, required this.uid})
      : super(key: key);

  Future<Map> getPost(int id) async {
    // Get the url
    var url =
        Uri.parse('${Misc.link}/${Misc.appName}/postsAPI/getPostFromID.php');
    var response = await http
        .post(url, body: {'id': id.toString(), "uid": uid.toString()});
    var data = jsonDecode(response.body);
    m_debugPrint(data['1']);
    if (data['success'] == true) {
      return data['1'];
    } else {
      return {
        'title': 'Error',
        'post': 'There was an error while loading the post',
        'owner': 'Error',
        'oid': 0,
        'id': 0,
        'author': "Error"
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: getPost(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ns.BigNewsContainer(
            shouldShowComments: true,
            title: snapshot.data!['title'] ?? 'Error',
            description: snapshot.data!['post'] ??
                'There was an error while loading the post',
            color: ColorsB.gray800,
            author: snapshot.data!["owner"] ?? 'Error',
            imageLink: snapshot.data!["link"] ?? '',
            likesBool: snapshot.data!["userLikes"] > 0 ?? false,
            dislikes: snapshot.data!["userDislikes"] > 0 ?? false,
            likes: snapshot.data!["likes"] ?? 0,
            ownerID: snapshot.data!["oid"] ?? -999,
            id: snapshot.data!['id'] ?? -999,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ColorsB.yellow500),
            ),
          );
        }
      },
    );
  }
}
