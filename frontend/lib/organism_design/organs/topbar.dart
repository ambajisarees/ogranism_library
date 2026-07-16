import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../cells.dart';
import '../tissues.dart';
import '../plasma/popover.dart';
import 'workspace_controller.dart';

/// [OrganTopbar] — The primary control center of the Kinetic Workspace.
/// 
/// Sits at the top of the application shell, providing branding, search, 
/// and global actions. Height is fixed at 48px.
class OrganTopbar extends StatelessWidget implements PreferredSizeWidget {
  final KineticWorkspaceController controller;
  final VoidCallback? onSearchTap;

  const OrganTopbar({
    super.key,
    required this.controller,
    this.onSearchTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(OrganismTheme.topbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final metadata = user?.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ?? email.split('@')[0];
    final initials = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Container(
      height: OrganismTheme.topbarHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0), // Aligns menu icon center with NavBoat rail center (28px)
      child: Row(
        children: [
          // LEFT: Toggle + Logo
          _AnimatedMenuIcon(
            isCollapsed: controller.isSidebarCollapsed,
            onPressed: controller.toggleSidebar,
          ),
          const SizedBox(width: 12.0), // Aligns logo left with NavItem character start (58px)
          const AmbajiSareeLogo(size: 24, isCollapsed: true), // Minimalist branding as requested
          
          const Spacer(),

          // RIGHT: Actions + Search + Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // STANDARDIZED COMMAND PALETTE LAUNCHER
              TissueCommandPaletteLauncher(
                key: const ValueKey('global_search_launcher'),
                placeholder: 'Search...',
                onTap: onSearchTap ?? () {
                  TissueCommandPalette.show(
                    context, 
                    actions: [
                      CommandPaletteAction(
                        id: 'nav_parties',
                        label: 'Parties',
                        subtitle: 'Manage customer and supplier accounts',
                        icon: LucideIcons.users,
                        onSelect: () => controller.setModuleIndex(1),
                      ),
                      CommandPaletteAction(
                        id: 'nav_items',
                        label: 'Items',
                        subtitle: 'Inventory and stock master',
                        icon: LucideIcons.box,
                        onSelect: () => controller.setModuleIndex(2),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: OrganismTheme.spacingMd),
              CellButton(
                text: '',
                icon: LucideIcons.bell,
                variant: CellButtonVariant.ghost,
                isCompact: true,
                onPressed: () {},
              ),
              const SizedBox(width: OrganismTheme.spacingSm),
              CellButton(
                text: '',
                icon: LucideIcons.settings,
                variant: CellButtonVariant.ghost,
                isCompact: true,
                onPressed: () {},
              ),
              const SizedBox(width: OrganismTheme.spacingMd),
              PlasmaPopover(
                explicitWidth: 260,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                trigger: _HoverableAvatar(initials: initials),
                content: _UserProfileCard(
                  onSignOut: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoverableAvatar extends StatefulWidget {
  final String initials;
  const _HoverableAvatar({required this.initials});

  @override
  State<_HoverableAvatar> createState() => _HoverableAvatarState();
}

class _HoverableAvatarState extends State<_HoverableAvatar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: OrganismTheme.durationFast,
        decoration: BoxDecoration(
          borderRadius: OrganismTheme.borderMd,
          boxShadow: _isHovered ? OrganismTheme.focusShadows(context) : null,
          border: Border.all(
            color: _isHovered ? colors.primary : colors.surfaceActive,
            width: 1.5,
          ),
        ),
        child: CellAvatar(
          name: widget.initials,
          size: 32,
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  final VoidCallback onSignOut;
  const _UserProfileCard({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'N/A';
    final metadata = user?.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ?? email.split('@')[0];
    final initials = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CellAvatar(
                name: initials,
                size: 40,
              ),
              const SizedBox(width: OrganismTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: OrganismTheme.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: OrganismTheme.bodySmall(context).copyWith(
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: OrganismTheme.spacingMd),
          const Divider(),
          const SizedBox(height: OrganismTheme.spacingSm),
          CellButton(
            text: 'Sign Out',
            icon: LucideIcons.logOut,
            variant: CellButtonVariant.ghost,
            isCompact: true,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

/// [AnimatedMenuIcon] — A specialized toggle icon that animates its state.
class _AnimatedMenuIcon extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onPressed;

  const _AnimatedMenuIcon({
    required this.isCollapsed,
    required this.onPressed,
  });

  @override
  State<_AnimatedMenuIcon> createState() => _AnimatedMenuIconState();
}

class _AnimatedMenuIconState extends State<_AnimatedMenuIcon> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: OrganismTheme.durationStandard,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: OrganismTheme.curveStandard),
    );

    if (widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedMenuIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    return OrganismFocus(
      onTap: widget.onPressed,
      borderRadius: OrganismTheme.borderMd,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: OrganismTheme.durationFast,
            curve: OrganismTheme.curveStandard,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isHovered ? colors.surfaceSubtle : Colors.transparent,
              borderRadius: OrganismTheme.borderMd,
            ),
            child: Center(
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Icon(
                  widget.isCollapsed ? LucideIcons.alignLeft : LucideIcons.menu,
                  size: 20,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isHovered = false;
}
