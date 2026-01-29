import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Validateurs de formulaire réutilisables
class FormValidators {
  FormValidators._();

  /// Valide un champ obligatoire
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName est obligatoire' 
          : 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Valide un numéro de téléphone Burkina Faso (8 chiffres)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }
    
    // Enlever les espaces et tirets
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    if (cleanNumber.length != 8) {
      return 'Le numéro doit contenir 8 chiffres';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Numéro invalide';
    }
    
    // Vérifier les préfixes valides au Burkina (50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79)
    final prefix = cleanNumber.substring(0, 2);
    final validPrefixes = ['50', '51', '52', '53', '54', '55', '56', '57', '58', 
                           '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
                           '70', '71', '72', '73', '74', '75', '76', '77', '78', '79'];
    
    if (!validPrefixes.contains(prefix)) {
      return 'Préfixe de téléphone invalide';
    }
    
    return null;
  }

  /// Valide un code OTP
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Code OTP requis';
    }
    
    if (value.length != length) {
      return 'Le code doit contenir $length chiffres';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Code invalide';
    }
    
    return null;
  }

  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email optionnel
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }

  /// Valide un nom
  static String? name(String? value, {String fieldName = 'Nom'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName trop court';
    }
    
    if (value.trim().length > 100) {
      return '$fieldName trop long';
    }
    
    return null;
  }

  /// Valide un montant
  static String? amount(String? value, {int min = 100, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Montant requis';
    }
    
    final amount = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
    
    if (amount == null) {
      return 'Montant invalide';
    }
    
    if (amount < min) {
      return 'Montant minimum: $min FCFA';
    }
    
    if (max != null && amount > max) {
      return 'Montant maximum: $max FCFA';
    }
    
    return null;
  }

  /// Valide une description
  static String? description(String? value, {int minLength = 10, int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return 'Description requise';
    }
    
    if (value.trim().length < minLength) {
      return 'Description trop courte (min. $minLength caractères)';
    }
    
    if (value.trim().length > maxLength) {
      return 'Description trop longue (max. $maxLength caractères)';
    }
    
    return null;
  }

  /// Combine plusieurs validateurs
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

/// Formateurs d'entrée personnalisés
class InputFormatters {
  InputFormatters._();

  /// Formateur pour numéro de téléphone (XX XX XX XX)
  static TextInputFormatter phoneNumber() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(' ', '');
      
      if (text.isEmpty) return newValue;
      if (text.length > 8) {
        return oldValue;
      }
      
      // Ne garder que les chiffres
      final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
      
      // Formater avec espaces: XX XX XX XX
      final buffer = StringBuffer();
      for (int i = 0; i < digitsOnly.length; i++) {
        if (i > 0 && i % 2 == 0) {
          buffer.write(' ');
        }
        buffer.write(digitsOnly[i]);
      }
      
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    });
  }

  /// Formateur pour montant (avec séparateur de milliers)
  static TextInputFormatter amount() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      
      if (text.isEmpty) return const TextEditingValue();
      
      // Formater avec séparateur de milliers
      final number = int.tryParse(text);
      if (number == null) return oldValue;
      
      final formatted = _formatNumber(number);
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  static String _formatNumber(int number) {
    final text = number.toString();
    final buffer = StringBuffer();
    
    int counter = 0;
    for (int i = text.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
      counter++;
    }
    
    return buffer.toString().split('').reversed.join();
  }

  /// Formateur pour texte en majuscules
  static TextInputFormatter upperCase() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
    });
  }

  /// Formateur pour limiter les caractères
  static TextInputFormatter maxLength(int maxLength) {
    return LengthLimitingTextInputFormatter(maxLength);
  }

  /// Formateur pour chiffres uniquement
  static TextInputFormatter digitsOnly() {
    return FilteringTextInputFormatter.digitsOnly;
  }

  /// Formateur pour lettres uniquement
  static TextInputFormatter lettersOnly() {
    return FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]'));
  }
}

/// Widget de champ de texte amélioré avec validation en temps réel
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const ValidatedTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  String? _errorText;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasInteracted && widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusLost() {
    if (!_hasInteracted) {
      setState(() {
        _hasInteracted = true;
        if (widget.validator != null) {
          _errorText = widget.validator!(_controller.text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) _onFocusLost();
      },
      child: TextFormField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        textCapitalization: widget.textCapitalization,
        onFieldSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          errorText: _errorText,
          counterText: widget.showCounter ? null : '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: widget.enabled ? Colors.white : Colors.grey.shade100,
        ),
      ),
    );
  }
}
