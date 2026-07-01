import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  State<ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  String selectedMode = "system"; // light | dark | system

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedMode = prefs.getString("app_theme") ?? "system";
    });
  }

  Future<void> _saveMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_theme", mode);

    setState(() {
      selectedMode = mode;
    });
  }

  // 🔥 BACKGROUND SWITCH
  Color _getBackgroundColor() {
    if (selectedMode == "dark") {
      return const Color(0xFF121212);
    } else {
      return const Color(0xFFF6F7F9);
    }
  }

  bool get isDark => selectedMode == "dark";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),

      // 🔥 APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        title: const Text(
          "App Theme",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [

            _modeCard(
              icon: Icons.light_mode_rounded,
              title: "Light Mode",
              subtitle: "Always use light theme",
              value: "light",
            ),

            const SizedBox(height: 12),

            _modeCard(
              icon: Icons.dark_mode_rounded,
              title: "Dark Mode",
              subtitle: "Better for night usage",
              value: "dark",
            ),


          ],
        ),
      ),
    );
  }

  // 🔥 CARD UI
  Widget _modeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedMode == value;

    return InkWell(
      onTap: () => _saveMode(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isSelected
                ? const Color(0xFFCC6D0D)
                : Colors.black.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            // 🔥 ICON BOX
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCC6D0D)
                    : const Color(0xFFCC6D0D).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFFCC6D0D),
              ),
            ),

            const SizedBox(width: 12),

            // 🔥 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 RADIO
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFFCC6D0D)
                  : (isDark ? Colors.white30 : Colors.black26),
            ),
          ],
        ),
      ),
    );
  }
}