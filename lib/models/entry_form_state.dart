class EntryFormStateData {
  String activeFilter; // 'all', 'lena', 'dena'
  String txType; // 'diya' ya 'liya'
  String selectedPaymentMode;
  String? selectedTag; // Nullable -> Tag chunna optional hai
  bool isAddAccordionOpen;
  final Set<dynamic> selectedFriendKeys;

  // By default sirf 3 tags + runtime custom tags
  List<String> availableTags;

  EntryFormStateData({
    this.activeFilter = 'all',
    this.txType = 'diya',
    this.selectedPaymentMode = 'UPI',
    this.selectedTag, // By default koi zabardasti selected nahi
    this.isAddAccordionOpen = false,
    Set<dynamic>? selectedFriendKeys,
    List<String>? availableTags,
  }) : selectedFriendKeys = selectedFriendKeys ?? {},
       availableTags = availableTags ?? ['Personal', 'Business', 'College'];
}
