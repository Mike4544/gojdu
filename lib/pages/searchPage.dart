import 'dart:convert';

import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/api.dart';
import 'package:gojdu/others/options.dart';
//  Import colorsB
import "../others/colors.dart";
// Import lazyBuilder
import "../widgets/lazyBuilder.dart";
//  Import the search bar and the filters.dart
import "../widgets/searchBar.dart";
import "../widgets/filters.dart";
// Import the opportunities page for the opportunity card, and the offers page
// for the offer card
import "opportunities.dart";
import "offersPage.dart";

// import http as http
import "package:http/http.dart" as http;

class SearchResultPage extends StatefulWidget {
  final SearchType searchType;
  final String searchTerm;
  final List<mFilterChip> filters;

  const SearchResultPage(
      {Key? key,
      required this.searchType,
      required this.searchTerm,
      required this.filters})
      : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late List<mFilterChip> searchedFilters;

  @override
  initState() {
    super.initState();

    lazyController = ScrollController();

    lazyController.addListener(lazyLoadCallback);

    searchResults = [];

    searchedFilters =
        widget.filters.map((e) => e.copyWith(onDelete: null)).toList();
  }

  Widget searchRes() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Search results for: ${widget.searchTerm}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30.sp,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Add the filters
          Wrap(
            children: searchedFilters.map((e) {
              return Padding(padding: const EdgeInsets.all(8.0), child: e);
            }).toList(),
          ),
        ],
      );

  Future getSearchResults() async {
    String file;

    switch (widget.searchType) {
      case SearchType.activities:
        file = "searchOpportunities.php";
        break;
      case SearchType.offers:
        file = "searchOffers.php";
        break;
      case SearchType.defaultSearch:
        file = "DEF.php";
        break;
    }

    List temp = searchedFilters.map((e) => e.label).toList();

    String filts = jsonEncode(temp);

    Map<String, dynamic> sendQuery = {
      'lastID': lastID.toString(),
      'turns': turns.toString(),
      "searchTerm": widget.searchTerm,
      "filters": filts,
    };

    String link = "${Misc.link}/${Misc.appName}/searchAPI/$file";

    switch (widget.searchType) {
      case SearchType.activities:
        searchResults.addAll(await loadActivities(link, sendQuery));
        break;
      case SearchType.offers:
        searchResults.addAll(await loadOffers(link, sendQuery));
        break;
    }
    m_debugPrint(sendQuery);
  }

  Future<void> _refresh() async {
    searchResults.clear();

    maxScrollCount = turns;
    lastMax = -1;

    lastID = Misc.lastID;

    search = getSearchResults();

    setState(() {});
  }

  Future<List<OpportunityCard>> loadActivities(
      String link, Map sendQuery) async {
    lastMax = maxScrollCount;

    List<OpportunityCard> cards = [];

    try {
      var url = Uri.parse(link);

      var response = await http.post(url, body: sendQuery);
      m_debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata);

        if (jsondata[0]['success']) {
          Map gmap = {"id": -999, "account": "NaN"};

          for (int i = 1; i < jsondata.length; i++) {
            cards.add(OpportunityCard.fromJson(jsondata[i], gmap, () {}));
          }
        }

        maxScrollCount += turns;
        lastID = cards.last.id;
      }
    } catch (e, s) {
      m_debugPrint(e);
      m_debugPrint(s);
    }

    return cards;
  }

  Future<List<OfferContainer>> loadOffers(String link, Map sendQuery) async {
    lastMax = maxScrollCount;

    List<OfferContainer> cards = [];

    try {
      var url = Uri.parse(link);
      var response = await http.post(url, body: sendQuery);
      m_debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        m_debugPrint(jsondata);

        if (jsondata[0]['success']) {
          Map gmap = {"id": -999, "account": "NaN"};

          for (int i = 1; i < jsondata.length; i++) {
            cards.add(OfferContainer.fromJson(jsondata[i], gmap, () {}));
          }

          maxScrollCount += turns;
          lastID = cards.last.id;
        }
      }
    } catch (e, s) {
      m_debugPrint(e);
      m_debugPrint(s);
    }

    return cards;
  }

  late List<Widget> searchResults;

  late Future search = getSearchResults();

  int lastMax = Misc.lastMax;
  int maxScrollCount = Misc.maxScrollCount;
  int lastID = Misc.lastID;
  int turns = Misc.turns;

  late ScrollController lazyController;

  void lazyLoadCallback() async {
    if (lastMax == maxScrollCount) return;

    if (lazyController.position.extentAfter == 0 && lastMax < maxScrollCount) {
      m_debugPrint('Haveth reached the end');

      search = getSearchResults();

      print("Last max: $lastMax");
      print("Max scroll count: $maxScrollCount");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsB.gray900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white54,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with: "Search results for: ", with the search result appended
            searchRes(),
            Expanded(
              child: LazyBuilder(
                  future: search,
                  widgetList: searchResults,
                  lastID: lastID,
                  lastMax: lastMax,
                  maxScrollCount: maxScrollCount,
                  refresh: _refresh,
                  scrollController: lazyController,
                  turns: turns),
            )
          ],
        ),
      ),
    );
  }
}
