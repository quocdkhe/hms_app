enum BillingItemType { roomFee, service, extraFee }

class BillingItem {
  final String title;
  final String subtitle;
  final int price;
  final BillingItemType type;

  BillingItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.type,
  });
}
