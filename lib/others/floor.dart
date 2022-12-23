class Floor {
  String floor;
  String? initName;
  String file;
  String image;
  int? tcase;

  Floor(
      {required this.floor,
      required this.file,
      required this.image,
      this.tcase,
      this.initName});

  Floor.fromJson(Map<String, String> json)
      : floor = json['floor']!,
        image = json['image']!,
        file = json['file']!;

  Map<String, String> toJson() =>
      {'floor': floor, 'file': file, 'image': image};

  Floor clone() =>
      Floor(floor: floor, file: file, image: image, initName: floor);

  Floor copyWith(
      {String? floor,
      String? file,
      String? image,
      int? tcase,
      String? initName}) {
    return Floor(
        floor: floor ?? this.floor,
        file: file ?? this.file,
        image: image ?? this.image,
        tcase: tcase ?? this.tcase,
        initName: initName ?? floor);
  }
}
