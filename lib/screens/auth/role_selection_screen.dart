import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBrown,
              AppTheme.primaryBrown.withOpacity(0.85),
              AppTheme.darkBrown,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo/Icon with shadow effect
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.cream.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.secondaryBrown.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: AppTheme.cream,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // App Name
                    Text(
                      'Chefventory',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.cream,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Smart Restaurant Inventory Management',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.cream.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 60),

                    // Role Selection Title
                    Text(
                      'How would you like to continue?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cream,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Admin Card
                    _buildModernRoleCard(
                      context: context,
                      icon: Icons.admin_panel_settings,
                      title: 'Restaurant Admin',
                      description: 'Create and manage your restaurant',
                      features: [
                        'Full inventory control',
                        'Manage staff members',
                        'Monitor activities',
                      ],
                      onTap: () {
                        Navigator.pushNamed(context, '/admin-auth');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Staff Card
                    _buildModernRoleCard(
                      context: context,
                      icon: Icons.people_alt_outlined,
                      title: 'Staff Member',
                      description: 'Join your restaurant team',
                      features: [
                        'Process orders',
                        'View inventory',
                        'Real-time alerts',
                      ],
                      onTap: () {
                        Navigator.pushNamed(context, '/staff-auth');
                      },
                    ),
                    
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppTheme.primaryBrown.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Icon container
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBrown.withOpacity(0.15),
                          AppTheme.secondaryBrown.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryBrown.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const SizedBox(height: 20),
                  
                  // CTA Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBrown,
                          AppTheme.primaryBrown.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






