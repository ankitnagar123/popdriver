import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  static const List<_SupportMenuItem> _items = [
    _SupportMenuItem(
      title: 'Write Support',
      subtitle: 'Send us a message or report an issue',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF019BA5),
      route: _SupportRoute.writeSupport,
    ),
    _SupportMenuItem(
      title: 'Frequently Asked Questions',
      subtitle: 'Quick answers to common questions',
      icon: Icons.help_outline_rounded,
      color: Color(0xFF0CBB70),
      route: _SupportRoute.faq,
    ),
    _SupportMenuItem(
      title: 'Privacy Policy',
      subtitle: 'How we handle your data',
      icon: Icons.privacy_tip_outlined,
      color: Color(0xFF5C6BC0),
      route: _SupportRoute.privacy,
    ),
    _SupportMenuItem(
      title: 'Terms & Condition',
      subtitle: 'Rules and terms of using the app',
      icon: Icons.description_outlined,
      color: Color(0xFFEF6C00),
      route: _SupportRoute.terms,
    ),
  ];

  void _onItemTap(_SupportRoute route) {
    switch (route) {
      case _SupportRoute.writeSupport:
        Get.toNamed(RouteHelper.getWriteSupportScreenRoute());
        break;
      case _SupportRoute.faq:
        Get.toNamed(RouteHelper.getFrequentlyScreenScreenRoute());
        break;
      case _SupportRoute.privacy:
        Get.toNamed(RouteHelper.getPrivacyPolicyScreenRoute());
        break;
      case _SupportRoute.terms:
        Get.toNamed(RouteHelper.getTermConditionScreenRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: MyColors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF02B3BE),
                Color(0xFF019BA5),
                Color(0xFF017A82),
              ],
            ),
          ),
        ),
        title: Text(
          'Support'.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildHeaderBanner(),
          const SizedBox(height: 16),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildMenuTile(item),
            ),
          ),
          const SizedBox(height: 8),
          _buildHelpFooter(),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF017A82),
            Color(0xFF019BA5),
            Color(0xFF02B3BE),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?'.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose an option below for help, policies, or to contact us.'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(_SupportMenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTap(item.route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title.tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: MyColors.black,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade400,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 20, color: MyColors.primary.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Our team usually responds within 24 hours.'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SupportRoute { writeSupport, faq, privacy, terms }

class _SupportMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _SupportRoute route;

  const _SupportMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
