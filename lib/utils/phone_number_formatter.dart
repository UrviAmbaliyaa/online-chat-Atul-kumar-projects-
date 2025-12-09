import 'package:flutter/services.dart';
import 'package:online_chat/utils/country_code_picker.dart';

/// Phone number formatter utility
/// Provides input formatters based on country code
class PhoneNumberFormatter {
  /// Get input formatter based on country code
  static TextInputFormatter getFormatter(CountryCode country) {
    switch (country.code) {
      case 'US':
      case 'CA':
        // US/Canada: (XXX) XXX-XXXX
        return _USPhoneFormatter();
      
      case 'GB':
        // UK: XXXX XXXXXX
        return _UKPhoneFormatter();
      
      case 'IN':
        // India: XXXXX XXXXXX
        return _IndiaPhoneFormatter();
      
      case 'AU':
        // Australia: XXXX XXX XXX
        return _AustraliaPhoneFormatter();
      
      case 'DE':
        // Germany: XXXX XXXXXXX
        return _GermanyPhoneFormatter();
      
      case 'FR':
        // France: XX XX XX XX XX
        return _FrancePhoneFormatter();
      
      case 'JP':
        // Japan: XXX-XXXX-XXXX
        return _JapanPhoneFormatter();
      
      case 'CN':
        // China: XXX XXXX XXXX
        return _ChinaPhoneFormatter();
      
      case 'BR':
        // Brazil: (XX) XXXXX-XXXX
        return _BrazilPhoneFormatter();
      
      case 'RU':
        // Russia: XXX XXX-XX-XX
        return _RussiaPhoneFormatter();
      
      case 'KR':
        // South Korea: XXX-XXXX-XXXX
        return _SouthKoreaPhoneFormatter();
      
      case 'IT':
        // Italy: XXX XXX XXXX
        return _ItalyPhoneFormatter();
      
      case 'ES':
        // Spain: XXX XXX XXX
        return _SpainPhoneFormatter();
      
      case 'MX':
        // Mexico: XX XXXX XXXX
        return _MexicoPhoneFormatter();
      
      case 'ID':
        // Indonesia: XXX-XXXX-XXXX
        return _IndonesiaPhoneFormatter();
      
      case 'TR':
        // Turkey: XXX XXX XX XX
        return _TurkeyPhoneFormatter();
      
      case 'SA':
        // Saudi Arabia: XX XXX XXXX
        return _SaudiArabiaPhoneFormatter();
      
      case 'AE':
        // UAE: XX XXX XXXX
        return _UAEPhoneFormatter();
      
      case 'ZA':
        // South Africa: XX XXX XXXX
        return _SouthAfricaPhoneFormatter();
      
      default:
        // Default: Allow digits only, max 15 digits (international standard)
        return FilteringTextInputFormatter.digitsOnly;
    }
  }

  /// Get max length for phone number based on country
  static int? getMaxLength(CountryCode country) {
    switch (country.code) {
      case 'US':
      case 'CA':
        return 14; // (XXX) XXX-XXXX
      case 'GB':
        return 11; // XXXX XXXXXX
      case 'IN':
        return 11; // XXXXX XXXXXX
      case 'AU':
        return 12; // XXXX XXX XXX
      case 'DE':
        return 12; // XXXX XXXXXXX
      case 'FR':
        return 14; // XX XX XX XX XX
      case 'JP':
        return 13; // XXX-XXXX-XXXX
      case 'CN':
        return 12; // XXX XXXX XXXX
      case 'BR':
        return 14; // (XX) XXXXX-XXXX
      case 'RU':
        return 12; // XXX XXX-XX-XX
      case 'KR':
        return 13; // XXX-XXXX-XXXX
      case 'IT':
        return 12; // XXX XXX XXXX
      case 'ES':
        return 11; // XXX XXX XXX
      case 'MX':
        return 11; // XX XXXX XXXX
      case 'ID':
        return 13; // XXX-XXXX-XXXX
      case 'TR':
        return 12; // XXX XXX XX XX
      case 'SA':
        return 11; // XX XXX XXXX
      case 'AE':
        return 11; // XX XXX XXXX
      case 'ZA':
        return 11; // XX XXX XXXX
      default:
        return 15; // International standard max length
    }
  }
}

// US/Canada Formatter: (XXX) XXX-XXXX
class _USPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = '($text';
    } else if (text.length <= 6) {
      formatted = '(${text.substring(0, 3)}) ${text.substring(3)}';
    } else {
      formatted = '(${text.substring(0, 3)}) ${text.substring(3, 6)}-${text.substring(6, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// UK Formatter: XXXX XXXXXX
class _UKPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 4) {
      formatted = text;
    } else {
      formatted = '${text.substring(0, 4)} ${text.substring(4, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// India Formatter: XXXXX XXXXXX
class _IndiaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 5) {
      formatted = text;
    } else {
      formatted = '${text.substring(0, 5)} ${text.substring(5, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Australia Formatter: XXXX XXX XXX
class _AustraliaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 4) {
      formatted = text;
    } else if (text.length <= 7) {
      formatted = '${text.substring(0, 4)} ${text.substring(4)}';
    } else {
      formatted = '${text.substring(0, 4)} ${text.substring(4, 7)} ${text.substring(7, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Germany Formatter: XXXX XXXXXXX
class _GermanyPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 4) {
      formatted = text;
    } else {
      formatted = '${text.substring(0, 4)} ${text.substring(4, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// France Formatter: XX XX XX XX XX
class _FrancePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    for (int i = 0; i < text.length; i += 2) {
      if (i > 0) formatted += ' ';
      if (i + 2 <= text.length) {
        formatted += text.substring(i, i + 2);
      } else {
        formatted += text.substring(i);
        break;
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Japan Formatter: XXX-XXXX-XXXX
class _JapanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 7) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    } else {
      formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// China Formatter: XXX XXXX XXXX
class _ChinaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 7) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    } else {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 7)} ${text.substring(7, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Brazil Formatter: (XX) XXXXX-XXXX
class _BrazilPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 2) {
      formatted = '($text';
    } else if (text.length <= 7) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2)}';
    } else {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Russia Formatter: XXX XXX-XX-XX
class _RussiaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    } else if (text.length <= 8) {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)}-${text.substring(6)}';
    } else {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)}-${text.substring(6, 8)}-${text.substring(8, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// South Korea Formatter: XXX-XXXX-XXXX
class _SouthKoreaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 7) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    } else {
      formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Italy Formatter: XXX XXX XXXX
class _ItalyPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    } else {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Spain Formatter: XXX XXX XXX
class _SpainPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    } else {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6, 9)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Mexico Formatter: XX XXXX XXXX
class _MexicoPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 2) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 2)} ${text.substring(2)}';
    } else {
      formatted = '${text.substring(0, 2)} ${text.substring(2, 6)} ${text.substring(6, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Indonesia Formatter: XXX-XXXX-XXXX
class _IndonesiaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 7) {
      formatted = '${text.substring(0, 3)}-${text.substring(3)}';
    } else {
      formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Turkey Formatter: XXX XXX XX XX
class _TurkeyPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    } else if (text.length <= 8) {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6)}';
    } else {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6, 8)} ${text.substring(8, 10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Saudi Arabia Formatter: XX XXX XXXX
class _SaudiArabiaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 2) {
      formatted = text;
    } else if (text.length <= 5) {
      formatted = '${text.substring(0, 2)} ${text.substring(2)}';
    } else {
      formatted = '${text.substring(0, 2)} ${text.substring(2, 5)} ${text.substring(5, 9)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// UAE Formatter: XX XXX XXXX
class _UAEPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 2) {
      formatted = text;
    } else if (text.length <= 5) {
      formatted = '${text.substring(0, 2)} ${text.substring(2)}';
    } else {
      formatted = '${text.substring(0, 2)} ${text.substring(2, 5)} ${text.substring(5, 9)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// South Africa Formatter: XX XXX XXXX
class _SouthAfricaPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    if (text.length <= 2) {
      formatted = text;
    } else if (text.length <= 5) {
      formatted = '${text.substring(0, 2)} ${text.substring(2)}';
    } else {
      formatted = '${text.substring(0, 2)} ${text.substring(2, 5)} ${text.substring(5, 9)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

