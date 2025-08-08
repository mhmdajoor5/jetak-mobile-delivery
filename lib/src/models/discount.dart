
class Discount {
  final List<dynamic> availableDiscounts;
  final dynamic bestDiscount;
  final bool hasDiscounts;
  final int totalDiscounts;

  Discount({
    required this.availableDiscounts,
    required this.bestDiscount,
    required this.hasDiscounts,
    required this.totalDiscounts,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
        availableDiscounts: json["available_discounts"] ?? [],
        bestDiscount: json["best_discount"],
        hasDiscounts: json["has_discounts"] ?? false,
        totalDiscounts: json["total_discounts"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "available_discounts": availableDiscounts,
        "best_discount": bestDiscount,
        "has_discounts": hasDiscounts,
        "total_discounts": totalDiscounts,
      };
}
