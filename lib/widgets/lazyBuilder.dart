import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../others/colors.dart';
import '../others/options.dart';

class LazyBuilder extends StatefulWidget {
  Future future;
  //  Future futureFunction;
  List<dynamic> widgetList;
  //  Widget loaderWidget;
  Function({int? lastMax, int? newMax, int? newID, Future? func}) update;
  Function refresh;
  ScrollController scrollController;
  int lastMax;
  int maxScrollCount;
  int turns;
  int lastID;

  LazyBuilder(
      {Key? key,
      required this.future,
      //  required this.futureFunction,
      required this.widgetList,
      //  required this.loaderWidget,
      required this.lastID,
      required this.update,
      required this.lastMax,
      required this.maxScrollCount,
      required this.refresh,
      required this.scrollController,
      required this.turns})
      : super(key: key);

  @override
  State<LazyBuilder> createState() => _LazyBuilderState();
}

class _LazyBuilderState extends State<LazyBuilder> {
  //  late ScrollController _scrollController;

  // int lastMax = -1; //  INT MAX
  // int maxScrollCount = 10;
  // int turns = 10;
  // int lastID = Misc.INT_MAX;

  @override
  void initState() {
    // _scrollController = ScrollController();

    // _scrollController.addListener(widget.lazyLoadCallback);

    super.initState();
  }

  @override
  void dispose() {
    //  _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(10.0),
                child: Shimmer.fromColors(
                  baseColor: ColorsB.gray800,
                  highlightColor: ColorsB.gray700,
                  child: Container(
                    // Student containers. Maybe get rid of the hero
                    width: screenWidth * 0.75,
                    height: 200,
                    decoration: BoxDecoration(
                      color: ColorsB.gray800,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
                    child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.3,
                      child: SvgPicture.asset('assets/svgs/404.svg'),
                    ),
                    const Text(
                      'Zap! Something went wrong!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      "Please retry.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        onPressed: () {
                          widget.refresh();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: ColorsB.yellow500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        )),
                  ],
                )),
                const SizedBox(height: 200),
              ],
            );
          } else {
            if (widget.widgetList.isNotEmpty) {
              return RefreshIndicator(
                backgroundColor: ColorsB.gray900,
                //  color: widget.color,
                onRefresh: () async {
                  widget.refresh();
                },
                child: Scrollbar(
                  child: ListView.builder(
                      controller: widget.scrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      shrinkWrap: false,
                      itemCount:
                          widget.widgetList.length < widget.maxScrollCount
                              ? widget.widgetList.length
                              : widget.maxScrollCount + 1,
                      itemBuilder: (_, index) {
                        // title = titles[index];
                        // description = descriptions[index];
                        // var owner = owners[index];

                        if (index != widget.maxScrollCount) {
                          return Center(child: widget.widgetList[index]);
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Shimmer.fromColors(
                                baseColor: ColorsB.gray800,
                                highlightColor: ColorsB.gray700,
                                child: Container(
                                  // Student containers. Maybe get rid of the hero
                                  width: screenWidth * 0.75,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: ColorsB.gray800,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                ),
              );
            } else {
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                      child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.25,
                        child: Image.asset('assets/images/no_posts.png'),
                      ),
                      const Text(
                        'Wow! Such empty. So class.',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        "It seems the only thing here is a lonely Doge. Pet it or begone!",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton.icon(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Refresh',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            widget.refresh();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: ColorsB.yellow500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          )),
                    ],
                  )),
                  const SizedBox(height: 200),
                ],
              );
            }
          }
        });
  }
}
