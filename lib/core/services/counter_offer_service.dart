import 'package:App_Tomaticos/core/models/counter_offer_model.dart';
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

  //
  Future<List<CounterOffer>> fetchCounterOfferByProducer() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await supabaseClient
          .from('contra_oferta')
          .select()
          .eq('idPropietario', user.id)
          .order('created_at', ascending: false);

      return response.map((json) => CounterOffer.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Contra Ofertas que pertenecen a cada Comerciante
  Future<List<CounterOffer>> fetchCounterOfferByMerchant() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await supabaseClient
          .from('contra_oferta')
          .select()
          .eq('idComprador', user.id)
          .order('created_at', ascending: false);

      return response.map((json) => CounterOffer.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteCounterOffer(int id) async {
    try {
      final response = await supabaseClient
          .from('contra_oferta')
          .delete()
          .eq('idContraOferta', id);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
