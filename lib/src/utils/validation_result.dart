class ValidationResult {
  final bool isValid;
  final String? message;

  const ValidationResult({
    required this.isValid,
    this.message,
  });

  const ValidationResult.valid()
      : isValid = true,
        message = null;

  const ValidationResult.invalid(String message)
      : isValid = false,
        message = message;
}
