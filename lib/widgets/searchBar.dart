import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gojdu/others/api.dart';
import 'package:gojdu/pages/forgot_password.dart';
import "../others/colors.dart";

// Import the filters.dart file
import '../pages/searchPage.dart';
import "filters.dart";

enum SearchType { activities, offers, defaultSearch, courses }

class SearchBar extends StatefulWidget {
  List<mFilterChip> filters;
  final Widget adminButton;
  final SearchType searchType;
  SearchBar(
      {Key? key,
      required this.filters,
      required this.adminButton,
      required this.searchType})
      : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  void initState() {
    open = false;
    searchController = TextEditingController();

    super.initState();
  }

  void delete(mFilterChip filter) {
    selectedFilters.removeWhere((element) => element.label == filter.label);
    setState(() {});
  }

  void search(String searchTerm) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchResultPage(
        searchType: widget.searchType,
        searchTerm: searchTerm,
        filters: selectedFilters,
      );
    }));
  }

  late bool open;
  late TextEditingController searchController;

  List<mFilterChip> selectedFilters = [];

  Widget searchBar() => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        height: 50,
        width: open ? screenWidth * .65 : screenWidth * .25,
        decoration: BoxDecoration(
          color: ColorsB.gray800,
          borderRadius: BorderRadius.circular(360),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add a search icon that becomes a close icon when the search bar is open
                  GestureDetector(
                    onTap: () async {
                      if (open) {
                        FocusScope.of(context).unfocus();
                        searchController.clear();
                        setState(() {
                          open = false;
                          selectedFilters.clear();
                        });
                      }
                    },
                    child: Icon(
                      open ? Icons.arrow_back_ios : Icons.search,
                      color: open ? Colors.white.withOpacity(.5) : Colors.white,
                    ),
                  ),
                  // Add space between the icon and the search bar
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: screenWidth,
                    child: TextField(
                      onTap: () {
                        setState(() => open = true);
                      },
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        search(value);
                      },
                      controller: searchController,
                      //  Get rid of the autocorrect
                      autocorrect: false,
                      //  Get rid of suggestions
                      enableSuggestions: false,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          hintText: 'Search',
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                              color: open
                                  ? Colors.white.withOpacity(.5)
                                  : Colors.white,
                              fontSize: 15.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(360),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() => open = true);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      searchBar(),
                      Positioned(
                          right: 0,
                          child: Visibility(
                            visible: searchController.text.isNotEmpty ||
                                selectedFilters.isNotEmpty,
                            child: IconButton(
                              onPressed: () => search(searchController.text),
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.adminButton,
                ),
              ],
            ),
            // Add a space between the search bar and the filters
            const SizedBox(height: 10),
            // Add a row with the selected filters and a dropdown button
            // that has the filters that are unselected
            Container(
              width: width,
              constraints: BoxConstraints(
                maxHeight: open ? height * .5 : 0,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: open ? 1 : 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Make the selectedFilters row wrap
                    Expanded(
                      flex: 2,
                      child: Wrap(
                        children: selectedFilters
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: e,
                                ))
                            .toList(),
                      ),
                    ),
                    // Add a dropdown button that has the filters that are unselected
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorsB.gray800,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: DropdownButton<mFilterChip>(
                            underline: const SizedBox(),
                            menuMaxHeight: height * .5,
                            hint: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Add Filter',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            dropdownColor: Colors.white10,
                            borderRadius: BorderRadius.circular(30),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            items: widget.filters
                                .map((e) => DropdownMenuItem<mFilterChip>(
                                      value: e,
                                      child: e,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              delete(value!);
                              setState(() {
                                selectedFilters
                                    .add(value.copyWith(onDelete: () {
                                  delete(value);
                                }));
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
