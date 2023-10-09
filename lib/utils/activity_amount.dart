int resolveAmountForActivity(int amount, String transactionType,
    String paymentStatus, String confirmation) {
  int resolvedAmount = 0;
  if (confirmation.toLowerCase() == 'declined') {
    return resolvedAmount;
  }
  if (paymentStatus.toLowerCase() == 'pending') {
    resolvedAmount =
        amount * (transactionType.toLowerCase() == 'lane' ? 1 : -1);
  }
  return resolvedAmount;
}
