import 'package:flutter/material.dart';
import '../../../../../models/production/model_cutting.dart';
import '../../../../../services/production/service_cutting.dart';
import '../../../../../organism_design/index.dart';

/// [CuttingFormState] — Scoped state controller for Cutting Batch Creation/Edit overlay.
class CuttingFormState extends ChangeNotifier {
  final CuttingService _service = CuttingService();

  DateTime batchDate = DateTime.now();
  List<String> selectedQualities = [];
  String? selectedMill;
  double cutLength = 5.20; // default 5.20
  String groupBy = 'NONE'; // NONE, DATE, DESNO
  Map<String, bool> expandedGroups = {};
  int? editingMultiVno;

  List<String> qualities = [];
  List<String> mills = [];
  List<Map<String, dynamic>> availableTakas = [];
  List<Map<String, dynamic>> selectedTakaRows = [];
  bool loadingAvailable = false;
  bool isSaving = false;

  // Controllers
  final TextEditingController freshPcsController = TextEditingController(text: '0');
  final TextEditingController secondPcsController = TextEditingController(text: '0');
  final TextEditingController sareeWtController = TextEditingController(text: '400'); // default 400 grams
  final TextEditingController fentWtController = TextEditingController(text: '0.00');
  final TextEditingController screenController = TextEditingController();
  final TextEditingController picController = TextEditingController();
  final TextEditingController startMultiVnoController = TextEditingController();

  CuttingFormState() {
    freshPcsController.addListener(_onTextChanged);
    secondPcsController.addListener(_onTextChanged);
    sareeWtController.addListener(_onTextChanged);
    fentWtController.addListener(_onTextChanged);
    startMultiVnoController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    freshPcsController.removeListener(_onTextChanged);
    secondPcsController.removeListener(_onTextChanged);
    sareeWtController.removeListener(_onTextChanged);
    fentWtController.removeListener(_onTextChanged);
    startMultiVnoController.removeListener(_onTextChanged);

    freshPcsController.dispose();
    secondPcsController.dispose();
    sareeWtController.dispose();
    fentWtController.dispose();
    screenController.dispose();
    picController.dispose();
    startMultiVnoController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    notifyListeners();
  }

  /// Initialize state — handles both Create and Edit flows
  Future<void> initialize({
    CuttingBatchSummaryModel? editBatch,
    List<CuttingCardModel>? siblingCards,
  }) async {
    // 1. Load initial qualities and mills list
    qualities = await _service.getUniqueQualities();
    mills = await _service.getUniqueMills();

    if (editBatch != null) {
      editingMultiVno = editBatch.multiVno;
      selectedQualities = editBatch.greyQual.split(', ').map((q) => q.trim()).toList();
      selectedMill = editBatch.mill;
      batchDate = editBatch.cutDate;
      cutLength = editBatch.cutLength;

      freshPcsController.text = editBatch.totalFreshPcs.toString();
      secondPcsController.text = editBatch.totalSecondPcs.toString();
      sareeWtController.text = (editBatch.avgWt * 1000).toInt().toString(); // convert kg to grams
      fentWtController.text = (editBatch.totalFentWt * 1000).toStringAsFixed(2); // convert kg to grams
      screenController.text = editBatch.screen ?? '';
      picController.text = editBatch.sbCardPic ?? '';
      startMultiVnoController.text = editBatch.multiVno.toString();

      // If we are editing, fetch the available takas including current siblings
      await loadAvailableTakas(siblingCards: siblingCards);
    } else {
      editingMultiVno = null;
      selectedQualities = [];
      selectedMill = null;
      availableTakas = [];
      selectedTakaRows = [];
      batchDate = DateTime.now();
      cutLength = 5.20;
      groupBy = 'NONE';
      expandedGroups = {};

      freshPcsController.text = '0';
      secondPcsController.text = '0';
      sareeWtController.text = '400';
      fentWtController.text = '0.00';
      screenController.clear();
      picController.clear();
      await loadNextMultiVno();
    }
    notifyListeners();
  }

  Future<void> loadNextMultiVno() async {
    final nextNo = await _service.getNextMultiVno();
    startMultiVnoController.text = nextNo.toString();
    notifyListeners();
  }

  Future<void> loadAvailableTakas({List<CuttingCardModel>? siblingCards}) async {
    if (selectedQualities.isEmpty || selectedMill == null) return;
    loadingAvailable = true;
    notifyListeners();

    final list = await _service.getAvailableTakas(
      greyQuals: selectedQualities,
      mill: selectedMill!,
      editMultiVno: editingMultiVno,
    );

    availableTakas = list;
    if (editingMultiVno != null && selectedTakaRows.isEmpty && siblingCards != null) {
      final siblingCardNos = siblingCards.map((c) => c.reccardno).toSet();
      selectedTakaRows = availableTakas.where((row) {
        final cardNo = (row['CARDNO'] as num?)?.toInt() ?? 0;
        return siblingCardNos.contains(cardNo);
      }).toList();
    }

    loadingAvailable = false;
    notifyListeners();
  }

  Future<void> onQualitiesChanged(List<String> qList) async {
    selectedQualities = qList;
    availableTakas = [];
    selectedTakaRows = [];
    groupBy = 'NONE';
    expandedGroups = {};
    notifyListeners();

    if (qList.isNotEmpty) {
      final Set<String> allMills = {};
      for (final q in qList) {
        final millsForQ = await _service.getUniqueMillsForQuality(q);
        allMills.addAll(millsForQ);
      }
      mills = allMills.toList();
    } else {
      mills = await _service.getUniqueMills();
    }

    await loadAvailableTakas();
    notifyListeners();
  }

  Future<void> onMillChanged(String? m) async {
    selectedMill = m;
    availableTakas = [];
    selectedTakaRows = [];
    groupBy = 'NONE';
    expandedGroups = {};
    notifyListeners();

    if (selectedQualities.isNotEmpty && m != null) {
      await loadAvailableTakas();
    }
    notifyListeners();
  }

  void updateCutLength(double length) {
    cutLength = length;
    notifyListeners();
  }

  void updateGroupBy(String group) {
    groupBy = group;
    notifyListeners();
  }

  void toggleGroupExpansion(String groupName) {
    expandedGroups[groupName] = !(expandedGroups[groupName] ?? true);
    notifyListeners();
  }

  void selectTakaGroup(List<Map<String, dynamic>> groupItems, bool checked) {
    if (checked) {
      for (var item in groupItems) {
        final exists = selectedTakaRows.any((sel) => sel['CARDNO'] == item['CARDNO']);
        if (!exists) {
          selectedTakaRows.add(item);
        }
      }
    } else {
      final groupCardNos = groupItems.map((item) => item['CARDNO']).toSet();
      selectedTakaRows.removeWhere((sel) => groupCardNos.contains(sel['CARDNO']));
    }
    notifyListeners();
  }

  void toggleTakaRow(Map<String, dynamic> card, int cardNo, bool isChecked) {
    if (isChecked) {
      selectedTakaRows.removeWhere((row) => (row['CARDNO'] as num?)?.toInt() == cardNo);
    } else {
      selectedTakaRows.add(card);
    }
    notifyListeners();
  }

  // --- LIVE MATH CALCULATORS ---

  double get totalReceivedMts => selectedTakaRows.fold(
        0.0,
        (sum, row) => sum + ((row['RMTS'] as num?)?.toDouble() ?? (row['PMTS'] as num?)?.toDouble() ?? (row['WMTS'] as num?)?.toDouble() ?? 0.0),
      );

  double get totalInputMts => selectedTakaRows.fold(
        0.0,
        (sum, row) => sum + ((row['WMTS'] as num?)?.toDouble() ?? 0.0),
      );

  double get shortagePct => totalInputMts > 0 ? (totalReceivedMts / totalInputMts * 100) : 0.0;

  double get avgWtGrams => double.tryParse(sareeWtController.text) ?? 400.0;
  double get totalFreshPcs => double.tryParse(freshPcsController.text) ?? 0.0;
  double get totalSecondPcs => double.tryParse(secondPcsController.text) ?? 0.0;
  double get totalFentWt => double.tryParse(fentWtController.text) ?? 0.0;

  double get calculatedFreshMts => totalFreshPcs * cutLength;
  double get freshPct => totalReceivedMts > 0 ? (calculatedFreshMts / totalReceivedMts * 100) : 0.0;

  double get calculatedSecondMts => totalSecondPcs * 5.0;
  double get secondPct => totalReceivedMts > 0 ? (calculatedSecondMts / totalReceivedMts * 100) : 0.0;

  double get calculatedFentMts => avgWtGrams > 0 ? (totalFentWt / avgWtGrams) * cutLength : 0.0;
  double get fentPct => totalReceivedMts > 0 ? (calculatedFentMts / totalReceivedMts * 100) : 0.0;

  int get rollCount => selectedTakaRows.length;

  /// Trigger the save batch action
  Future<Map<String, dynamic>?> saveBatch(BuildContext context) async {
    if (selectedQualities.isEmpty || selectedMill == null) {
      PlasmaToastManager.instance.show(context, 'Please select at least one Quality and a Mill first.', variant: CellBadgeVariant.warning);
      return null;
    }
    if (selectedTakaRows.isEmpty) {
      PlasmaToastManager.instance.show(context, 'Please select at least one Taka card.', variant: CellBadgeVariant.warning);
      return null;
    }

    final totalFresh = double.tryParse(freshPcsController.text) ?? 0.0;
    if (totalFresh <= 0) {
      PlasmaToastManager.instance.show(context, 'Please enter a valid fresh piece count.', variant: CellBadgeVariant.warning);
      return null;
    }

    isSaving = true;
    notifyListeners();

    try {
      final payload = {
        'mill': selectedMill,
        'greyqual': selectedQualities.join(', '),
        'cut_date': batchDate.toIso8601String(),
        'cut_length': cutLength,
        'avg_wt': avgWtGrams / 1000.0, // convert g to kg
        'total_fresh_pcs': totalFresh.toInt(),
        'total_second_pcs': (double.tryParse(secondPcsController.text) ?? 0.0).toInt(),
        'total_fent_wt': (double.tryParse(fentWtController.text) ?? 0.0) / 1000.0, // convert grams back to kg
        'job_type': 'Standard Cutting', // default to standard cutting
        'value_addition': 'None',
        'screen': screenController.text.isNotEmpty ? screenController.text : null,
        'sb_cardpic': picController.text.isNotEmpty ? picController.text : null,
        'selected_cards': selectedTakaRows,
        'start_multi_vno': int.tryParse(startMultiVnoController.text) ?? 0,
        'edit_multi_vno': editingMultiVno,
      };

      PlasmaToastManager.instance.show(context, 'Saving cutting batch transaction...', variant: CellBadgeVariant.primary);

      final result = await _service.saveCuttingBatch(payload);

      isSaving = false;
      notifyListeners();
      return result;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Inherited widget lookup helper
  static CuttingFormState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CuttingFormStateProvider>();
    if (provider == null || provider.notifier == null) {
      throw FlutterError('CuttingFormState.of() called with a context that does not contain a CuttingFormStateProvider.');
    }
    return provider.notifier!;
  }
}

/// [CuttingFormStateProvider] — Concrete InheritedNotifier for CuttingFormState.
class CuttingFormStateProvider extends InheritedNotifier<CuttingFormState> {
  const CuttingFormStateProvider({
    super.key,
    required super.notifier,
    required super.child,
  });
}
