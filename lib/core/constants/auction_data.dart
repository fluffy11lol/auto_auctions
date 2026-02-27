// ============================================================
// AUCTION_DATA.DART — Справочники для аукционов
// ============================================================
// Go аналог: const блоки или var с инициализацией

class AuctionData {
  AuctionData._();

  // Аукционы
  static const List<String> auctions = [
    'Copart',
    'IAAI',
    'Manheim',
    'Other',
  ];

  // Штаты США
  static const Map<String, String> usStates = {
    'AL': 'Alabama',
    'AK': 'Alaska',
    'AZ': 'Arizona',
    'AR': 'Arkansas',
    'CA': 'California',
    'CO': 'Colorado',
    'CT': 'Connecticut',
    'DE': 'Delaware',
    'FL': 'Florida',
    'GA': 'Georgia',
    'HI': 'Hawaii',
    'ID': 'Idaho',
    'IL': 'Illinois',
    'IN': 'Indiana',
    'IA': 'Iowa',
    'KS': 'Kansas',
    'KY': 'Kentucky',
    'LA': 'Louisiana',
    'ME': 'Maine',
    'MD': 'Maryland',
    'MA': 'Massachusetts',
    'MI': 'Michigan',
    'MN': 'Minnesota',
    'MS': 'Mississippi',
    'MO': 'Missouri',
    'MT': 'Montana',
    'NE': 'Nebraska',
    'NV': 'Nevada',
    'NH': 'New Hampshire',
    'NJ': 'New Jersey',
    'NM': 'New Mexico',
    'NY': 'New York',
    'NC': 'North Carolina',
    'ND': 'North Dakota',
    'OH': 'Ohio',
    'OK': 'Oklahoma',
    'OR': 'Oregon',
    'PA': 'Pennsylvania',
    'RI': 'Rhode Island',
    'SC': 'South Carolina',
    'SD': 'South Dakota',
    'TN': 'Tennessee',
    'TX': 'Texas',
    'UT': 'Utah',
    'VT': 'Vermont',
    'VA': 'Virginia',
    'WA': 'Washington',
    'WV': 'West Virginia',
    'WI': 'Wisconsin',
    'WY': 'Wyoming',
  };

  // Типы повреждений
  static const List<String> damageTypes = [
    'None',
    'Front End',
    'Rear End',
    'Side',
    'Rollover',
    'Hail Damage',
    'Water/Flood',
    'Fire',
    'Vandalism',
    'Theft Recovery',
    'Mechanical',
    'Minor Dents',
    'All Over',
  ];

  // Типы документов (Title)
  static const List<String> titleTypes = [
    'Clean Title',
    'Salvage',
    'Rebuilt',
    'Certificate of Destruction',
    'Non-Repairable',
    'Lemon',
    'Flood',
    'Unknown',
  ];

  // Популярные марки
  static const List<String> popularMakes = [
    'Acura',
    'Audi',
    'BMW',
    'Buick',
    'Cadillac',
    'Chevrolet',
    'Chrysler',
    'Dodge',
    'Ford',
    'GMC',
    'Honda',
    'Hyundai',
    'Infiniti',
    'Jaguar',
    'Jeep',
    'Kia',
    'Land Rover',
    'Lexus',
    'Lincoln',
    'Mazda',
    'Mercedes-Benz',
    'Mini',
    'Mitsubishi',
    'Nissan',
    'Porsche',
    'Ram',
    'Subaru',
    'Tesla',
    'Toyota',
    'Volkswagen',
    'Volvo',
  ];

  // Типы топлива
  static const List<String> fuelTypes = [
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'Plug-in Hybrid',
    'Flex Fuel',
  ];

  // Типы трансмиссии
  static const List<String> transmissionTypes = [
    'Automatic',
    'Manual',
    'CVT',
  ];

  // Типы привода
  static const List<String> drivetrainTypes = [
    'FWD',  // Front-Wheel Drive
    'RWD',  // Rear-Wheel Drive
    'AWD',  // All-Wheel Drive
    '4WD',  // 4-Wheel Drive
  ];

  // Порты доставки
  static const List<String> usaPorts = [
    'Houston, TX',
    'Los Angeles, CA',
    'Newark, NJ',
    'Savannah, GA',
    'Seattle, WA',
  ];

  static const List<String> ruPorts = [
    'Vladivostok',
    'Novorossiysk',
    'St. Petersburg',
  ];
}