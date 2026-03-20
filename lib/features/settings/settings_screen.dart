import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/export_service.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/amends_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Data & Export"),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            title: const Text('Export PDF Summary'),
            subtitle: const Text('Inventory and 10th Step patterns'),
            onTap: () => _handlePdfExport(ref),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Export Amends to Excel'),
            subtitle: const Text('Download your restitution plan'),
            onTap: () => _handleExcelExport(ref),
          ),
          
          const Divider(),
          _buildSectionHeader("Privacy"),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.grey),
            title: const Text('Clear All Data'),
            subtitle: const Text('Locally wipe all inventory and reviews'),
            onTap: () => _confirmDataWipe(context, ref),
          ),
          
          const Divider(),
          _buildSectionHeader("About"),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Recovery Resources'),
            onTap: () {
              // Navigation to resources or external links
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // --- Logic Handlers ---

  Future<void> _handlePdfExport(WidgetRef ref) async {
    final resentments = await ref.read(inventoryRepositoryProvider).watchResentments().first;
    final fears = await ref.read(inventoryRepositoryProvider).watchFears().first;
    final harms = await ref.read(inventoryRepositoryProvider).watchHarms().first;
    final reviews = await ref.read(reviewRepositoryProvider).watchAllReviews().first;
    
    await ExportService.generateInventoryPdf(
      resentments: resentments,
      fears: fears,
      harms: harms,
      reviews: reviews,
    );
  }

  Future<void> _handleExcelExport(WidgetRef ref) async {
    final amends = await ref.read(amendsRepositoryProvider).watchAll().first;
    await ExportService.exportToExcel(amends);
  }

  void _confirmDataWipe(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear all data?"),
        content: const Text("This action cannot be undone. All your inventory, reviews, and amends will be permanently deleted from this device."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // Implementation for database wipe
              Navigator.pop(context);
            }, 
            child: const Text("Delete Everything", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}