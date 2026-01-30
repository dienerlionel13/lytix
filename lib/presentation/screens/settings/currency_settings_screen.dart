import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/models/currency.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  final CurrencyService _currencyService = CurrencyService();

  CurrencySettings _settings = const CurrencySettings();
  List<ExchangeRate> _rates = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final rates = await _currencyService.getAllRates(
        _settings.primaryCurrency,
      );
      setState(() {
        _rates = rates
            .where(
              (r) => CurrencyInfo.supportedCurrencies.any(
                (c) => c.code == r.toCurrency,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshRates() async {
    setState(() => _isRefreshing = true);
    _currencyService.clearCache();

    try {
      final rates = await _currencyService.getAllRates(
        _settings.primaryCurrency,
      );
      setState(() {
        _rates = rates
            .where(
              (r) => CurrencyInfo.supportedCurrencies.any(
                (c) => c.code == r.toCurrency,
              ),
            )
            .toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tasas actualizadas'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPrimaryCurrencyCard(),
                      const SizedBox(height: 20),
                      _buildExchangeRatesCard(),
                      const SizedBox(height: 20),
                      _buildSettingsCard(),
                      const SizedBox(height: 20),
                      _buildConverterCard(),
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

  Widget _buildHeader() {
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
              'Monedas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _isRefreshing ? null : _refreshRates,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPrimaryCurrencyCard() {
    final currency = _settings.primaryCurrencyInfo;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      gradient: AppColors.primaryGradient,
      child: Column(
        children: [
          Text(currency.flag ?? '💰', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            currency.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currency.code,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Moneda Principal',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Currency selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: CurrencyInfo.supportedCurrencies.map((c) {
              final isSelected = c.code == _settings.primaryCurrency;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(primaryCurrency: c.code);
                    });
                    _loadData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white30,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      c.code,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildExchangeRatesCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasas de Cambio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currencyService.lastFetchTime != null)
                Text(
                  'Hace ${DateTime.now().difference(_currencyService.lastFetchTime!).inMinutes}m',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (_rates.isEmpty)
            Center(
              child: Text(
                'No hay tasas disponibles',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            )
          else
            ..._rates.map((rate) {
              final toCurrency = CurrencyInfo.fromCode(rate.toCurrency);
              return _RateRow(
                flag: toCurrency?.flag ?? '💱',
                name: toCurrency?.name ?? rate.toCurrency,
                code: rate.toCurrency,
                rate: rate.formattedRate,
                symbol: toCurrency?.symbol ?? '',
              );
            }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildSettingsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _SettingRow(
            icon: Icons.currency_exchange,
            title: 'Mostrar ambas monedas',
            subtitle: 'Ver valores en GTQ y USD',
            value: _settings.showBothCurrencies,
            onChanged: (v) => setState(() {
              _settings = _settings.copyWith(showBothCurrencies: v);
            }),
          ),
          const Divider(color: Colors.white12),
          _SettingRow(
            icon: Icons.sync,
            title: 'Actualización automática',
            subtitle: 'Obtener tasas al iniciar',
            value: _settings.autoUpdateRates,
            onChanged: (v) => setState(() {
              _settings = _settings.copyWith(autoUpdateRates: v);
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildConverterCard() {
    return _CurrencyConverter(
      settings: _settings,
      currencyService: _currencyService,
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }
}

class _RateRow extends StatelessWidget {
  final String flag;
  final String name;
  final String code;
  final String rate;
  final String symbol;

  const _RateRow({
    required this.flag,
    required this.name,
    required this.code,
    required this.rate,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$symbol $rate',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _CurrencyConverter extends StatefulWidget {
  final CurrencySettings settings;
  final CurrencyService currencyService;

  const _CurrencyConverter({
    required this.settings,
    required this.currencyService,
  });

  @override
  State<_CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<_CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  String _fromCurrency = 'USD';
  String _toCurrency = 'GTQ';
  double? _result;
  bool _isConverting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    setState(() => _isConverting = true);

    final result = await widget.currencyService.convert(
      amount: amount,
      from: _fromCurrency,
      to: _toCurrency,
    );

    setState(() {
      _result = result;
      _isConverting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Convertidor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Amount input
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),

          const SizedBox(height: 16),

          // Currencies row
          Row(
            children: [
              Expanded(
                child: _CurrencyDropdown(
                  value: _fromCurrency,
                  onChanged: (v) => setState(() => _fromCurrency = v!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = _fromCurrency;
                      _fromCurrency = _toCurrency;
                      _toCurrency = temp;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz, color: AppColors.accent),
                ),
              ),
              Expanded(
                child: _CurrencyDropdown(
                  value: _toCurrency,
                  onChanged: (v) => setState(() => _toCurrency = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GradientButton(
            text: 'Convertir',
            onPressed: _isConverting ? null : _convert,
            isLoading: _isConverting,
            icon: Icons.currency_exchange,
          ),

          if (_result != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Resultado',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyInfo.fromCode(_toCurrency)?.symbol ?? ''} ${_result!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceDark,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          items: CurrencyInfo.supportedCurrencies.map((c) {
            return DropdownMenuItem(
              value: c.code,
              child: Row(
                children: [
                  Text(c.flag ?? '', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(c.code, style: const TextStyle(color: Colors.white)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
