import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/production/purchase_bills/purchase_bill_category.dart';

class PurchaseBillsCategorySelect extends StatelessWidget {
  final PurchaseBillCategory selectedCategory;
  final Map<PurchaseBillCategory, int> categoryCounts;
  final ValueChanged<PurchaseBillCategory> onCategoryChanged;

  const PurchaseBillsCategorySelect({
    super.key,
    required this.selectedCategory,
    required this.categoryCounts,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final padSm = theme.density.baseContainerPadding * theme.scaling * shad.padSm;
    final selectedCount = categoryCounts[selectedCategory] ?? 0;

    return Builder(
      builder: (context) {
        return shad.OutlineButton(
          onPressed: () {
            shad.showOverlay(
              context,
              shad.PopoverConfiguration(
                alignment: Alignment.bottomLeft,
                offset: Offset(0, 6 * theme.scaling),
                builder: (context) => shad.ModalContainer(
                  child: SizedBox(
                    width: 230 * theme.scaling,
                    child: Padding(
                      padding: EdgeInsets.all(padSm),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Select Category',
                            style: theme.typography.xSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.mutedForeground,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const shad.DensityGap(shad.gapSm),
                          const shad.Divider(),
                          const shad.DensityGap(shad.gapSm),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 320 * theme.scaling),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: PurchaseBillCategory.values.map((cat) {
                                  final count = categoryCounts[cat] ?? 0;
                                  final isSelected = cat == selectedCategory;
                                  return shad.Button.ghost(
                                    onPressed: () {
                                      shad.closeOverlay(context);
                                      onCategoryChanged(cat);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          cat.icon,
                                          size: 14 * theme.scaling,
                                          color: isSelected ? colors.primary : colors.mutedForeground,
                                        ),
                                        const shad.DensityGap(shad.gapSm),
                                        Expanded(
                                          child: Text(
                                            cat.label,
                                            style: theme.typography.textSmall.copyWith(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? colors.primary : colors.foreground,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const shad.DensityGap(shad.gapSm),
                                        isSelected
                                            ? shad.PrimaryBadge(
                                                child: Text(
                                                  count.toString(),
                                                  style: theme.typography.xSmall.copyWith(
                                                    fontSize: 10 * theme.scaling,
                                                  ),
                                                ),
                                              )
                                            : shad.OutlineBadge(
                                                child: Text(
                                                  count.toString(),
                                                  style: theme.typography.xSmall.copyWith(
                                                    fontSize: 10 * theme.scaling,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selectedCategory.icon, size: 16 * theme.scaling, color: colors.primary),
              const shad.DensityGap(shad.gapSm),
              Text(
                selectedCategory.label,
                style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const shad.DensityGap(shad.gapSm),
              shad.SecondaryBadge(
                child: Text(
                  selectedCount.toString(),
                  style: theme.typography.xSmall.copyWith(
                    fontSize: 10 * theme.scaling,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapSm),
              Icon(shad.LucideIcons.chevronDown, size: 14 * theme.scaling, color: colors.mutedForeground),
            ],
          ),
        );
      },
    );
  }
}
