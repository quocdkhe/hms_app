// Safe int parser to handle ints coming as String or num
int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  if (value is double) return value.toInt();
  throw FormatException('Cannot parse value to int: $value');
}
