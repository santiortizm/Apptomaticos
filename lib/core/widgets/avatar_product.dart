// import 'dart:io';

// import 'package:apptomaticos/core/constants/colors.dart';
// import 'package:apptomaticos/core/services/permissions_service.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AvatarProduct extends StatefulWidget {
//   const AvatarProduct({super.key, this.imageUrl, required this.onUpLoad});
//   final String? imageUrl;
//   final void Function(String imageUrl) onUpLoad;

//   @override
//   State<AvatarProduct> createState() => _AvatarProductState();
// }

// class _AvatarProductState extends State<AvatarProduct> {
//   final ImagePicker _picker = ImagePicker();
//   final SupabaseClient supabase = Supabase.instance.client;
//   XFile? _selectedImage;
//   // Método para verificar permisos y abrir opciones de selección de imagen
//   Future<void> _selectImage() async {
//     // Verificar y solicitar permisos de cámara y almacenamiento
//     final bool permissionGranted = await storagePermission();
//     if (permissionGranted) {
//       // Si los permisos están concedidos, mostrar opciones
//       showModalBottomSheet(
//         // ignore: use_build_context_synchronously
//         context: context,
//         builder: (BuildContext context) {
//           return SafeArea(
//             child: Wrap(
//               children: <Widget>[
//                 ListTile(
//                   leading: const Icon(Icons.photo_library),
//                   title: const Text('Seleccionar de la galería'),
//                   onTap: () async {
//                     Navigator.of(context).pop();
//                     final XFile? image =
//                         await _picker.pickImage(source: ImageSource.gallery);
//                     if (image == null) {
//                       return;
//                     }
//                     final imageBytes = await image.readAsBytes();
//                     // const productId = ;
//                     const imagePath = '/$productId/product';
//                     await supabase.storage
//                         .from('products')
//                         .uploadBinary(imagePath, imageBytes);
//                     final imageUrl = supabase.storage
//                         .from('products')
//                         .getPublicUrl(imagePath);
//                     onUpLoad(imageUrl);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.camera_alt),
//                   title: const Text('Tomar una foto'),
//                   onTap: () async {
//                     Navigator.of(context).pop();
//                     final XFile? image =
//                         await _picker.pickImage(source: ImageSource.camera);
//                     if (image != null) {
//                       setState(() {
//                         _selectedImage = image;
//                       });
//                     }
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     } else {
//       // Si no se concedieron permisos, mostrar un SnackBar
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               const Text('Permisos de almacenamiento y cámara no concedidos.'),
//           action: SnackBarAction(
//             label: 'Configurar',
//             onPressed: () {
//               openAppSettings();
//             },
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircleAvatar(
//           radius: 50,
//           backgroundImage: imageUrl != null
//               ? FileImage(File(imageUrl!))
//               : const AssetImage('assets/images/fondo1.jpg') as ImageProvider,
//         ),
//         Padding(
//           padding: EdgeInsets.only(
//             top: size.height * 0.075,
//           ),
//           child: IconButton(
//             style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(redApp)),
//             color: redApp,
//             onPressed: _selectImage,
//             icon: const Icon(
//               size: 26,
//               Icons.camera_alt_rounded,
//               color: Colors.black,
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
