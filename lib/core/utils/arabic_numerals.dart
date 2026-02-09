/// Convert English numerals to Arabic-Indic numerals
String toArabicNumerals(int number) {
  const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((digit) {
        return arabicNumbers[int.parse(digit)];
      })
      .join('');
}

/// Convert English numerals string to Arabic-Indic numerals
String stringToArabicNumerals(String text) {
  const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return text
      .split('')
      .map((char) {
        if (char.contains(RegExp(r'[0-9]'))) {
          return arabicNumbers[int.parse(char)];
        }
        return char;
      })
      .join('');
}
