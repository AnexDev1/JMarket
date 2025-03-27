// lib/data/models/order_model.dart
class Order {
  final String userId;
  final String orderId;
  final String shippingAddress;
  final String orderStatus;
  final int quantity;
  final String orderDate;

  Order({
    required this.userId,
    required this.orderId,
    required this.shippingAddress,
    required this.orderStatus,
    required this.quantity,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      userId: json['user_id'],
      orderId: json['order_id']?.toString() ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      orderStatus: json['order_status'],
      quantity: json['quantity'] ?? 0,
      orderDate: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'order_id': orderId,
      'shipping_address': shippingAddress,
      'order_status': orderStatus,
      'quantity': quantity,
    };
  }
}
