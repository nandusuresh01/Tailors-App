// form_validation.dart

class FormValidation {
  // Email Validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    }
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // Regular expression for email
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password Validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    // Check for minimum 6 characters
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm Password Validation
  static String? validateConfirmPassword(
      String? confirmPassword, String? password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Contact Number Validation (example: 10 digits)
  static String? validateContact(String? contact) {
    if (contact == null || contact.isEmpty) {
      return 'Please enter a contact number';
    }
    // Regex for 10-digit contact number
    String pattern = r'^[0-9]{10}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(contact)) {
      return 'Please enter a valid 10-digit contact number';
    }
    return null;
  }

  // Name Validation
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  // Address Validation
  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  // Generic Field Validation
  static String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  // Dropdown Validation
  static String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  }

  // Text-only Validation
  static String? validateTextOnly(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a value";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Only alphabets are allowed";
    }
    return null;
  }

  // Number Validation
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  // Price/Amount Validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  // Description Validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 10) {
      return 'Description should be at least 10 characters';
    }
    return null;
  }
}
