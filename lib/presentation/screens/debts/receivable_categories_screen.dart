import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/receivable_service.dart';
import '../../../data/models/debtor.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class ReceivableCategoriesScreen extends StatefulWidget {
  final String userId;

  const ReceivableCategoriesScreen({super.key, required this.userId});

  @override
  State<ReceivableCategoriesScreen> createState() =>
      _ReceivableCategoriesScreenState();
}

class _ReceivableCategoriesScreenState
    extends State<ReceivableCategoriesScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  List<ReceivableCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ReceivableService>(context, listen: false);
      final cats = await service.getCategories(widget.userId);
      setState(() => _categories = cats);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ReceivableService>(context, listen: false);
      final newCat = ReceivableCategory(userId: widget.userId, name: name);
      await service.saveCategory(newCat);
      _nameController.clear();
      _loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      final service = Provider.of<ReceivableService>(context, listen: false);
      await service.deleteCategory(id);
      _loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
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
              _buildAddSection(),
              Expanded(
                child: _isLoading && _categories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCategoriesList(),
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
          const Text(
            'Gestionar Categorías',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildAddSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nueva Categoría',
                hintText: 'Ej. Comida, Internet...',
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Agregar Categoría',
              onPressed: _isLoading ? null : _addCategory,
              isLoading: _isLoading,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1);
  }

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'No hay categorías creadas',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.category,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                cat.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => _deleteCategory(cat.id),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
      },
    );
  }
}
