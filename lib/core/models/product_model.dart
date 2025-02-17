class Product {
  final int idProducto;
  final DateTime createdAt;
  final String nombreProducto;
  final int cantidad;
  final String descripcion;
  final String maduracion;
  final String fertilizantes;
  final String fechaCosecha;
  final String fechaCaducidad;
  final double precio;
  final String? idImagen;
  final String idPropietario;

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
    this.idImagen,
    required this.idPropietario,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      idProducto: map['idProducto'],
      createdAt: DateTime.parse(map['created_at'] as String),
      nombreProducto: map['nombreProducto'],
      cantidad: map['cantidad'],
      descripcion: map['descripcion'],
      maduracion: map['maduracion'],
      fertilizantes: map['fertilizantes'],
      fechaCosecha: map['fechaCosecha'],
      fechaCaducidad: map['fechaCaducidad'],
      precio: map['precio'].toDouble(),
      idImagen: map['idImage'],
      idPropietario: map['idPropietario'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'created_at': createdAt.toIso8601String(),
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'maduracion': maduracion,
      'fertilizantes': fertilizantes,
      'fechaCosecha': fechaCosecha.toString(),
      'fechaCaducidad': fechaCaducidad.toString(),
      'precio': precio,
      'idImagen': idImagen,
      'idPropietario': idPropietario,
    };
  }
}
