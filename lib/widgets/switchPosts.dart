import 'package:flutter/material.dart';
import '../others/colors.dart';

class PostsSwitcher extends StatefulWidget {
  int index;
  final PageController ctrl;
  final Function(int value) update;
  final List<String> labels;
  final List<IconData> icons;

  PostsSwitcher(
      {Key? key,
      required this.index,
      required this.ctrl,
      required this.update,
      required this.labels,
      required this.icons})
      : super(key: key);

  @override
  State<PostsSwitcher> createState() => _PostsSwitcherState();
}

class _PostsSwitcherState extends State<PostsSwitcher> {
  void anim(int value) {
    widget.update(value);

    widget.ctrl.animateToPage(value,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    const inactiveStyle = TextStyle(color: ColorsB.gray700);

    const activeStyle = TextStyle(color: ColorsB.yellow500);

    final cActive = BoxDecoration(
        borderRadius: BorderRadius.circular(360),
        color: ColorsB.gray700,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)]);

    final cInactive = BoxDecoration(
        borderRadius: BorderRadius.circular(360), color: ColorsB.gray800);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            height: 50,
            width: width * .75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      anim(0);
                    },
                    child: AnimatedContainer(
                      clipBehavior: Clip.hardEdge,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 500),
                      decoration: widget.index == 0 ? cActive : cInactive,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 7.5, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: height * .03,
                                height: height * .03,
                                child: FittedBox(
                                    child: Icon(
                                  widget.icons[0],
                                  color: widget.index == 0
                                      ? ColorsB.yellow500
                                      : ColorsB.gray700,
                                ))),
                            const SizedBox(
                              width: 5,
                            ),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                widget.labels[0],
                                overflow: TextOverflow.fade,
                                style: widget.index == 0
                                    ? activeStyle
                                    : inactiveStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      anim(1);
                    },
                    child: AnimatedContainer(
                      clipBehavior: Clip.hardEdge,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 500),
                      decoration: widget.index == 1 ? cActive : cInactive,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 7.5, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: height * .025,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  widget.labels[1],
                                  overflow: TextOverflow.fade,
                                  style: widget.index == 1
                                      ? activeStyle
                                      : inactiveStyle,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                                width: height * .03,
                                height: height * .03,
                                child: FittedBox(
                                  child: Icon(
                                    widget.icons[1],
                                    color: widget.index == 1
                                        ? ColorsB.yellow500
                                        : ColorsB.gray700,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
