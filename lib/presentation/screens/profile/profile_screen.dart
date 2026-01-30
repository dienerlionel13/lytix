import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedCurrency = 'GTQ';

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
                  'Perfil',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () {
                      // Edit profile
                    },
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Header
                    _buildProfileHeader()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    // Account Settings
                    _buildAccountSettings()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Preferences
                    _buildPreferences()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Security
                    _buildSecurity()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Data & Sync
                    _buildDataSync()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton().animate().fadeIn(
                      duration: 600.ms,
                      delay: 500.ms,
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'JD',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Juan Díaz',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'juan.diaz@email.com',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Cuenta Activa',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.person, title: 'Cuenta'),
          const SizedBox(height: 16),
          _SettingsItem(
            icon: Icons.person_outline,
            label: 'Información Personal',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.email_outlined,
            label: 'Cambiar Email',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: '+502 5555 1234',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.tune, title: 'Preferencias'),
          const SizedBox(height: 16),
          _SettingsItem(
            icon: Icons.attach_money,
            label: 'Moneda Principal',
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              dropdownColor: AppColors.surfaceDark,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'GTQ', child: Text('Quetzal (Q)')),
                DropdownMenuItem(value: 'USD', child: Text('Dólar (\$)')),
              ],
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
              },
            ),
          ),
          _SettingsSwitch(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          _SettingsItem(
            icon: Icons.language,
            label: 'Idioma',
            value: 'Español',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.security, title: 'Seguridad'),
          const SizedBox(height: 16),
          _SettingsSwitch(
            icon: Icons.fingerprint,
            label: 'Autenticación Biométrica',
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() => _biometricEnabled = value);
            },
          ),
          _SettingsItem(
            icon: Icons.lock_outline,
            label: 'Cambiar Contraseña',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.devices,
            label: 'Dispositivos Conectados',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDataSync() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.cloud, title: 'Datos y Sincronización'),
          const SizedBox(height: 16),
          _SettingsItem(
            icon: Icons.cloud_sync,
            label: 'Sincronizar Ahora',
            value: 'Última: hace 5 min',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.backup,
            label: 'Exportar Datos',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.delete_outline,
            label: 'Eliminar Datos Locales',
            textColor: AppColors.warning,
            onTap: () {
              _showDeleteConfirmation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlineGradientButton(
      text: 'Cerrar Sesión',
      borderColor: AppColors.error,
      icon: Icons.logout,
      onPressed: () {
        _showLogoutConfirmation();
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning),
            SizedBox(width: 12),
            Text('Eliminar Datos', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todos los datos locales? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete data
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 12),
            Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.textColor,
    this.trailing,
    this.onTap,
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
            Icon(icon, color: Colors.white54, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (value != null)
              Text(
                value!,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              )
            else
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

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}
