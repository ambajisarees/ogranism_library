/// ============================================================
/// SYSTEMS — Page-Level Master Layouts (Level 5)
/// ============================================================
///
/// Systems are the highest architectural layer. They compose
/// entire page shells from Organs, Tissues, and data bindings.
///
/// Currently a placeholder — Level 5 architecture is coming.
/// Responsive layout helpers have been moved to `theme.dart`
/// to centralize all structural DNA in one location.
///
/// Examples of future Systems:
///   • StandardListDetailSystem — The master split-pane ERP pattern
///   • DashboardSystem          — Metric grid + chart scaffolding
///   • FormPageSystem           — Full-page form with validation flow
///
/// Hierarchy: Theme → Plasma → Cells → Tissues → Organs → **Systems**
/// ============================================================
library;


export 'systems/app_shell.dart';
export 'systems/master_layout.dart';

/// Future Level 5 Architectural Systems will be defined here.
/// This file acts as the assembly plant for complex, page-wide layout patterns.
