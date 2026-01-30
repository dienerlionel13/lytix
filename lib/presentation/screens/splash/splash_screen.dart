import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../data/datasources/local/database_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize connectivity service
      setState(() => _statusText = 'Verificando conexión...');
      connectivityService.startMonitoring();
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize databases
      setState(() => _statusText = 'Cargando bases de datos...');
      await databaseHelper.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize biometric service
      setState(() => _statusText = 'Configurando seguridad...');
      await biometricService.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      // Complete
      setState(() => _statusText = '¡Listo!');
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to login or dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() => _statusText = 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, color: Colors.white24)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 32),

                // App Name
                Text(
                  'Lytix',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  'Gestión de Patrimonio',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const Spacer(flex: 2),

                // Loading Indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                const SizedBox(height: 20),

                // Status Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusText,
                    key: ValueKey(_statusText),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ),

                const Spacer(),

                // Version
                Text(
                  'v1.0.0.1',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white24,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
