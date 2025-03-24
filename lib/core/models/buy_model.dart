class Buy {
  final int id;
  final DateTime createdAt;
  final String alternativaPago;
  final String nombreProducto;
  final int cantidad;
  final double total;
  final DateTime fecha;
  final String idPropietario;
  final int idProducto;
  final String idComprador;
  final String imagenProducto;
  final String estadoCompra;

  Buy({
    required this.id,
    required this.alternativaPago,
    required this.createdAt,
    required this.nombreProducto,
    required this.cantidad,
    required this.total,
    required this.fecha,
    required this.idProducto,
    required this.idComprador,
    required this.idPropietario,
    required this.imagenProducto,
    required this.estadoCompra,
  });

  /// Convierte el modelo a un `Map<String, dynamic>` para insertarlo en Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idProducto': idProducto,
      'created_at': createdAt.toIso8601String(),
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'total': total,
      'alternativaPago': alternativaPago,
      'estadoCompra': estadoCompra,
      'idComprador': idComprador,
      'idPropietario': idPropietario,
      'imagenProducto': imagenProducto,
      'fecha': fecha.toIso8601String(),
    };
  }

  /// Crea una instancia de `BuyModel` desde un JSON (consulta de Supabase)
  factory Buy.fromJson(Map<String, dynamic> json) {
    return Buy(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at'] as String),
      alternativaPago: json['alternativaPago'],
      nombreProducto: json['nombreProducto'],
      cantidad: json['cantidad'],
      total: (json['total'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']),
      estadoCompra: json['estadoCompra'],
      idPropietario: json['idPropietario'],
      idProducto: json['idProducto'],
      idComprador: json['idComprador'],
      imagenProducto: json['imagenProducto'] ?? '',
    );
  }
}
