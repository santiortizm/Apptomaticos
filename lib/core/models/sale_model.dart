class Sale {
  final int? idVenta;
  final DateTime createdAt;
  final String estadoVenta;
  final int idCompra;

  Sale({
    this.idVenta,
    required this.createdAt,
    required this.estadoVenta,
    required this.idCompra,
  });

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt.toIso8601String(),
      'estadoVenta': estadoVenta,
      'idCompra': idCompra
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
        idVenta: map['idVenta'],
        createdAt: DateTime.parse(map['created_at']),
        estadoVenta: map['estadoVenta'],
        idCompra: map['idCompra']);
  }
}
