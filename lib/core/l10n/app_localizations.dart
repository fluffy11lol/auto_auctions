import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _values = {
    'en': {
      'app_title': 'Auto Auctions',
      'all_lots': 'All',
      'favorites': 'Favorites',
      'no_lots': 'No lots yet',
      'no_lots_hint': 'Tap + to add your first lot',
      'settings': 'Settings',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'add': 'Add',
      'edit': 'Edit',
      'confirm_delete': 'Are you sure you want to delete?',
      'error': 'Error',
      'no_data': 'No data',
      'search': 'Search',
      'copied': 'Copied',
      'no_photos': 'No photos',
      'notes': 'Notes',

      'theme': 'Theme',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'language': 'Language',

      'add_lot': 'Add Lot',
      'edit_lot': 'Edit Lot',
      'details': 'Details',
      'lot_number': 'Lot #',

      'make': 'Make',
      'model': 'Model',
      'year': 'Year',
      'vin': 'VIN',
      'mileage': 'Mileage',
      'miles': 'mi',
      'engine': 'Engine',
      'transmission': 'Transmission',
      'drivetrain': 'Drivetrain',
      'fuel_type': 'Fuel Type',
      'color': 'Color',

      'auction': 'Auction',
      'auction_info': 'Auction Info',
      'vehicle_info': 'Vehicle Info',
      'current_bid': 'Current Bid',
      'buy_now': 'Buy Now',
      'location': 'Location',
      'sale_date': 'Sale Date',

      'damage': 'Damage',
      'damage_condition': 'Damage & Condition',
      'primary_damage': 'Primary Damage',
      'secondary_damage': 'Secondary Damage',
      'has_keys': 'Has Keys',
      'runs_drives': 'Runs & Drives',
      'runs': 'Runs',
      'not_run': 'Not Run',
      'title_type': 'Title Type',
      'yes': 'Yes',
      'no': 'No',

      'calculator': 'Calculator',
      'cost_calculator': 'Cost Calculator',
      'calculate_cost': 'Calculate Total Cost',
      'auction_costs': 'Auction Costs',
      'shipping_costs': 'Shipping Costs',
      'customs_costs': 'Customs & Duties',
      'total_cost': 'Total Cost',
      'subtotal': 'Subtotal',
      'bid_price': 'Bid Price',
      'auction_fee': 'Auction Fee',
      'gate_fee': 'Gate Fee',
      'from': 'From',
      'to': 'To',
      'shipping_to_port': 'Shipping to Port',
      'ocean_freight': 'Ocean Freight',
      'port_fees': 'Port Fees',
      'customs_duty': 'Customs Duty',
      'recycling_fee': 'Recycling Fee',
      'broker_fee': 'Broker Fee',
      'potential_profit': 'Potential Profit',
      'market_price': 'Market Price (RU)',
      'profit': 'Profit',
      'margin': 'Margin',
      'usd_rate': 'USD Rate',

      'currency': 'Currency',
      'clear_data': 'Clear All Data',
      'reload_mock': 'Reload Mock Data',
      'reload_mock_desc': 'Reset to sample lots',
      'delete_all_lots': 'Delete all lots',
      'reload_confirm': 'Reload Mock Data?',
      'reload_confirm_desc': 'This will replace all lots with sample data.',
      'reload': 'Reload',
      'delete_confirm': 'Delete All Data?',
      'delete_confirm_desc': 'This action cannot be undone.',
      'data_reloaded': 'Mock data reloaded!',
      'data_cleared': 'All data cleared!',

      'about': 'About',
      'version': 'Version',
      'made_with': 'Made by fluffy11',
      'data': 'Data',

      'price_location': 'Price & Location',
      'city': 'City',
      'state': 'State',
      'your_notes': 'Your notes',
      'update_lot': 'Update Lot',

      'open_on': 'Open on',
    },
    'ru': {
      'app_title': 'Авто Аукционы',
      'all_lots': 'Все',
      'favorites': 'Избранное',
      'no_lots': 'Лотов пока нет',
      'no_lots_hint': 'Нажмите + чтобы добавить',
      'settings': 'Настройки',
      'delete': 'Удалить',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'add': 'Добавить',
      'edit': 'Изменить',
      'confirm_delete': 'Вы уверены?',
      'error': 'Ошибка',
      'no_data': 'Нет данных',
      'search': 'Поиск',
      'copied': 'Скопировано',
      'no_photos': 'Нет фото',
      'notes': 'Заметки',

      'theme': 'Тема',
      'theme_light': 'Светлая',
      'theme_dark': 'Тёмная',
      'theme_system': 'Системная',
      'language': 'Язык',

      'add_lot': 'Добавить лот',
      'edit_lot': 'Редактировать',
      'details': 'Детали',
      'lot_number': 'Лот №',

      'make': 'Марка',
      'model': 'Модель',
      'year': 'Год',
      'vin': 'VIN',
      'mileage': 'Пробег',
      'miles': 'миль',
      'engine': 'Двигатель',
      'transmission': 'КПП',
      'drivetrain': 'Привод',
      'fuel_type': 'Топливо',
      'color': 'Цвет',

      'auction': 'Аукцион',
      'auction_info': 'Информация об аукционе',
      'vehicle_info': 'Информация об авто',
      'current_bid': 'Текущая ставка',
      'buy_now': 'Купить сейчас',
      'location': 'Локация',
      'sale_date': 'Дата торгов',

      'damage': 'Повреждения',
      'damage_condition': 'Повреждения и состояние',
      'primary_damage': 'Основное',
      'secondary_damage': 'Дополнительное',
      'has_keys': 'Ключи',
      'runs_drives': 'На ходу',
      'runs': 'На ходу',
      'not_run': 'Не на ходу',
      'title_type': 'Документ',
      'yes': 'Да',
      'no': 'Нет',

      'calculator': 'Калькулятор',
      'cost_calculator': 'Калькулятор стоимости',
      'calculate_cost': 'Рассчитать стоимость',
      'auction_costs': 'Расходы на аукционе',
      'shipping_costs': 'Доставка',
      'customs_costs': 'Таможня и пошлины',
      'total_cost': 'Итого',
      'subtotal': 'Подитог',
      'bid_price': 'Ставка',
      'auction_fee': 'Сбор аукциона',
      'gate_fee': 'Gate Fee',
      'from': 'Откуда',
      'to': 'Куда',
      'shipping_to_port': 'До порта США',
      'ocean_freight': 'Океан',
      'port_fees': 'Порт РФ',
      'customs_duty': 'Пошлина',
      'recycling_fee': 'Утильсбор',
      'broker_fee': 'Брокер',
      'potential_profit': 'Потенциальная прибыль',
      'market_price': 'Рыночная цена РФ',
      'profit': 'Прибыль',
      'margin': 'Маржа',
      'usd_rate': 'Курс USD',

      'currency': 'Валюта',
      'clear_data': 'Очистить данные',
      'reload_mock': 'Загрузить тестовые данные',
      'reload_mock_desc': 'Сбросить к примерам',
      'delete_all_lots': 'Удалить все лоты',
      'reload_confirm': 'Загрузить тестовые данные?',
      'reload_confirm_desc': 'Все текущие лоты будут заменены.',
      'reload': 'Загрузить',
      'delete_confirm': 'Удалить все данные?',
      'delete_confirm_desc': 'Это действие нельзя отменить.',
      'data_reloaded': 'Тестовые данные загружены!',
      'data_cleared': 'Данные очищены!',

      'about': 'О приложении',
      'version': 'Версия',
      'made_with': 'Сделано fluffy11',
      'data': 'Данные',

      'price_location': 'Цена и локация',
      'city': 'Город',
      'state': 'Штат',
      'your_notes': 'Ваши заметки',
      'update_lot': 'Обновить лот',

      'open_on': 'Открыть на',
    },
  };

  String t(String key) => _values[locale.languageCode]?[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}