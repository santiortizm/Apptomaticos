class Transport {
  final int idTransporte;
  final DateTime createdAt;
  final String fechaCargue;
  final String fechaEntrega;
  final String estado;
  final double pesoCarga;
  final int valorTransporte;
  final int idCompra;
  final String idTransportador;
  Transport({
    required this.idTransporte,
    required this.createdAt,
    required this.fechaCargue,
    required this.fechaEntrega,
    required this.estado,
    required this.pesoCarga,
    required this.valorTransporte,
    required this.idCompra,
    required this.idTransportador,
  });

  factory Transport.fromMap(Map<String, dynamic> map) {
    return Transport(
      idTransporte: map['idTransporte'],
      createdAt: DateTime.parse(map['created_at'] as String),
      fechaCargue: map['fechaCargue'],
      fechaEntrega: map['fechaEntrega'],
      estado: map['estado'],
      pesoCarga: map['pesoCarga'].toDouble(),
      valorTransporte: map['valorTransporte'],
      idCompra: map['idCompra'],
      idTransportador: map['idTransportador'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTransporte': idTransporte,
      'created_at': createdAt.toIso8601String(),
      'fechaCargue': fechaCargue,
      'fechaEntrega': fechaEntrega,
      'estado': estado,
      'pesoCarga': pesoCarga,
      'valorTransporte': valorTransporte,
      'idCompra': idCompra,
      'idTransportador': idTransportador,
    };
  }
}
