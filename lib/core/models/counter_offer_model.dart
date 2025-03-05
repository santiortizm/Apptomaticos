class CounterOffer {
  final int? idContraOferta;
  final DateTime createdAt;
  final int cantidad;
  final double valorOferta;
  final String estadoOferta;
  final String? estadoPago;
  final String imagenProducto;
  final String nombreProducto;
  final int idProducto;
  final String idComprador;
  final String idPropietario;

  CounterOffer({
    this.idContraOferta,
    required this.createdAt,
    required this.cantidad,
    required this.valorOferta,
    required this.estadoOferta,
    this.estadoPago,
    required this.imagenProducto,
    required this.nombreProducto,
    required this.idProducto,
    required this.idComprador,
    required this.idPropietario,
  });

  factory CounterOffer.fromMap(Map<String, dynamic> map) {
    return CounterOffer(
      idContraOferta: map['idContraOferta'],
      createdAt: DateTime.parse(map['created_at']),
      cantidad: map['cantidad'],
      valorOferta: map['valorOferta'].toDouble(),
      estadoOferta: map['estadoOferta'],
      estadoPago: map['estadoPago'] ?? '',
      imagenProducto: map['imagenProducto'],
      nombreProducto: map['nombreProducto'],
      idProducto: map['idProducto'],
      idComprador: map['idComprador'],
      idPropietario: map['idPropietario'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt.toIso8601String(),
      'cantidad': cantidad,
      'valorOferta': valorOferta,
      'estadoOferta': estadoOferta,
      'imagenProducto': imagenProducto,
      'nombreProducto': nombreProducto,
      'idProducto': idProducto,
      'idComprador': idComprador,
      'idPropietario': idPropietario,
    };
  }
}
