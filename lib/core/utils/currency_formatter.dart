/// Formate un montant en FCFA avec séparateurs de milliers (espace).
/// Ex: 150000 → "150 000 FCFA", 1000 → "1 000 FCFA"
String formatCFA(num amount) {
  final intAmount = amount.toInt();
  final sign = intAmount < 0 ? '-' : '';
  final absStr = intAmount.abs().toString();
  
  final buffer = StringBuffer();
  for (int i = 0; i < absStr.length; i++) {
    if (i > 0 && (absStr.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(absStr[i]);
  }
  
  return '$sign${buffer.toString()} FCFA';
}

/// Formate un montant sans le suffixe "FCFA"
String formatNumber(num amount) {
  final intAmount = amount.toInt();
  final sign = intAmount < 0 ? '-' : '';
  final absStr = intAmount.abs().toString();
  
  final buffer = StringBuffer();
  for (int i = 0; i < absStr.length; i++) {
    if (i > 0 && (absStr.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(absStr[i]);
  }
  
  return '$sign${buffer.toString()}';
}
