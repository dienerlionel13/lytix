import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSection(
                        title: 'Cuenta',
                        items: [
                          _SettingItem(
                            icon: Icons.person_outline,
                            title: 'Perfil',
                            subtitle: 'Información personal',
                            onTap: () =>
                                Navigator.pushNamed(context, '/profile'),
                          ),
                          _SettingItem(
                            icon: Icons.currency_exchange,
                            title: 'Monedas',
                            subtitle: 'Tasas de cambio y conversión',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/settings/currency',
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notificaciones',
                            subtitle: 'Alertas y recordatorios',
                            onTap: () {
                              // Todo: Navigate to notifications settings
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Datos',
                        items: [
                          _SettingItem(
                            icon: Icons.backup_outlined,
                            title: 'Respaldo',
                            subtitle: 'Sincronización y respaldo',
                            onTap: () {
                              // Todo: Navigate to backup settings
                            },
                          ),
                          _SettingItem(
                            icon: Icons.download_outlined,
                            title: 'Exportar',
                            subtitle: 'Exportar datos a Excel/PDF',
                            onTap: () {
                              // Todo: Export functionality
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Apariencia',
                        items: [
                          _SettingItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Tema',
                            subtitle: 'Oscuro (por defecto)',
                            trailing: const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onTap: () {
                              // Todo: Theme settings
                            },
                          ),
                          _SettingItem(
                            icon: Icons.language_outlined,
                            title: 'Idioma',
                            subtitle: 'Español',
                            onTap: () {
                              // Todo: Language settings
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Información',
                        items: [
                          _SettingItem(
                            icon: Icons.info_outline,
                            title: 'Acerca de',
                            subtitle: 'Versión y licencias',
                            onTap: () => Navigator.pushNamed(context, '/about'),
                          ),
                          _SettingItem(
                            icon: Icons.help_outline,
                            title: 'Ayuda',
                            subtitle: 'Preguntas frecuentes',
                            onTap: () {
                              // Todo: Help screen
                            },
                          ),
                          _SettingItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacidad',
                            subtitle: 'Política de privacidad',
                            onTap: () {
                              // Todo: Privacy policy
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildLogoutButton(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Configuración',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSection({
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: 50 * items.length),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GlassCard(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text(
              '¿Cerrar sesión?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Tus datos locales se mantendrán guardados.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: AppColors.error.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(
            'Cerrar sesión',
            style: TextStyle(
              color: AppColors.error.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
          ],
        ),
      ),
    );
  }
}
