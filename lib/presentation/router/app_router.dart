import 'package:App_Tomaticos/auth_app.dart';
import 'package:App_Tomaticos/presentation/screens/login/login_widget.dart';
import 'package:App_Tomaticos/presentation/screens/menu/menu.dart';
import 'package:App_Tomaticos/presentation/screens/menu_trucker/menu_trucker.dart';
import 'package:App_Tomaticos/presentation/screens/products/add_product_page.dart';
import 'package:App_Tomaticos/presentation/screens/products/buy_product_page.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_merchant/my_counter_offers.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_merchant/my_orders.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_merchant/offert_page.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_merchant/payment_alternatives.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_merchant/purchase_page.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_merchant/shopping_merchant.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_producer/counter_offers_producer.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_producer/my_sales.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_producer/products_of_producer.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_trucker/my_transports.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_trucker/transport_history.dart';
import 'package:App_Tomaticos/presentation/screens/second_pages/second_pages_trucker/transport_status.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
        path: '/menuTrucker',
        builder: (context, state) => const MenuTrucker(),
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
        path: '/buyProduct',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return BuyProductPage(productId: data['productId']);
        },
      ),
      GoRoute(
          path: '/myProducts',
          builder: (context, state) => const ProductsOfProducer()),
      GoRoute(
        path: '/myCouterOffers',
        builder: (context, state) => const CounterOffersProducer(),
      ),
      GoRoute(
        path: '/mySales',
        builder: (context, state) => MySales(),
      ),
      GoRoute(
        path: '/purchase',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PurchasePage(
            productId: extra['productId'],
            imageUrl: extra['imageUrl'],
            price: extra['price'],
            cantidad: extra['cantidad'],
            availableQuantify: extra['availableQuantify'],
          );
        },
      ),
      GoRoute(
        path: '/counterOfferMerchant',
        builder: (context, state) => const MyCounterOffers(),
      ),
      GoRoute(
          path: '/paymentAlternatives',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentAlternatives(
              productId: extra['productId'],
              quantity: extra['quantity'],
              imageProduct: extra['imageProduct'],
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
      GoRoute(
        path: '/shoppingMerchant',
        builder: (context, state) => const ShoppingMerchant(),
      ),
      GoRoute(
        path: '/myOrders',
        builder: (context, state) => const MyOrders(),
      ),
      GoRoute(
        path: '/myTransports',
        builder: (context, state) => const MyTransports(),
      ),
      GoRoute(
        path: '/transportHistory',
        builder: (context, state) => TransportHistory(),
      ),
      GoRoute(
        path: '/transportStatus',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return TransportStatus(
            idTransporte: data['idTransporte'],
          );
        },
      ),
    ],
  );
}
