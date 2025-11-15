bool isValidCpf(String cpf) {
  // Expect only digits
  if (cpf.length != 11) return false;
  if (RegExp(r'^(0{11}|1{11}|2{11}|3{11}|4{11}|5{11}|6{11}|7{11}|8{11}|9{11})$').hasMatch(cpf)) return false;
  final numbers = cpf.split('').map(int.parse).toList();

  int calcCheckDigit(List<int> nums, int factor) {
    var total = 0;
    for (var n in nums) {
      total += n * factor;
      factor--;
    }
    final mod = total % 11;
    return mod < 2 ? 0 : 11 - mod;
  }

  final d1 = calcCheckDigit(numbers.sublist(0, 9), 10);
  final numsForD2 = List<int>.from(numbers.sublist(0, 9))..add(d1);
  final d2 = calcCheckDigit(numsForD2, 11);
  return d1 == numbers[9] && d2 == numbers[10];
}

/// Validate the add-user form fields.
/// - `name` is required (non-empty after trim).
/// - `email` is optional, but if present must contain '@'.
/// - `phone` is optional, but if present must be 10 or 11 digits.
/// - `document` must be either a CPF (11 digits) or an RG (9 digits).
bool validateAddUserFields({
  required String name,
  String? email,
  String? phone,
  String? document,
}) {
  // Require name
  final n = name.trim();
  if (n.isEmpty) return false;

  // Require email and basic validation
  final e = (email ?? '').trim();
  if (e.isEmpty || !e.contains('@')) return false;

  // Require phone and validate digits length
  final p = (phone ?? '').trim();
  final pDigits = p.replaceAll(RegExp(r'[^0-9]'), '');
  if (!(pDigits.length == 10 || pDigits.length == 11)) return false;

  // Require document and validate as cpf (11) or rg (9)
  final d = (document ?? '').trim();
  final dDigits = d.replaceAll(RegExp(r'[^0-9]'), '');
  if (dDigits.isEmpty) return false;
  if (dDigits.length == 11) {
    if (!isValidCpf(dDigits)) return false;
  } else if (dDigits.length == 9) {
    // RG (9 digits) accepted
  } else {
    return false;
  }

  return true;
}
