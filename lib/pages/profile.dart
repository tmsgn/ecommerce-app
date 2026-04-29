import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? "Guest User";
    final email = user?.email ?? "No email linked";
    final photoURL = user?.photoURL;
    final color = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding:
          const EdgeInsets.only(bottom: 100), // prevent overlap with bottom nav
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? color.secondary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: color.primary.withOpacity(0.2),
                    backgroundImage:
                        photoURL != null ? NetworkImage(photoURL) : null,
                    child: photoURL == null
                        ? Icon(Icons.person,
                            size: 40, color: color.inversePrimary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: color.inversePrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Options list

            _buildProfileOption(context, Icons.local_shipping_outlined,
                'Shipping Addresses', () {}),
            _buildProfileOption(
                context, Icons.payment_outlined, 'Payment Methods', () {}),
            Divider(height: 32, color: color.primary.withOpacity(0.2)),

            _buildThemeToggle(context),

            _buildProfileOption(
                context, Icons.settings_outlined, 'Settings', () {}),
            _buildProfileOption(
                context, Icons.help_outline, 'Help & Support', () {}),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.red.shade900.withOpacity(0.3)
                      : Colors.red.shade50,
                  foregroundColor:
                      isDarkMode ? Colors.red.shade300 : Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final color = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? color.secondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color.inversePrimary),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: color.inversePrimary)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: color.inversePrimary.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? color.secondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, child) {
          bool switchValue;
          if (currentMode == ThemeMode.system) {
            switchValue = isDarkMode;
          } else {
            switchValue = currentMode == ThemeMode.dark;
          }

          return SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                switchValue ? Icons.dark_mode : Icons.light_mode,
                color: color.inversePrimary,
              ),
            ),
            title: Text(
              "Dark Mode",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color.inversePrimary,
              ),
            ),
            value: switchValue,
            activeColor: Colors.purple.shade300,
            onChanged: (value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        },
      ),
    );
  }
}
