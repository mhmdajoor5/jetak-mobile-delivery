
import 'package:deliveryboy/src/models/discount.dart';
import 'package:deliveryboy/src/models/media.dart';

class Restaurant {
  final int? id;
  final String? name;
  final double? deliveryFee;
  final String? address;
  final String? phone;
  final double? defaultTax;
  final bool? availableForDelivery;
  final List<dynamic>? customFields;
  final bool? hasMedia;
  final dynamic rate;
  final Discount? discount;
  final List<Media>? media;

  Restaurant({
    this.id,
    this.name,
    this.deliveryFee,
    this.address,
    this.phone,
    this.defaultTax,
    this.availableForDelivery,
    this.customFields,
    this.hasMedia,
    this.rate,
    this.discount,
    this.media,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        deliveryFee: (json["delivery_fee"])?.toDouble(),
        address: json["address"],
        phone: json["phone"],
        defaultTax: (json["default_tax"])?.toDouble(),
        availableForDelivery: json["available_for_delivery"],
        customFields: json["custom_fields"],
        hasMedia: json["has_media"],
        rate: json["rate"],
        discount: json["discount"] == null ? null : Discount.fromJson(json["discount"]),
        media: json["media"] == null
            ? null
            : List<Media>.from(json["media"]!.map((x) => Media.fromJSON(x))),
      );

  Map<String, dynamic>? toJson() => {
        "id": id,
        "name": name,
        "delivery_fee": deliveryFee,
        "address": address,
        "phone": phone,
        "default_tax": defaultTax,
        "available_for_delivery": availableForDelivery,
        "custom_fields": customFields,
        "has_media": hasMedia,
        "rate": rate,
        "discount": discount?.toJson(),
        "media": media == null ? null : List<Media>.from(media!.map((x) => x.toMap())),
      };
}
