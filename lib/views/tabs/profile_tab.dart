import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/myntra_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/wishlist_viewmodel.dart';
import '../login_view.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  String _formatName(String? email, String? displayName) {
    if (displayName != null && displayName.isNotEmpty) return displayName;
    if (email == null || email.isEmpty) return 'Maisha Shopper';
    final namePart = email.split('@').first;
    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authVM = Provider.of<AuthViewModel>(context, listen: false);
              await authVM.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: MyntraColors.primary),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final locationVM = Provider.of<LocationViewModel>(context);
    final wishlistVM = Provider.of<WishlistViewModel>(context);
    final userName = _formatName(user?.email, user?.displayName);

    return Scaffold(
      backgroundColor: MyntraColors.background,
      appBar: AppBar(
        title: const Text(
          'MY PROFILE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: MyntraColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        children: [
          // User Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFFFF0F3),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: MyntraColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MyntraColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No email associated',
                        style: const TextStyle(
                          fontSize: 13,
                          color: MyntraColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM MEMBER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: MyntraColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // User Information Section (UID removed)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACCOUNT DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: MyntraColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // Name Item
                _ProfileInfoTile(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: userName,
                ),
                const Divider(height: 16, color: MyntraColors.border),

                // Email Item
                _ProfileInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: user?.email ?? 'Not available',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Delivery Address Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DELIVERY ADDRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: MyntraColors.textMuted,
                      ),
                    ),
                    TextButton(
                      onPressed: () => locationVM.fetchLocation(),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'REFRESH GPS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: MyntraColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 20, color: MyntraColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        locationVM.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MyntraColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Shopping Activity Counts
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.favorite_border, color: MyntraColors.primary),
                      const SizedBox(height: 4),
                      Text(
                        '${wishlistVM.itemCount}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Wishlist Items',
                        style: TextStyle(fontSize: 11, color: MyntraColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: MyntraColors.border),
                const Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: MyntraColors.greenBadge),
                      SizedBox(height: 4),
                      Text(
                        'COD',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Payment Mode',
                        style: TextStyle(fontSize: 11, color: MyntraColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Log Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
              label: const Text(
                'LOG OUT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.redAccent,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MyntraColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: MyntraColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MyntraColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
