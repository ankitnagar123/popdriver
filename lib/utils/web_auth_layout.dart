import 'package:flutter/material.dart';

import 'colors.dart';

/// Shared responsive layout for auth screens (mobile + web/desktop).
class WebAuthLayout {
  static const double maxFormWidth = 440;
  static const double wideBreakpoint = 720;

  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= wideBreakpoint;
  }

  static Widget constrainForm(BuildContext context, Widget child) {
    if (!isWide(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxFormWidth),
        child: child,
      ),
    );
  }

  static Widget formCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: MyColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isWide(context) ? 0.08 : 0.12),
            blurRadius: isWide(context) ? 24 : 15,
            spreadRadius: isWide(context) ? 0 : 2,
            offset: Offset(0, isWide(context) ? 8 : 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyColors.background.withOpacity(0.95),
            MyColors.background,
          ],
        ),
      ),
      child: child,
    );
    return constrainForm(context, card);
  }

  static Widget page({
    required BuildContext context,
    required Widget child,
    PreferredSizeWidget? appBar,
    Widget? bottomBar,
    Color? backgroundColor,
  }) {
    final wide = isWide(context);
    return Scaffold(
      backgroundColor: backgroundColor ?? (wide ? const Color(0xFFF8FAFA) : Colors.white),
      appBar: appBar,
      bottomNavigationBar: wide ? null : bottomBar,
      body: SafeArea(
        child: wide
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        child,
                        if (bottomBar != null) ...[
                          const SizedBox(height: 16),
                          bottomBar,
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: child,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static double logoHeight(BuildContext context) =>
      isWide(context) ? 130 : 200;

  /// Compact centered dialog for web — avoids full-width modals on desktop.
  static Widget dialog({
    required BuildContext context,
    required Widget child,
    double maxWidth = 420,
    EdgeInsets insetPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 24,
    ),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide(context) ? maxWidth : 340,
        ),
        child: child,
      ),
    );
  }

  /// Centers page content on web with a max readable width.
  static Widget contentColumn({
    required BuildContext context,
    required List<Widget> children,
    double maxWidth = 600,
    EdgeInsets padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
  }) {
    final wide = isWide(context);
    final list = ListView(
      shrinkWrap: true,
      padding: wide
          ? EdgeInsets.symmetric(
              horizontal: padding.horizontal / 2,
              vertical: padding.vertical,
            )
          : padding,
      children: children,
    );

    if (!wide) return list;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
