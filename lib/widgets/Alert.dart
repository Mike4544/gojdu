const String tableAlerts = 'alerts';

enum Availability { ADMINS, TEACHERS }

extension ValueExtension on Availability {
  int get _class {
    switch (this) {
      case Availability.ADMINS:
        return 1;
      case Availability.TEACHERS:
        return 2;
    }
  }
}

class AlertFields {
  static const String id = 'id';
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
  final int seenby;
  bool shared;

  Alert(
      {this.id,
      required this.seenby,
      required this.read,
      required this.title,
      required this.description,
      required this.imageString,
      required this.createdTime,
      required this.owner,
      required this.shared});

  Map<String, dynamic> toJson() => {
        "id": id,
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
      seenby: json['seenby'] as int,
      read: json[AlertFields.read],
      title: json[AlertFields.title] as String,
      description: json[AlertFields.description] as String,
      imageString: json[AlertFields.imageString] as String,
      createdTime: DateTime.parse(json[AlertFields.time] as String),
      owner: json[AlertFields.owner] as String,
      shared: json[AlertFields.shared]);

  Alert copy(
          {int? id,
          int? seenby,
          bool? read,
          String? title,
          String? description,
          String? imageString,
          DateTime? createdTime,
          String? owner,
          bool? shared}) =>
      Alert(
          id: id ?? this.id,
          read: read ?? this.read,
          seenby: seenby ?? this.seenby,
          title: title ?? this.title,
          description: description ?? this.description,
          imageString: imageString ?? this.imageString,
          createdTime: createdTime ?? this.createdTime,
          owner: owner ?? this.owner,
          shared: shared ?? this.shared);
}
