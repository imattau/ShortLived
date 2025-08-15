class LnurlPayParams {
  final Uri callback;
  final int minSendable; // millisats
  final int maxSendable; // millisats
  final String? nostrPubkey;
  LnurlPayParams({required this.callback, required this.minSendable, required this.maxSendable, this.nostrPubkey});
}

class Invoice {
  final String bolt11;
  Invoice(this.bolt11);
}
