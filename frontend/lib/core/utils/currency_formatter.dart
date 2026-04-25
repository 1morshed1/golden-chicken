String formatBDT(double amount) => '৳${amount.toStringAsFixed(2)}';

String toBanglaDigits(String input) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  var result = input;
  for (var i = 0; i < en.length; i++) {
    result = result.replaceAll(en[i], bn[i]);
  }
  return result;
}
