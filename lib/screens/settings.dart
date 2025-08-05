import 'package:flutter/material.dart';
import 'package:hello_world/login.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Settings')),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 80),
            children: [
              SizedBox(height: 16),
              _buildSection([
                _buildTile(Icons.person, 'Account', () {}),
                _buildTile(Icons.lock, 'Privacy', () {}),
              ]),
              SizedBox(height: 32),
              _buildSection([_buildTile(Icons.language, 'Language', () {})]),
              SizedBox(height: 32),
              _buildSection([
                _buildTile(Icons.info, 'About', () {}),
                _buildTile(Icons.help, 'Help', () {}),
              ]),
              SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> tiles) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(
          tiles.length,
          (index) => Column(
            children: [
              if (index != 0)
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
              tiles[index],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
