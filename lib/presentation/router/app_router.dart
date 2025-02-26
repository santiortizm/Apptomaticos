import 'package:apptomaticos/auth_app.dart';
import 'package:apptomaticos/presentation/screens/login/login_widget.dart';
import 'package:apptomaticos/presentation/screens/products/add_product_page.dart';
import 'package:apptomaticos/presentation/screens/menu/menu.dart';
import 'package:apptomaticos/presentation/screens/second_pages/second_pages_merchant/offert_page.dart';
import 'package:apptomaticos/presentation/screens/second_pages/second_pages_merchant/payment_alternatives.dart';
import 'package:apptomaticos/presentation/screens/second_pages/second_pages_merchant/purchase_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // ✅ Define la pantalla de inicio
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthApp(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginWidget(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const Menu(),
      ),
      GoRoute(
        path: '/registerProduct',
        builder: (context, state) => const AddProductPage(),
      ),
      GoRoute(
        path: '/purchase',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PurchasePage(
            productId: extra['productId'],
            imageUrl: extra['imageUrl'],
            price: extra['price'],
            availableQuantify: extra['availableQuantify'],
          );
        },
      ),
      GoRoute(
          path: '/paymentAlternatives',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentAlternatives(
              productId: extra['productId'],
              quantity: extra['quantity'],
              totalPrice: extra['totalPrice'],
            );
          }),
      GoRoute(
        path: '/offerProduct',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OffertPage(
            productId: extra['productId'],
            imageUrl: extra['imageUrl'],
            price: extra['price'],
            availableQuantity: extra['availableQuantity'],
            productName: extra['productName'],
            ownerId: extra['ownerId'],
          );
        },
      ),
    ],
  );
}
