class Product {
  final int idProducto;
  final DateTime createdAt;
  final String nombreProducto;
  final int cantidad;
  final String descripcion;
  final String maduracion;
  final String fertilizantes;
  final DateTime fechaCosecha;
  final DateTime fechaCaducidad;
  final double precio;

  // Constructor
  Product({
    required this.idProducto,
    required this.createdAt,
    required this.nombreProducto,
    required this.cantidad,
    required this.descripcion,
    required this.maduracion,
    required this.fertilizantes,
    required this.fechaCosecha,
    required this.fechaCaducidad,
    required this.precio,
  });

  // Factory para crear una instancia de Product desde un mapa (ej. de JSON)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      idProducto: map['idProducto'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      nombreProducto: map['nombreProducto'] as String,
      cantidad: map['cantidad'] as int,
      descripcion: map['descripcion'] as String,
      maduracion: map['maduracion'] as String,
      fertilizantes: map['fertilizantes'] as String,
      fechaCosecha: DateTime.parse(map['fechaCosecha'] as String),
      fechaCaducidad: DateTime.parse(map['fechaCaducidad'] as String),
      precio: map['precio'] as double,
    );
  }

  // Método para convertir la instancia de Product a un mapa (para enviar a Supabase, por ejemplo)
  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'created_at': createdAt.toIso8601String(),
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'maduracion': maduracion,
      'fertilizantes': fertilizantes,
      'fechaCosecha': fechaCosecha.toIso8601String(),
      'fechaCaducidad': fechaCaducidad.toIso8601String(),
      'precio': precio,
    };
  }
}
