import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gojdu/others/colors.dart';

import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path/path.dart';

import '../widgets/Note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if(_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);

  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const stringType = 'TEXT NOT NULL';



    await db.execute('''
    CREATE TABLE $tableNotes (
    ${NoteFields.id} $idType,
    ${NoteFields.isImportant} $boolType,
    ${NoteFields.title} $stringType,
    ${NoteFields.description} $stringType,
    ${NoteFields.time} $stringType
    )
    ''');

  }

  Future<Note> create(Note note) async {
    final db = await instance.database;
    
    // final json = note.toJson();
    // const columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    //
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    //
    // final id = await db
    //         .rawInsert('INSERT INTO table_name ($columns), VALUES ($values)');

    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);

  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id]
    );

    if(maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    }
    else {
      throw Exception('ID $id not found');
    }

  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    const orderBy = '${NoteFields.time} ASC';
    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id]
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableNotes,
      where: "${NoteFields.id} = ?",
      whereArgs: [id],
    );
  }

}



class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late List<Note> notes;
  late List<NoteContainer> noteWidgs;
  bool isLoading  = false;

  void update() {
    refreshNotes();
    setState(() {

    });
  }

  @override
  void initState() {
    notes = [];
    noteWidgs = [];
    refreshNotes();

    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return buildNotes(context);
  }

  Widget buildNotes(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      children: noteWidgs.map((container) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteDetailPage(noteId: container.data?.id, update: update,))
            );
          },
          child: container,
        );
      }).toList(),
    );
  }

  Future refreshNotes() async {
    setState(() {
      isLoading = true;
    });

    notes = await NotesDatabase.instance.readAllNotes();
    print(notes.length);
    mapNotes();

    setState(() {
      isLoading = false;
    });

  }

  void mapNotes() {
    noteWidgs = [];

    for(var element in notes){
      noteWidgs.add(
          NoteContainer(data: element, type: 1)
      );
    }

    // print(noteWidgs.length);

    noteWidgs.insert(0, const NoteContainer(type: 2),
    );
  }
}

class NoteContainer extends StatelessWidget {
  final Note? data;
  final int type;

  const NoteContainer({Key? key, this.data, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    var smallStyle = TextStyle(
      fontSize: 12.5,
      color: Colors.white.withOpacity(.5),
    );

    var titleStyle = const TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold
    );

    if(type == 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
              color: ColorsB.gray800,
              borderRadius: BorderRadius.circular(height * .05)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    data!.title,
                    style: titleStyle,
                  ),
                ),
                const SizedBox(height: 2.5,),
                Text(
                  DateFormat.yMMMd().format(data!.createdTime),
                  style: smallStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
              color: ColorsB.gray800,
              borderRadius: BorderRadius.circular(height * .05)
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: const [
                Expanded(
                  child: SizedBox(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ),
        ),
      );
    }
  }
}






class NoteDetailPage extends StatefulWidget {
  final int? noteId;
  final VoidCallback update;

  const NoteDetailPage({Key? key, this.noteId, required this.update}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  Note? note;
  var isLoading = false;
  var didChange = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    refreshNote();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget deleteButton() {
      if(note != null){
        return IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await NotesDatabase.instance.delete(widget.noteId!);

              Navigator.of(context).pop();
              widget.update();
            }
        );
      }
      else {
        return const SizedBox();
      }
    }

    Future updateNote() async {
      final not = note!.copy(
        isImportant: false,
        title: _titleController.text,
        description: _descriptionController.text
      );

      await NotesDatabase.instance.update(not);


    }

    Future addNote() async {
      final not = Note(
        isImportant: false,
        title: _titleController.text,
        description: _descriptionController.text,
        createdTime: DateTime.now(),
      );

      await NotesDatabase.instance.create(not);
    }



    Widget didChangeButton() {
      if(didChange){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            child: const Text(
              'Save note',
              style: TextStyle(
                color: Colors.white
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green[300]
            ),
            onPressed: () async {
              if(_titleController.text.isEmpty && _descriptionController.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Note cannot be empty'
                    ),
                    backgroundColor: Colors.red,
                  )
                );

                return;
              }

              final isUpdating = note != null;

              if(isUpdating){
                await updateNote();
              }
              else {
                await addNote();
              }

              Navigator.of(context).pop();
              widget.update();

            },
          ),
        );
      }
      else {
        return const SizedBox();
      }


    }


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorsB.gray900,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            deleteButton(), didChangeButton()
          ],
        ),
        body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorsB.yellow500)))

        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 17.5),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              TextField(
                controller: _titleController,
                onChanged: (s) {
                  if(!didChange) {
                    setState(() {
                      didChange = true;
                    });
                  }
                },
                maxLines: null,
                cursorColor: ColorsB.yellow500,
                decoration: const InputDecoration(

                  border: InputBorder.none,
                  filled: false,
                  hintText: "Enter the note's title...",
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  )
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 12),

              note != null
              ? Text(
                DateFormat.yMMMd().format(note!.createdTime),
                style: const TextStyle(color: Colors.white38),
              )
              : const SizedBox(),

              const SizedBox(height: 24),
              TextField(
                cursorColor: ColorsB.yellow500,
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (s) {
                  if(!didChange) {
                    setState(() {
                      didChange = true;
                    });
                  }
                },
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintText: "Enter a description...",
                    hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                    )
                ),
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        )
      ),
    );
  }




  Future refreshNote() async {
    setState(() {
      isLoading = true;
    });

    if(widget.noteId != null){
      note = await NotesDatabase.instance.readNote(widget.noteId!);
    }
    else {
      note = null;
    }

    _titleController = TextEditingController(text: note != null ? note!.title : '');
    _descriptionController = TextEditingController(text: note != null ? note!.description : '');

    setState(() {
      isLoading = false;
    });
  }
}
