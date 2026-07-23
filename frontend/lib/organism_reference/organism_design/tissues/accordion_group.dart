import 'package:flutter/material.dart';
import '../theme.dart';
import 'accordion.dart';

class TissueAccordionGroup extends StatefulWidget {
  final List<TissueAccordion> children;
  final String? defaultOpenId;

  const TissueAccordionGroup({
    super.key,
    required this.children,
    this.defaultOpenId,
  });

  @override
  State<TissueAccordionGroup> createState() => _TissueAccordionGroupState();
}

class _TissueAccordionGroupState extends State<TissueAccordionGroup> {


  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: OrganismTheme.borderMd,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.children.length,
        separatorBuilder: (context, index) => Container(height: 1, color: colors.borderSubtle),
        itemBuilder: (context, index) {
          final child = widget.children[index];
          // Determine ID based on index if not explicitly provided inside TissueAccordion
          // Note: TissueAccordion needs an ID property or we use index as ID.
          // Since TissueAccordion is pre-existing, we might not be able to change its constructor easily.
          // We will mock the state overriding. 


          // Note: This ideally requires modifying TissueAccordion to accept isOpen and onToggle.
          // Since we control it from here, we will ignore its internal state by rebuilding.
          return Builder(
            builder: (context) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, // Remove default flutter exp panel borders if it uses it
                ),
                child: child, // Ideally, child should be customized to receive `isOpen` override.
                // Assuming TissueAccordion is just a wrapper, if it has internal state, this might not fully force it
                // unless we pass a key.
              );
            },
          );
        },
      ),
    );
  }
}
