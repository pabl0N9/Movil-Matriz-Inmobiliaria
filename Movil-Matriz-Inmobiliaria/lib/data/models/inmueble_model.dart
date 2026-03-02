class Inmueble {
  final String id;
  final String imagePath;
  final String title;
  final String code;
  final String location;
  final String operation;
  final String status;
  final String? salePrice;
  final String? rentPrice;
  final String price;
  final String area;
  final String rooms;
  final String baths;
  final bool featured;
  final int? ownerId;

  const Inmueble({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.code,
    required this.location,
    required this.operation,
    required this.status,
    required this.salePrice,
    required this.rentPrice,
    required this.price,
    required this.area,
    required this.rooms,
    required this.baths,
    required this.featured,
    this.ownerId,
  });
}
