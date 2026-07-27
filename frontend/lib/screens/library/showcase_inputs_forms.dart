import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseInputsForms extends StatefulWidget {
  const ShowcaseInputsForms({super.key});

  @override
  State<ShowcaseInputsForms> createState() => _ShowcaseInputsFormsState();
}

class _ShowcaseInputsFormsState extends State<ShowcaseInputsForms> {
  final TextEditingController _stdController = TextEditingController(text: 'AMBAJI SAREES');
  final TextEditingController _errController = TextEditingController(text: 'INVALID_GST_NUMBER');
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController(text: '24AAAAA0000A1Z5');
  final TextEditingController _notesController = TextEditingController(text: 'Special embroidery processing required for design #4089.');
  
  String? _selectedCity = 'surat';
  final DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _chips = ['Silk', 'Georgette', 'Chiffon', 'Organza'];
  Color _selectedColor = const Color(0xFFE11D48);

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text('Form Inputs & Text Entry', style: theme.typography.h2),
          Text(
            'Form inputs formatted in native ERP width boundaries (220px–320px) with icons, clear actions, pickers, and masked validation.',
            style: theme.typography.textMuted,
          ),
          const shad.DensityGap(shad.gapLg),

          // 1. Text Inputs Matrix (220px-320px Width Wrappers)
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Text Inputs & Field States (ERP Width Scoped)', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 20 * theme.scaling,
                  runSpacing: 16 * theme.scaling,
                  children: [
                    // Standard Input (240px)
                    _buildInputWrapper(
                      label: 'Party Name (Standard)',
                      width: 240,
                      child: shad.TextField(
                        placeholder: const Text('Enter party name...'),
                      ),
                    ),
                    // Filled Input (240px)
                    _buildInputWrapper(
                      label: 'Company Title (Filled)',
                      width: 240,
                      child: shad.TextField(
                        controller: _stdController,
                      ),
                    ),
                    // Validation Error Input (240px)
                    _buildInputWrapper(
                      label: 'GSTIN (Error State)',
                      width: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          shad.TextField(
                            controller: _errController,
                            features: [
                              shad.InputFeature.trailing(
                                Icon(shad.LucideIcons.circleAlert, color: colors.destructive, size: 16),
                              ),
                            ],
                          ),
                          const shad.DensityGap(shad.gapSm),
                          Text('Invalid GSTIN format sequence', style: theme.typography.xSmall.copyWith(color: colors.destructive)),
                        ],
                      ),
                    ),
                    // Disabled Input (240px)
                    _buildInputWrapper(
                      label: 'Voucher No. (Disabled)',
                      width: 240,
                      child: const shad.TextField(
                        enabled: false,
                        placeholder: Text('VNO #10482 (Read-only)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. Inputs with Icons & Actions (280px-320px Width Wrappers)
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inputs with Prefix/Suffix Icons & Action Triggers', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 20 * theme.scaling,
                  runSpacing: 16 * theme.scaling,
                  children: [
                    // Search Input with Clear Action
                    _buildInputWrapper(
                      label: 'Search Item / Design',
                      width: 280,
                      child: shad.TextField(
                        controller: _searchController,
                        placeholder: const Text('Search catalog...'),
                        features: [
                          shad.InputFeature.leading(
                            Icon(shad.LucideIcons.search, size: 16, color: colors.mutedForeground),
                          ),
                          shad.InputFeature.trailing(
                            shad.IconButton.ghost(
                              density: shad.ButtonDensity.iconDense,
                              size: shad.ButtonSize.small,
                              icon: const Icon(shad.LucideIcons.x, size: 14),
                              onPressed: () => _searchController.clear(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Currency Input with ₹ Prefix
                    _buildInputWrapper(
                      label: 'Rate / Price per Mtr',
                      width: 260,
                      child: shad.TextField(
                        placeholder: const Text('0.00'),
                        features: [
                          const shad.InputFeature.leading(
                            Text('₹', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          shad.InputFeature.trailing(
                            Text('/ mtr', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                          ),
                        ],
                      ),
                    ),
                    // Masked GSTIN Formatted Input
                    _buildInputWrapper(
                      label: 'Formated GSTIN Code',
                      width: 280,
                      child: shad.TextField(
                        controller: _gstinController,
                        features: [
                          shad.InputFeature.leading(
                            Icon(shad.LucideIcons.shieldCheck, size: 16, color: colors.primary),
                          ),
                        ],
                      ),
                    ),
                    // Phone Input with Country Code
                    _buildInputWrapper(
                      label: 'WhatsApp Mobile Number',
                      width: 280,
                      child: shad.TextField(
                        placeholder: const Text('98765 43210'),
                        features: [
                          const shad.InputFeature.leading(
                            Text('+91', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          shad.InputFeature.trailing(
                            Icon(shad.LucideIcons.phone, size: 14, color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 3. Dropdowns, Select & Pickers (240px-300px)
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dropdown Select & Autocomplete Controls', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 20 * theme.scaling,
                  runSpacing: 16 * theme.scaling,
                  children: [
                    // Station Select
                    _buildInputWrapper(
                      label: 'Station / City Select',
                      width: 240,
                      child: Builder(
                        builder: (context) {
                          return shad.OutlineButton(
                            onPressed: () {
                              shad.showOverlay(
                                context,
                                shad.PopoverConfiguration(
                                  alignment: Alignment.bottomLeft,
                                  offset: const Offset(0, 4),
                                  builder: (context) => shad.ModalContainer(
                                    child: SizedBox(
                                      width: 220,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: ['Surat (HQ)', 'Ahmedabad', 'Mumbai', 'Jaipur', 'Delhi'].map((city) {
                                          return shad.Button.ghost(
                                            onPressed: () {
                                              shad.closeOverlay(context);
                                              setState(() => _selectedCity = city.toLowerCase());
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(city),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(_selectedCity != null ? _selectedCity!.toUpperCase() : 'Select City'),
                                const Spacer(),
                                Icon(shad.LucideIcons.chevronDown, size: 14, color: colors.mutedForeground),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Date Field
                    _buildInputWrapper(
                      label: 'Delivery Date',
                      width: 240,
                      child: shad.TextField(
                        placeholder: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        features: [
                          shad.InputFeature.trailing(
                            Icon(shad.LucideIcons.calendar, size: 16, color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    // Time Field
                    _buildInputWrapper(
                      label: 'Dispatch Slot Time',
                      width: 220,
                      child: shad.TextField(
                        placeholder: Text('${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} IST'),
                        features: [
                          shad.InputFeature.trailing(
                            Icon(shad.LucideIcons.clock, size: 16, color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    // OTP Pin Field
                    _buildInputWrapper(
                      label: 'Secure PIN Code (OTP)',
                      width: 240,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Container(
                            width: 44,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            child: const shad.TextField(
                              textAlign: TextAlign.center,
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
          const shad.DensityGap(shad.gapLg),

          // 4. Advanced Form Elements (Chip Input, Multiline TextArea, Color Picker)
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Advanced Form Inputs (Tags, Remarks & Color Picker)', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Multiline TextArea
                    Expanded(
                      flex: 2,
                      child: _buildInputWrapper(
                        label: 'Voucher Notes & Terms',
                        width: double.infinity,
                        child: shad.TextArea(
                          controller: _notesController,
                          maxLines: 4,
                        ),
                      ),
                    ),
                    const shad.DensityGap(shad.gapLg),
                    // Chips & Color Picker
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputWrapper(
                            label: 'Fabric Category Tags',
                            width: double.infinity,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._chips.map((tag) => shad.SecondaryBadge(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(tag),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () => setState(() => _chips.remove(tag)),
                                            child: const Icon(shad.LucideIcons.x, size: 12),
                                          ),
                                        ],
                                      ),
                                    )),
                                shad.OutlineButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () {
                                    setState(() => _chips.add('Tag #${_chips.length + 1}'));
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(shad.LucideIcons.plus, size: 12),
                                      SizedBox(width: 4),
                                      Text('Add Tag'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const shad.DensityGap(shad.gapMd),
                          // Color Selector
                          Row(
                            children: [
                              Text('Design Color Shade: ', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colors.border),
                                ),
                              ),
                              const shad.DensityGap(shad.gapMd),
                              shad.OutlineButton(
                                size: shad.ButtonSize.small,
                                onPressed: () {
                                  // Cycle preset colors
                                  final colorsList = [
                                    const Color(0xFFE11D48),
                                    const Color(0xFF2563EB),
                                    const Color(0xFF059669),
                                    const Color(0xFFD97706),
                                    const Color(0xFF7C3AED),
                                  ];
                                  setState(() {
                                    final nextIdx = (colorsList.indexOf(_selectedColor) + 1) % colorsList.length;
                                    _selectedColor = colorsList[nextIdx];
                                  });
                                },
                                child: const Text('Change Shade'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputWrapper({
    required String label,
    required double width,
    required Widget child,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.mutedForeground,
            ),
          ),
          const shad.DensityGap(shad.gapSm),
          child,
        ],
      ),
    );
  }
}
