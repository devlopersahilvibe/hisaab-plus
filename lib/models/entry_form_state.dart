class EntryFormStateData {
  String activeFilter; // 'all', 'lena', 'dena'
  String txType; // 'diya' (Lena banta hai) ya 'liya' (Dena banta hai)
  String selectedPaymentMode;
  String selectedTag;
  bool isAddAccordionOpen;
  final Set<dynamic> selectedFriendKeys;

  EntryFormStateData({
    this.activeFilter = 'all',
    this.txType = 'diya',
    this.selectedPaymentMode = 'UPI',
    this.selectedTag = 'Roommate',
    this.isAddAccordionOpen = false,
    Set<dynamic>? selectedFriendKeys,
  }) : selectedFriendKeys = selectedFriendKeys ?? {};

  static const List<String> availableTags = [
    'College',
    'Roommate',
    'Office',
    'Business',
    'Personal',
  ];
}
