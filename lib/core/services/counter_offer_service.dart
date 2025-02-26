import 'package:apptomaticos/core/models/counter_offer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/product_service.dart';

class CounterOfferService {
  final SupabaseClient supabaseClient;
  final ProductService productService;

  CounterOfferService(this.supabaseClient, this.productService);

  /// Crear una nueva contraoferta con estado inicial "En Espera"
  Future<bool> createContraOferta(CounterOffer oferta) async {
    try {
      // Insertar la contraoferta
      await supabaseClient.from('contra_oferta').insert(oferta.toMap());

      // Reducir temporalmente la cantidad del producto
      await productService.updateProductQuantity(
          oferta.idProducto, -oferta.cantidad);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cambiar el estado de la contraoferta y manejar cantidad del producto
  Future<bool> updateContraOfertaStatus(
      int ofertaId, String nuevoEstado) async {
    try {
      final response = await supabaseClient
          .from('contra_oferta')
          .select('*')
          .eq('idContraOferta', ofertaId)
          .single();

      final oferta = CounterOffer.fromMap(response);

      if (nuevoEstado == "Rechazado") {
        // Devolver la cantidad al producto
        await productService.updateProductQuantity(
            oferta.idProducto, oferta.cantidad);
      }

      await supabaseClient
          .from('contra_oferta')
          .update({'estadoOferta': nuevoEstado}).eq('idContraOferta', ofertaId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Revisar y revertir ofertas "En Espera" después de 30 minutos
  Future<void> checkExpiredOffers() async {
    try {
      final now = DateTime.now();
      final expirationTime = now.subtract(const Duration(minutes: 2));

      final ofertas = await supabaseClient
          .from('contra_oferta')
          .select('*')
          .eq('estadoOferta', 'En Espera')
          .lt('created_at', expirationTime.toIso8601String());

      for (var oferta in ofertas) {
        final contraOferta = CounterOffer.fromMap(oferta);
        await updateContraOfertaStatus(
            contraOferta.idContraOferta!, "Rechazado");
      }
    } catch (e) {
      return;
    }
  }
}
