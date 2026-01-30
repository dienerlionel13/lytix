import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Acerca de',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Logo and App Info
                    _buildAppInfo()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    // Version Info
                    _buildVersionCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Features
                    _buildFeaturesCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Links
                    _buildLinksCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Developer Info
                    _buildDeveloperCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 40),

                    // Copyright
                    Center(
                      child: Text(
                        '© 2024 ${AppConstants.appName}. Todos los derechos reservados.',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        // Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            Icons.analytics_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestión de Patrimonio y Flujo de Caja',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersionCard() {
    return GlassCard(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.tag,
            label: 'Versión',
            value: AppConstants.fullVersion,
          ),
          const Divider(color: Colors.white12, height: 24),
          _InfoRow(
            icon: Icons.build,
            label: 'Build',
            value: '#${AppConstants.buildNumber}',
          ),
          const Divider(color: Colors.white12, height: 24),
          _InfoRow(
            icon: Icons.flutter_dash,
            label: 'Framework',
            value: 'Flutter',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Características',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _FeatureItem(
            icon: Icons.account_balance_wallet,
            title: 'Control de Deudas',
            description: 'Gestiona cuentas por cobrar y pagar',
          ),
          _FeatureItem(
            icon: Icons.credit_card,
            title: 'Visacuotas',
            description: 'Seguimiento de compras a plazos',
          ),
          _FeatureItem(
            icon: Icons.pie_chart,
            title: 'Activos',
            description: 'Inventario y valuación de patrimonio',
          ),
          _FeatureItem(
            icon: Icons.analytics,
            title: 'Dashboards',
            description: 'Análisis visual de tus finanzas',
          ),
          _FeatureItem(
            icon: Icons.cloud_sync,
            title: 'Sincronización',
            description: 'Trabaja offline y sincroniza a la nube',
          ),
          _FeatureItem(
            icon: Icons.fingerprint,
            title: 'Seguridad',
            description: 'Autenticación biométrica',
          ),
        ],
      ),
    );
  }

  Widget _buildLinksCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enlaces',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _LinkItem(
            icon: Icons.privacy_tip,
            label: 'Política de Privacidad',
            onTap: () {
              // Open privacy policy
            },
          ),
          _LinkItem(
            icon: Icons.description,
            label: 'Términos de Servicio',
            onTap: () {
              // Open terms
            },
          ),
          _LinkItem(
            icon: Icons.help_outline,
            label: 'Centro de Ayuda',
            onTap: () {
              // Open help
            },
          ),
          _LinkItem(
            icon: Icons.star_rate,
            label: 'Calificar App',
            onTap: () {
              // Open store rating
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desarrollador',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.person,
            label: 'Equipo',
            value: AppConstants.developerName,
          ),
          const Divider(color: Colors.white12, height: 24),
          _InfoRow(
            icon: Icons.email,
            label: 'Soporte',
            value: AppConstants.supportEmail,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
