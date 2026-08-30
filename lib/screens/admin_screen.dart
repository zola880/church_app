import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();

  // Premium color palette (matches other screens)
  static const Color _primary = Color(0xFF5B3FBB);
  static const Color _primaryDark = Color(0xFF2E1A66);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _bgLight = Color(0xFFF6F4FB);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryDark, _primary],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Statistics Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
            child: FutureBuilder<Map<String, int>>(
              future: _adminService.getUserStatistics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Error loading statistics'),
                    ),
                  );
                }

                final stats = snapshot.data ?? {};

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Users',
                        stats['total'] ?? 0,
                        Icons.people_alt_rounded,
                        const [Color(0xFF4E7DF0), Color(0xFF6FA0FF)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        stats['active'] ?? 0,
                        Icons.check_circle_rounded,
                        const [Color(0xFF2E9E5B), Color(0xFF52C77E)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Admins',
                        stats['admins'] ?? 0,
                        Icons.admin_panel_settings_rounded,
                        const [_primary, Color(0xFF7C5CE0)],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Users List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _adminService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDECEA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error_outline,
                              size: 40, color: Color(0xFFC62828)),
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primary.withOpacity(0.08),
                          ),
                          child: const Icon(Icons.people_outline,
                              size: 46, color: _primary),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'No users registered yet',
                          style: TextStyle(
                            fontSize: 15.5,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(
                        users[index], userProvider.currentUser?.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, int value, IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, String? currentUserId) {
    final bool isAdminUser = user.role == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isAdminUser
                  ? [_primary, const Color(0xFF7C5CE0)]
                  : [const Color(0xFFB9AEDD), const Color(0xFFD9D0F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Age: ${user.age}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
              Text('Phone: ${user.phoneNumber}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAdminUser
                      ? _accentGold.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isAdminUser
                        ? const Color(0xFF9A7B00)
                        : Colors.grey[700],
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role Toggle
            if (user.id != currentUserId)
              IconButton(
                icon: Icon(
                  isAdminUser
                      ? Icons.person_outline
                      : Icons.admin_panel_settings_outlined,
                  color: isAdminUser ? _primary : Colors.grey[500],
                ),
                onPressed: () => _toggleUserRole(user),
                tooltip: isAdminUser ? 'Make Member' : 'Make Admin',
              ),
            // Delete Button
            if (user.id != currentUserId)
              IconButton(
                icon: Icon(
                  user.isActive ? Icons.delete_outline : Icons.restore,
                  color: user.isActive
                      ? const Color(0xFFC62828)
                      : const Color(0xFF2E7D32),
                ),
                onPressed: () => _toggleUserStatus(user),
                tooltip: user.isActive ? 'Deactivate User' : 'Reactivate User',
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showPremiumDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_primary, Color(0xFF7C5CE0)],
                  ),
                ),
                child: const Icon(Icons.help_outline,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: Colors.grey[600]),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [_primary, Color(0xFF7C5CE0)],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context, true),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUserRole(UserModel user) async {
    final newRole = user.role == 'admin' ? 'member' : 'admin';

    final confirmed = await _showPremiumDialog(
      title: 'Change User Role',
      content:
          'Are you sure you want to change ${user.name}\'s role to $newRole?',
    );

    if (confirmed == true) {
      try {
        await _adminService.updateUserRole(user.id, newRole);
        if (mounted) {
          _showResultSnackBar('User role updated to $newRole');
        }
      } catch (e) {
        if (mounted) {
          _showResultSnackBar('Failed to update role: $e', isError: true);
        }
      }
    }
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    final action = user.isActive ? 'deactivate' : 'reactivate';

    final confirmed = await _showPremiumDialog(
      title: '${action.capitalize()} User',
      content: 'Are you sure you want to $action ${user.name}?',
    );

    if (confirmed == true) {
      try {
        if (user.isActive) {
          await _adminService.deactivateUser(user.id);
        } else {
          await _adminService.reactivateUser(user.id);
        }
        if (mounted) {
          _showResultSnackBar('User ${action}d successfully');
        }
      } catch (e) {
        if (mounted) {
          _showResultSnackBar('Failed to $action user: $e', isError: true);
        }
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}