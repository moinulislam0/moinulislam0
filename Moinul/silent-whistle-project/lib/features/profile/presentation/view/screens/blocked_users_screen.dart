import 'package:flutter/material.dart';
import 'package:jwells/features/auth/model_view/shout_provider.dart';
import 'package:jwells/features/profile/data/model/blocked_user_model.dart';
import 'package:jwells/features/profile/presentation/viewmodel/blocked_users_provider.dart';
import 'package:provider/provider.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockedUsersProvider>().fetchBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Consumer<BlockedUsersProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xff0D1F15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Blocked Users',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xff00d09c),
                    backgroundColor: const Color(0xff010702),
                    onRefresh: provider.fetchBlockedUsers,
                    child: _buildBody(provider),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BlockedUsersProvider provider) {
    if (provider.isLoading && provider.blockedUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xff00d09c)),
      );
    }

    if (provider.errorMessage != null && provider.blockedUsers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.block_outlined, size: 64, color: Colors.red.shade200),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      );
    }

    if (provider.blockedUsers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.shield_outlined, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            'No blocked users yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Users you block will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: provider.blockedUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = provider.blockedUsers[index];
        return _BlockedUserCard(
          user: user,
          isBusy: provider.isActionLoading,
          onUnblock: () => _handleUnblock(user),
        );
      },
    );
  }

  Future<void> _handleUnblock(BlockedUserModel user) async {
    final provider = context.read<BlockedUsersProvider>();
    final success = await provider.unblockUser(user.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (provider.successMessage ?? 'User unblocked successfully.')
              : (provider.errorMessage ?? 'Failed to unblock user.'),
        ),
        backgroundColor:
            success ? const Color(0xff00d09c) : Colors.redAccent,
      ),
    );

    if (success) {
      context.read<ShoutProvider>().fetchAllShouts(isRefresh: true);
    }
  }
}

class _BlockedUserCard extends StatelessWidget {
  final BlockedUserModel user;
  final bool isBusy;
  final VoidCallback onUnblock;

  const _BlockedUserCard({
    required this.user,
    required this.isBusy,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0D1F15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white10,
            backgroundImage:
                user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            child: user.avatar.isEmpty
                ? const Icon(Icons.person_outline, color: Colors.white54)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.displayHandle,
                  style: const TextStyle(
                    color: Color(0xff00d09c),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.locationText,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isBusy ? null : onUnblock,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff00d09c),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xff00d09c).withValues(
                alpha: 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(isBusy ? 'Please wait' : 'Unblock'),
          ),
        ],
      ),
    );
  }
}
