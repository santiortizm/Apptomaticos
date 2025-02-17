class BuyModel {
  final int id;
  final String alternativaPago;
  final int cantidad;
  final double total;
  final DateTime fecha;
  final int idProducto;
  final String idComprador;

  BuyModel({
    required this.id,
    required this.alternativaPago,
    required this.cantidad,
    required this.total,
    required this.fecha,
    required this.idProducto,
    required this.idComprador,
  });

  factory BuyModel.fromJson(Map<String, dynamic> json) {
    return BuyModel(
      id: json['id'],
      alternativaPago: json['alternativaPago'],
      cantidad: json['cantidad'],
      total: json['total'].toDouble(),
      fecha: DateTime.parse(json['fecha']),
      idProducto: json['idProducto'],
      idComprador: json['idComprador'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alternativaPago': alternativaPago,
      'cantidad': cantidad,
      'total': total,
      'fecha': fecha.toIso8601String(),
      'idProducto': idProducto,
      'idComprador': idComprador,
    };
  }
}
