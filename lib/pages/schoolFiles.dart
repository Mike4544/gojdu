//  Import material

import 'dart:async';
import 'dart:io';

import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gojdu/others/api.dart';
import 'package:gojdu/widgets/Event.dart';
import 'package:gojdu/others/options.dart';

// Import http as http
import 'package:http/http.dart' as http;
// Import dart convert
import 'dart:convert';

// Import colors
import '../others/colors.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:path_provider/path_provider.dart';

Map<String, String> fileTypeIcons = {
  "doc": "assets/images/file_types/doc.png",
  "docx": "assets/images/file_types/doc.png",
  "pdf": "assets/images/file_types/pdf.png",
  "ppt": "assets/images/file_types/ppt.png",
  "pptx": "assets/images/file_types/ppt.png",
  "xls": "assets/images/file_types/xls.png",
  "xlsx": "assets/images/file_types/xls.png",
  "zip": "assets/images/file_types/zip.png",
  "rar": "assets/images/file_types/zip.png",
  "txt": "assets/images/file_types/txt.png",
  "png": "assets/images/file_types/image.png",
  "jpg": "assets/images/file_types/image.png",
  "jpeg": "assets/images/file_types/image.png",
  "gif": "assets/images/file_types/image.png",
  "mp4": "assets/images/file_types/video.png",
  "mp3": "assets/images/file_types/music.png",
  "wav": "assets/images/file_types/music.png",
  "flac": "assets/images/file_types/music.png",
  "default": "assets/images/file_types/default.png"
};

// ignore: must_be_immutable
class SchoolFiles extends StatefulWidget {
  final bool isAdmin;
  const SchoolFiles({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<SchoolFiles> createState() => _SchoolFilesState();
}

class _SchoolFilesState extends State<SchoolFiles> {
  late Map<String, dynamic> paths = {};
  late List<Category> categories = [];

  Future<bool> newCategory() async {
    final TextEditingController _controller = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorsB.gray800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text("Create Category",
              style: TextStyle(
                  color: ColorsB.yellow500, fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: TextFormField(
              validator: (value) => value!.isEmpty ? "Enter a name" : null,
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: "Category Name",
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                return;
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                if (await createCategory(_controller.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "${_controller.text} has been created",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: ColorsB.gray800,
                  ));

                  setState(() {
                    setState(() {
                      paths.addAll({
                        _controller.text: [],
                      });
                    });
                  });

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Failed to create category",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: ColorsB.gray800,
                  ));
                }
              },
              child: const Text(
                "Create",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return false;
  }

  Future<bool> createCategory(String name) async {
    String link =
        "${Misc.link}/${Misc.appName}/schoolFilesAPI/createCategory.php";

    final response = await http.post(
      Uri.parse(link),
      body: {"name": name},
    );

    return response.statusCode == 200 && jsonDecode(response.body)["success"];
  }

  Widget buildFileView() {
    categories = [];

    paths.forEach((key, value) {
      List<FileContainer> files = [];

      value.forEach((element) {
        files.add(FileContainer(
          path: "$key/$element",
          name: element,
          isAdmin: widget.isAdmin,
          onDelete: () {
            setState(() {
              paths[key].remove(element);
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "$element has been deleted",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: ColorsB.gray800,
            ));
          },
        ));
      });

      categories.add(Category(
        memoryBarKey: memoryBarKey,
        onDelete: () {
          setState(() {
            paths.remove(key);
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "$key has been deleted",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: ColorsB.gray800,
          ));
        },
        isAdmin: widget.isAdmin,
        name: key,
        files: files,
      ));
    });

    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: widget.isAdmin ? categories.length + 1 : categories.length,
      itemBuilder: (context, index) {
        if (widget.isAdmin && index == categories.length) {
          return TextButton.icon(
            onPressed: () async {
              // setState(() {
              //   paths.addAll({
              //     "New Category": [],
              //   });
              // });
              newCategory();
            },
            label: const Text(
              "Add Category",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          );
        } else {
          return categories[index];
        }
      },
    );
  }

  Future<int> getCategories() async {
    //  await Future.delayed(const Duration(seconds: 1));
    //  Map<String, dynamic> paths = {};

    String link = "${Misc.link}/${Misc.appName}/schoolFilesAPI/getPath.php";

    //  Make a request to the link and store the decoded value
    try {
      final response = await http.get(Uri.parse(link));
      m_debugPrint(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsondata = jsonDecode(response.body);

        paths = jsondata['path'];
        memUsed = jsondata['memUsed'] != 0 ? jsondata['memUsed'] : 0.0;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e, s) {
      m_debugPrint(e);
      m_debugPrint(s);

      // return a snack bar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Failed to load data",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorsB.gray800,
      ));

      return 0;
    }

    return 1;
  }

  final ScrollController _scrollController = ScrollController();

  late final Future<int> _getCategs = getCategories();

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  // Global key for the memory bar
  final GlobalKey<_MemoryBarState> memoryBarKey = GlobalKey<_MemoryBarState>();
  double memUsed = 0;

  Widget memBar() => Visibility(
        visible: widget.isAdmin,
        child: Column(
          children: [
            MemoryBar(usedMemory: memUsed, key: memoryBarKey),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder(
        future: _getCategs,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                memBar(),
                buildFileView(),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class MemoryBar extends StatefulWidget {
  double usedMemory;
  double? totalMemory;
  MemoryBar({Key? key, required this.usedMemory, this.totalMemory = 100.0})
      : super(key: key);

  @override
  State<MemoryBar> createState() => _MemoryBarState();
}

class _MemoryBarState extends State<MemoryBar> {
  void updateMemory(double usedMemory) {
    setState(() {
      widget.usedMemory = usedMemory;
    });
  }

  @override
  double get memUsed => widget.usedMemory;
  double get memTotal => widget.totalMemory ?? 100.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 20,
          width: screenWidth - 40,
          decoration: BoxDecoration(
            color: ColorsB.gray800,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Positioned(
          left: 0,
          child: Container(
            height: 20,
            width:
                (screenWidth - 40) * (widget.usedMemory / widget.totalMemory!),
            decoration: BoxDecoration(
              color: ColorsB.yellow500,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Text(
          "${widget.usedMemory.toStringAsFixed(2)} MB / ${widget.totalMemory} MB",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class FileContainer extends StatelessWidget {
  final String name;
  final String path;
  final bool isAdmin;
  final Function? onDelete;
  const FileContainer(
      {Key? key,
      required this.name,
      required this.isAdmin,
      required this.path,
      this.onDelete})
      : super(key: key);

  Image getIcon() {
    String ext = name.split(".").last;
    if (fileTypeIcons.containsKey(ext)) {
      return Image.asset(fileTypeIcons[ext]!);
    } else {
      return Image.asset(fileTypeIcons["default"]!);
    }
  }

  Future<bool> delete() async {
    String link = "${Misc.link}/${Misc.appName}/schoolFilesAPI/deleteFile.php";

    try {
      m_debugPrint(path);
      final response = await http.post(
        Uri.parse(link),
        body: {
          "path": path,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsondata = jsonDecode(response.body);

        return jsondata['success'];
      } else {
        throw Exception("Failed to connect");
      }
    } catch (e, s) {
      m_debugPrint(e);
      m_debugPrint(s);
      return false;
    }
  }

  Future<void> downloadFile(BuildContext context) async {
    final url = "${Misc.link}/${Misc.appName}/schoolFiles/$path";

    final status = await Permission.storage.request();

    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectory();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Downloading..."),
        ),
      );

      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        saveInPublicStorage: true,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      // Snack bar for failed download

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied"),
        ),
      );
    }
  }

  Widget contents() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: getIcon(),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              name.length > 15
                  ? "${name.substring(0, 15)}...${name.split('.').last}"
                  : name,
              style: TextStyle(
                color: Colors.white,
                fontSize: name.length > 10 ? 10 : 12,
              ),
            ),
          ],
        ),
      );

  Widget actionButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () async {
              await downloadFile(context);
              print("Download $name");
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
          Visibility(
            visible: isAdmin,
            child: IconButton(
              onPressed: () async {
                bool success = await delete();
                if (success) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  onDelete!();
                  m_debugPrint("Delete $name");
                }
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );

  Widget bottomBar(BuildContext context) => Container(
        color: Colors.black54,
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name.length > 15
                    ? "${name.substring(0, 15)}...${name.split('.').last}"
                    : name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              actionButtons(context)
            ],
          ),
        ),
      );

  Widget deleteButton() => Visibility(
        visible: isAdmin,
        child: IconButton(
          onPressed: () async {
            // m_debugPrint("Delete $path");
            bool success = await delete();
            if (success) {
              onDelete!();
              m_debugPrint("Deleted $path");
            }
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsB.gray800,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            contents(),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    //  print("Tapped $name");
                    //  Display the file as an alert
                    showDialog(
                        context: context,
                        builder: (context) => GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.3,
                                      width: screenHeight * 0.3,
                                      child: getIcon(),
                                    ),
                                    Positioned(
                                        bottom: 0, child: bottomBar(context)),
                                    Positioned(
                                        top: 0,
                                        left: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ));
                  },
                ),
              ),
            ),
            Positioned(top: 0, right: 0, child: deleteButton())
          ],
        ),
      ),
    );
  }
}

class AddContainer extends FileContainer {
  final Function(List<File>) onAdd;
  final GlobalKey<_MemoryBarState> memoryBarKey;
  final String path;
  AddContainer(
      {Key? key,
      required this.memoryBarKey,
      required this.onAdd,
      required this.path})
      : super(key: key, name: "", isAdmin: false, path: "", onDelete: null);

  @override
  Widget contents() => const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      );

  late List<File> _files;

  Future<bool> upload(BuildContext context) async {
    //  Choosing files
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return false;

    List<File> files = result.paths.map((path) => File(path!)).toList();
    _files = files;

    final int divideBy = 1000 * 1000;

    try {
      final String serverUrl =
          "${Misc.link}/${Misc.appName}/schoolFilesAPI/upload.php";
      m_debugPrint(serverUrl);

      for (File _file in files) {
        double fileMemory = _file.lengthSync() / divideBy;
        m_debugPrint("File: ${_file.path} ($fileMemory)");

        double memUsed = memoryBarKey.currentState!.memUsed;
        double totalMem = memoryBarKey.currentState!.memTotal;

        if (memUsed + fileMemory > totalMem) {
          throw Exception("Not enough storage!");
        }

        //  m_debugPrint("File: ${_file.path}");

        // Uploading each file to the server
        final String fileName = _file.path.split("/").last;

        var request = http.MultipartRequest("POST", Uri.parse(serverUrl));
        request.files.add(await http.MultipartFile.fromPath("file", _file.path,
            filename: fileName));

        request.fields["path"] = path;

        request.send().then((response) {
          if (response.statusCode == 200) {
            m_debugPrint("Uploaded $fileName");

            //  Refreshing the memory bar
            memoryBarKey.currentState!.updateMemory(memUsed + fileMemory);

            //  onAdd();
          } else {
            m_debugPrint("Failed to upload $fileName");
            throw Exception("Failed to upload $fileName");
          }

          return response.statusCode == 200;
        });
      }
    } catch (e, s) {
      m_debugPrint("Error: $e");
      m_debugPrint("Stack: $s");

      // Display a snackbar with the error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorsB.gray800,
              borderRadius: BorderRadius.circular(30),
            ),
            child: contents(),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  if (await upload(context)) {
                    m_debugPrint("Uploaded");
                    onAdd(_files);
                  }
                  //  onAdd();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class Category extends StatefulWidget {
  final String name;
  final bool isAdmin;
  final GlobalKey<_MemoryBarState> memoryBarKey;
  final Function onDelete;
  List<FileContainer> files;
  Category({
    Key? key,
    required this.memoryBarKey,
    required this.name,
    required this.files,
    required this.isAdmin,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> deleteCategory(BuildContext context) async {
    final String link =
        "${Misc.link}/${Misc.appName}/schoolFilesAPI/deleteCategory.php";

    try {
      final response = await http.post(
        Uri.parse(link),
        body: {
          "name": widget.name,
        },
      );

      if (response.statusCode == 200) {
        final jsondata = jsonDecode(response.body);

        m_debugPrint(jsondata);

        m_debugPrint("Deleted ${widget.name}");
        //  widget.onDelete();
      } else {
        m_debugPrint("Failed to delete ${widget.name}");
        throw Exception("Failed to delete ${widget.name}");
      }
    } catch (e, s) {
      m_debugPrint("Error: $e");
      m_debugPrint("Stack: $s");

      // Display a snackbar with the error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(
        Icons.folder,
        color: Colors.white,
      ),
      initiallyExpanded: false,
      title: Row(
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const Spacer(),

          // Add a delete button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: widget.isAdmin,
              child: IconButton(
                onPressed: () async {
                  if (await deleteCategory(context)) {
                    widget.onDelete();
                  }
                  //  widget.onDelete();
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      collapsedIconColor: Colors.white,
      iconColor: ColorsB.yellow500,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              widget.isAdmin ? widget.files.length + 1 : widget.files.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (widget.isAdmin && index == widget.files.length) {
              return AddContainer(
                memoryBarKey: widget.memoryBarKey,
                path: widget.name,
                onAdd: (files) {
                  //  print("Add");
                  for (final file in files) {
                    widget.files.add(FileContainer(
                      name: file.path.split("/").last,
                      path: "${widget.name}/${file.path.split("/").last}",
                      isAdmin: widget.isAdmin,
                      onDelete: () {
                        setState(() {
                          widget.files.removeWhere((element) =>
                              element.name == file.path.split("/").last);
                        });

                        //  Display a snackbar that the file has been deleted
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "${file.path.split("/").last} has been deleted",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: ColorsB.gray800,
                        ));
                      },
                    ));
                  }

                  setState(() {});
                },
              );
            } else {
              return widget.files[index];
            }
          },
        )
      ],
    );
  }
}
