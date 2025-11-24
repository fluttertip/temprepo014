import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class ValidationUtils {
  static bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isPhoneValid(String phone) {
    // Nepali phone number validation (starting with 98 and 10 digits)
    return RegExp(r'^98\d{8}$').hasMatch(phone);
  }

  static bool isPriceValid(String price) {
    final numPrice = double.tryParse(price);
    return numPrice != null && numPrice > 0;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isEmailValid(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!isPhoneValid(phone)) {
      return 'Please enter a valid Nepali phone number (98XXXXXXXX)';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'Price is required';
    }
    if (!isPriceValid(price)) {
      return 'Please enter a valid price';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

class PriceUtils {
  static String formatPrice(double price) {
    if (price >= 100000) {
      return 'NPR ${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return 'NPR ${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return 'NPR ${price.toStringAsFixed(0)}';
    }
  }

  static String formatPriceWithCommas(double price) {
    final formatter = NumberFormat('#,##,###');
    return 'NPR ${formatter.format(price)}';
  }
}

class StringUtils {
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}
