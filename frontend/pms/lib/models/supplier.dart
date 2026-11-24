class Supplier {
  Supplier({
    this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.details,
  });

  String? id;
  String name;
  String location;
  String phone;
  String details;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['_id'] as String?,
      name: json['name'] as String,
      location: json['location'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }
}
