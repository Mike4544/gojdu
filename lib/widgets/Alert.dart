const String tableAlerts = 'alerts';

class AlertFields {
  static const List<String> values = [
    id, read, title, description, imageString, time, owner
  ];

  static const String id = '_id';
  static const String read = 'read';
  static const String title = 'title';
  static const String description = 'description';
  static const String imageString = 'imageString';
  static const String time = 'time';
  static const String owner = 'owner';
  static const String shared = 'shared';

}

class Alert {
  final int? id;
  bool read;
  final String title;
  final String description;
  final String imageString;
  final DateTime createdTime;
  final String owner;
  bool shared;

  Alert({
    this.id,
    required this.read,
    required this.title,
    required this.description,
    required this.imageString,
    required this.createdTime,
    required this.owner,
    required this.shared
});

  Map<String, dynamic> toJson() =>
  {
    "_id": id,
    "read": read ? 1 : 0,
    "title": title,
    "description": description,
    "imageString": imageString,
    "time": createdTime.toIso8601String(),
    "owner": owner,
    "shared": shared ? 1 : 0
  };

  static Alert fromJson(Map<String, dynamic> json) => Alert(
    id: json[AlertFields.id] as int?,
    read: json[AlertFields.read] == 1,
    title: json[AlertFields.title] as String,
    description: json[AlertFields.description] as String,
    imageString: json[AlertFields.imageString] as String,
    createdTime: DateTime.parse(json[AlertFields.time] as String),
    owner: json[AlertFields.owner] as String,
    shared: json[AlertFields.shared] == 1
  );

  Alert copy({
    int? id,
    bool? read,
    String? title,
    String? description,
    String? imageString,
    DateTime? createdTime,
    String? owner,
    bool? shared
}) => Alert(
    id: id ?? this.id,
    read: read ?? this.read,
    title: title ?? this.title,
    description: description ?? this.description,
    imageString: imageString ?? this.imageString,
    createdTime: createdTime ?? this.createdTime,
    owner: owner ?? this.owner,
    shared: shared ?? this.shared
  );


}