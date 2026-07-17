/// ============================================================
/// DOMAIN — Business Logic Primitives
/// ============================================================
///
/// Domain Layer contains types and logic specific to the Textile ERP.
/// It bridges the generic Design System with Ambaji's specific entities.
///
/// Hierarchy: Theme → Plasma → Cells → Tissues → Organs → **Domain** → Systems
/// ============================================================
library;

export 'domain/types.dart';
export 'domain/amounts.dart';

// -- PRODUCTION --
export 'domain/production/stage_badge.dart';
export 'domain/production/stage_icon.dart';
export 'domain/production/challan_card.dart';
export 'domain/production/stock_indicator.dart';
export 'domain/production/production_timeline.dart';
export 'domain/production/cutting_timeline.dart';
export 'domain/production/identity.dart';
export 'domain/production/status.dart';
export 'domain/production/kpi_tile.dart';
export 'domain/production/kpi_strip.dart';
export 'domain/production/sync_monitor.dart';

// -- FINANCIAL --
export 'domain/financial/account.dart';
export 'domain/financial/ledger.dart';
export 'domain/financial/tokens.dart';
export 'domain/financial/indicators.dart';
export 'domain/financial/identity_badges.dart';
export 'domain/financial/party_card.dart';

// -- INVENTORY --
export 'domain/inventory/identity.dart';
export 'domain/inventory/summary.dart';

// -- DOCUMENTS --
export 'domain/documents/document.dart';

// -- GENERAL & SEARCH --
export 'domain/general/meta.dart';
export 'domain/search/results.dart';
