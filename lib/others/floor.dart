class Floor {
  String floor;
  String file;
  String image;

  Floor({required this.floor, required this.file, required this.image});

  Floor.fromJson(Map<String, String> json)
  : floor = json['floor']!,
    image = json['image']!,
    file = json['file']!;

  Map<String, String> toJson() =>
      {
        'floor': floor,
        'file': file,
        'image': image
      };

  Floor clone() => Floor(
    floor: floor,
    file: file,
    image: image
  );

}