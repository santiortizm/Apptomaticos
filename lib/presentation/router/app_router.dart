import 'package:apptomaticos/core/utils/auth_app.dart';
import 'package:apptomaticos/presentation/screens/login/login_widget.dart';
import 'package:apptomaticos/presentation/screens/products/add_product_widget.dart';
import 'package:apptomaticos/presentation/screens/products/menu_products_widget.dart';
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
              builder: (context, state) => const MenuProductsWidget(),
            ),
            GoRoute(
              path: '/registerProduct',
              builder: (context, state) => const AddProductWidget(),
            )
          ],
        );
  GoRouter get router => _router;
}
