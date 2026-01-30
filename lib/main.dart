import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/connectivity_service.dart';
import 'presentation/navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1B2A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LytixApp());
}

class LytixApp extends StatelessWidget {
  const LytixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Connectivity Service
        ChangeNotifierProvider.value(value: connectivityService),
      ],
      child: MaterialApp(
        title: 'Lytix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          // Apply responsive text scaling
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
