import 'package:apptomaticos/core/utils/auth_app.dart';
import 'package:apptomaticos/presentation/screens/login/login_widget.dart';
import 'package:apptomaticos/presentation/screens/products/add_product_page.dart';
import 'package:apptomaticos/presentation/screens/menu/menu.dart';
import 'package:apptomaticos/presentation/screens/second_pages/second_pages_merchant/offert_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter _router;

  AppRouter()
      : _router = GoRouter(
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
              path: '/offertProduct',
              builder: (context, state) => const OffertPage(),
            ),
            // GoRoute(
            //   path: '/buyProduct',
            //   builder: (context, state) => const BuyProductWidget(
            //     productId: '',
            //   ),
            // )
          ],
        );
  GoRouter get router => _router;
}
