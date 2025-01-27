import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<CurrencyService>(() => CurrencyService());
}
