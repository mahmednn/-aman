import 'package:flutter/material.dart';
import 'package:flutter_application_11/app_router.dart';
import 'package:flutter_application_11/constants/strings.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appRouter.authCubit),
        BlocProvider.value(value: appRouter.cartCubit),
        BlocProvider.value(value: appRouter.supplierCubit),
        BlocProvider.value(value: appRouter.categoriesCubit),
        BlocProvider.value(value: appRouter.locationCubit),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Tajawal',
          brightness:
              Brightness.dark, // يضمن أن تكون ألوان النصوص الافتراضية فاتحة
          scaffoldBackgroundColor:
              Colors.transparent, // يجعل خلفية السكافولد شفافة
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, // يجعل خلفية شريط التطبيق شفافة
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        builder: (context, child) {
          // هذا الـ builder يغلف التطبيق بالكامل
          return Directionality(
            textDirection: TextDirection.rtl, // Enforcing RTL globally
            child: Container(
              decoration: const BoxDecoration(gradient: mainBackgroundGradient),
              child: child ?? const SizedBox(),
            ),
          );
        },
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: splashRoute,
      ),
    );
  }
}
