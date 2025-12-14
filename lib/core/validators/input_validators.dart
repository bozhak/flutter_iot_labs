// core/validators/input_validators.dart

class InputValidators {
  /// Валідація email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не може бути порожнім';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Введіть коректний email';
    }

    return null;
  }

  /// Валідація пароля
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не може бути порожнім';
    }

    if (value.length < 6) {
      return 'Пароль має містити мінімум 6 символів';
    }

    return null;
  }

  /// Валідація імені
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ім\'я не може бути порожнім';
    }

    if (value.length < 2) {
      return 'Ім\'я має містити мінімум 2 символи';
    }

    final nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯіІїЇєЄґҐ\s]+$');

    if (!nameRegex.hasMatch(value)) {
      return 'Ім\'я не може містити цифри або спецсимволи';
    }

    return null;
  }

  /// Валідація підтвердження пароля
  static String? validateConfirmPassword(
      String? value,
      String password,
      ) {
    if (value == null || value.isEmpty) {
      return 'Підтвердіть пароль';
    }

    if (value != password) {
      return 'Паролі не співпадають';
    }

    return null;
  }
}