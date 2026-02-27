import 'package:hive/hive.dart';

//flutter pub run build_runner build
part 'lot_model.g.dart';

@HiveType(typeId: 0)
class LotModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String lotNumber;

  @HiveField(2)
  final String auction; // Copart, IAAI, etc.

  @HiveField(3)
  final String? url;

  @HiveField(4)
  final String make;

  @HiveField(5)
  final String model;

  @HiveField(6)
  final int year;

  @HiveField(7)
  final String? vin;

  @HiveField(8)
  final int? mileage;

  @HiveField(9)
  final String? engine;

  @HiveField(10)
  final String? transmission;

  @HiveField(11)
  final String? drivetrain;

  @HiveField(12)
  final String? fuelType;

  @HiveField(13)
  final String? exteriorColor;

  @HiveField(14)
  final double currentBid;

  @HiveField(15)
  final double? buyNowPrice;

  @HiveField(16)
  final String state; // TX, CA, etc.

  @HiveField(17)
  final String city;

  @HiveField(18)
  final DateTime? saleDate;

  @HiveField(19)
  final String primaryDamage;

  @HiveField(20)
  final String? secondaryDamage;

  @HiveField(21)
  final bool hasKeys;

  @HiveField(22)
  final bool runsDrives;

  @HiveField(23)
  final String titleType;

  @HiveField(24)
  final List<String> photos;


  @HiveField(25)
  final String? notes;

  @HiveField(26)
  final bool isFavorite;

  @HiveField(27)
  final DateTime createdAt;

  @HiveField(28)
  final DateTime updatedAt;

  LotModel({
    required this.id,
    required this.lotNumber,
    required this.auction,
    this.url,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.mileage,
    this.engine,
    this.transmission,
    this.drivetrain,
    this.fuelType,
    this.exteriorColor,
    required this.currentBid,
    this.buyNowPrice,
    required this.state,
    required this.city,
    this.saleDate,
    required this.primaryDamage,
    this.secondaryDamage,
    this.hasKeys = true,
    this.runsDrives = true,
    required this.titleType,
    this.photos = const [],
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$year $make $model';

  String get location => '$city, $state';

  LotModel copyWith({
    String? id,
    String? lotNumber,
    String? auction,
    String? url,
    String? make,
    String? model,
    int? year,
    String? vin,
    int? mileage,
    String? engine,
    String? transmission,
    String? drivetrain,
    String? fuelType,
    String? exteriorColor,
    double? currentBid,
    double? buyNowPrice,
    String? state,
    String? city,
    DateTime? saleDate,
    String? primaryDamage,
    String? secondaryDamage,
    bool? hasKeys,
    bool? runsDrives,
    String? titleType,
    List<String>? photos,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LotModel(
      id: id ?? this.id,
      lotNumber: lotNumber ?? this.lotNumber,
      auction: auction ?? this.auction,
      url: url ?? this.url,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      engine: engine ?? this.engine,
      transmission: transmission ?? this.transmission,
      drivetrain: drivetrain ?? this.drivetrain,
      fuelType: fuelType ?? this.fuelType,
      exteriorColor: exteriorColor ?? this.exteriorColor,
      currentBid: currentBid ?? this.currentBid,
      buyNowPrice: buyNowPrice ?? this.buyNowPrice,
      state: state ?? this.state,
      city: city ?? this.city,
      saleDate: saleDate ?? this.saleDate,
      primaryDamage: primaryDamage ?? this.primaryDamage,
      secondaryDamage: secondaryDamage ?? this.secondaryDamage,
      hasKeys: hasKeys ?? this.hasKeys,
      runsDrives: runsDrives ?? this.runsDrives,
      titleType: titleType ?? this.titleType,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
