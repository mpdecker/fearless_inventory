import 'package:flutter/material.dart';
import '../inventory/resentment_list_screen.dart';
import '../inventory/fear_list_screen.dart';
import '../inventory/harm_list_screen.dart';

class Step4LandingScreen extends StatelessWidget {
  const Step4LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 4: Moral Inventory")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Made a searching and fearless moral inventory of ourselves.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          _buildInventoryTile(
            context,
            "Resentment Inventory",
            "The 'number one' offender.",
            Icons.format_list_bulleted,
            Colors.redAccent,
            const ResentmentListScreen(),
          ),
          _buildInventoryTile(
            context,
            "Fear Inventory",
            "Reviewing our fears thoroughly.",
            Icons.warning_amber_rounded,
            Colors.amber.shade800,
            const FearListScreen(),
          ),
          _buildInventoryTile(
            context,
            "Sex & Harm Inventory",
            "Reviewing our own conduct.",
            Icons.people_outline,
            Colors.teal,
            const HarmListScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTile(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget screen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}