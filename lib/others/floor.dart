class Floor {
  String floor;
  String file;

  Floor({required this.floor, required this.file});

  Floor.fromJson(Map<String, String> json)
  : floor = json['floor']!,
    file = json['file']!;

  Map<String, String> toJson() =>
      {
        'floor': floor,
        'file': file
      };

  Floor clone() => Floor(
    floor: floor,
    file: file
  );

}