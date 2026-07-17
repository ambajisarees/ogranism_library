
/// [DomainLedgerType] — Standard financial mapping for the Textile ERP.
enum DomainLedgerType {
  sales,
  purchase,
  payment,
  receipt,
  journal,
  contra,
}

/// [DomainDocumentType] — Production and trading document categories.
enum DomainDocumentType {
  slip,       // Production Slip (O3, O4, etc)
  invoice,    // Sales Invoice (S1)
  purchase,   // Purchase Bill (P2, P11)
  order,      // Sales Order (O1)
  challan,    // Delivery Challan
  mending,    // Mending/Repair
}

/// [DomainProductionStage] — Mapping for the EMPIRE series flow.
enum DomainProductionStage {
  multiCutting('O3'),
  workInHouse('O4'),
  dispatchStitching('O5'),
  receiveStitching('O6'),
  dispatchDiamond('O7'),
  receiveDiamond('O8'),
  dispatchEmb('O9'),
  receiveEmb('O10'),
  dispatchCharak('O11'),
  receiveCharak('O12'),
  readyProduct('O45');

  final String code;
  const DomainProductionStage(this.code);

  static DomainProductionStage? fromCode(String code) {
    for (final stage in DomainProductionStage.values) {
      if (stage.code == code) return stage;
    }
    return null;
  }
}

/// [DomainTaxType] — GST categories for Indian textile compliance.
enum DomainTaxType {
  gst5,
  gst12,
  gst18,
  gst28,
  exempt,
}
