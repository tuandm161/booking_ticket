class CheckoutResult {
  const CheckoutResult({
    required this.bookingId,
    required this.bookingCode,
    required this.totalAmount,
  });
  final String bookingId;
  final String bookingCode;
  final int totalAmount;
}
