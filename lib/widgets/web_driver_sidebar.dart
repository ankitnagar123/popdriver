import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import '../utils/driver_menu_actions.dart';
import '../utils/web_driver_layout.dart';

enum WebSidebarAction { deleteAccount, logout }

class WebDriverSidebar extends StatelessWidget {
  const WebDriverSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const int homeIndex = 0;
  static const int ridesIndex = 1;
  static const int earningsIndex = 2;
  static const int notificationIndex = 3;
  static const int rateReviewsIndex = 4;
  static const int supportIndex = 5;
  static const int profileIndex = 6;
  static const int inviteFriendsIndex = 7;
  static const int changePasswordIndex = 8;

  static const _mainItems = <_NavItem>[
    _NavItem(Icons.home_rounded, 'Home', index: homeIndex),
    _NavItem(Icons.work_history_outlined, 'Rides', index: ridesIndex),
    _NavItem(Icons.payments_outlined, 'Earnings', index: earningsIndex),
  ];

  static const _moreItems = <_NavItem>[
    _NavItem(Icons.notifications_outlined, 'Notification', index: notificationIndex),
    _NavItem(Icons.rate_review_outlined, 'Rate & Reviews', index: rateReviewsIndex),
    _NavItem(Icons.support_agent_outlined, 'Support', index: supportIndex),
    _NavItem(Icons.person_outline_rounded, 'Profile', index: profileIndex),
    _NavItem(Icons.share_outlined, 'Invite Friends', index: inviteFriendsIndex),
    _NavItem(Icons.lock_outline_rounded, 'Change Password', index: changePasswordIndex),
    _NavItem(
      Icons.delete_forever_outlined,
      'Delete Account',
      action: WebSidebarAction.deleteAccount,
    ),
    _NavItem(
      Icons.logout_rounded,
      'Sign Out',
      action: WebSidebarAction.logout,
      danger: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: WebDriverLayout.sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyColors.primary,
            MyColors.primary.withOpacity(0.92),
            MyColors.DarkBlue.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POP Driver',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Driver Portal',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  ..._mainItems.map((item) => _buildNavTile(context, item)),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'More'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._moreItems.map(
                    (item) => _buildNavTile(context, item, indented: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/trip.png',
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Go online to receive rides',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    _NavItem item, {
    bool indented = false,
  }) {
    final isAction = item.action != null;
    final selected = !isAction && selectedIndex == item.index;

    return Padding(
      padding: EdgeInsets.fromLTRB(indented ? 16 : 10, 2, 10, 2),
      child: Material(
        color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onTap(context, item),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: indented ? 14 : 16,
              vertical: indented ? 11 : 13,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: item.danger
                      ? Colors.red.shade200
                      : selected
                          ? Colors.white
                          : Colors.white70,
                  size: indented ? 19 : 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.danger
                          ? Colors.red.shade100
                          : selected
                              ? Colors.white
                              : Colors.white70,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: indented ? 12.5 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, _NavItem item) {
    switch (item.action) {
      case WebSidebarAction.logout:
        DriverMenuActions.showLogoutDialog(context);
        return;
      case WebSidebarAction.deleteAccount:
        DriverMenuActions.showDeleteAccountDialog(context);
        return;
      case null:
        if (item.index != null) onSelected(item.index!);
    }
  }
}

class _NavItem {
  const _NavItem(
    this.icon,
    this.label, {
    this.index,
    this.action,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final int? index;
  final WebSidebarAction? action;
  final bool danger;
}
