import 'dart:io';

class ValidationHelper {
  // Name validation
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Basic international phone format validation
    // Accepts formats like: +1234567890, +123 456 7890, etc.
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    String cleanedPhone = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Please enter a valid phone number (international format)';
    }

    return null;
  }

  // Date of birth validation (18+ years old)
  static String? validateDateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }

    try {
      DateTime birthDate = DateTime.parse(value);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      // Adjust age if birthday hasn't occurred this year
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      if (age < 18) {
        return 'You must be at least 18 years old';
      }

      if (age > 100) {
        return 'Please enter a valid date of birth';
      }

      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Numbers only validation
  static String? validateNumbersOnly(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final numbersRegex = RegExp(r'^[0-9]+$');
    if (!numbersRegex.hasMatch(value.trim())) {
      return '$fieldName must contain only numbers';
    }

    return null;
  }

  // File validation
  static String? validateFile(String? filePath, {int maxSizeMB = 5}) {
    if (filePath == null || filePath.isEmpty) {
      return 'File is required';
    }

    File file = File(filePath);

    if (!file.existsSync()) {
      return 'File does not exist';
    }

    // Check file extension
    String extension = filePath.split('.').last.toLowerCase();
    List<String> allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];

    if (!allowedExtensions.contains(extension)) {
      return 'File must be PDF, PNG, or JPG';
    }

    // Check file size
    int fileSizeInBytes = file.lengthSync();
    int maxSizeInBytes = maxSizeMB * 1024 * 1024;

    if (fileSizeInBytes > maxSizeInBytes) {
      return 'File size must be less than ${maxSizeMB}MB';
    }

    return null;
  }

  // Get file size in MB
  static double getFileSizeInMB(String filePath) {
    File file = File(filePath);
    int sizeInBytes = file.lengthSync();
    return sizeInBytes / (1024 * 1024);
  }

  // Format file size for display
  static String formatFileSize(String filePath) {
    double sizeInMB = getFileSizeInMB(filePath);
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(2)} MB';
  }
}
