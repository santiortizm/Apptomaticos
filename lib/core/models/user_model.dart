class User {
  final String idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String celular;
  final String rol;
  final String imagenUrl;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.celular,
    required this.rol,
    required this.imagenUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      idUsuario: map['idUsuario'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      correo: map['correo'],
      celular: map['celular'],
      rol: map['rol'],
      imagenUrl: map['imagenUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'celular': celular,
      'rol': rol,
      'imagenUrl': imagenUrl,
    };
  }
}
