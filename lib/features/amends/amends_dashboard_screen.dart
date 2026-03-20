import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';

class AmendsDashboardScreen extends ConsumerWidget {
  const AmendsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Amends Workspace"),
          bottom: const TabBar(
            indicatorColor: Colors.indigo,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Step 8: The List", icon: Icon(Icons.format_list_bulleted)),
              Tab(text: "Step 9: Action", icon: Icon(Icons.bolt)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Step8ListView(),
            _Step9ActionView(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEntryDialog(context),
          label: const Text("Add to List"),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    // This allows the "Sponsor reminder" direct entry
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Amends (Step 8)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: "Person/Organization")),
            const TextField(decoration: InputDecoration(labelText: "Description of Harm")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Add to List")),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Step8ListView extends StatelessWidget {
  const _Step8ListView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Step 8: Made a list of all persons we had harmed, and became willing to make amends to them all.",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
        ),
        const SizedBox(height: 20),
        // Here you would render items with status == 'list'
        _buildAmendsItem("John Doe", "Financial harm from 2022", false),
        _buildAmendsItem("Family", "Dishonesty and absence", true),
      ],
    );
  }

  Widget _buildAmendsItem(String name, String harm, bool isWilling) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(harm),
        trailing: Switch(value: isWilling, onChanged: (v) {}, activeColor: Colors.green),
      ),
    );
  }
}

class _Step9ActionView extends StatelessWidget {
  const _Step9ActionView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Step 9: Made direct amends to such people wherever possible...",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
        ),
        const SizedBox(height: 20),
        // Here you render items where status == 'planning' or 'completed'
        const Center(child: Text("No active plans. Move items from Step 8 to begin.")),
      ],
    );
  }
}