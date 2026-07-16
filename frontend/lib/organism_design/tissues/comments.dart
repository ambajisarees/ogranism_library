import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells.dart';

class CommentData {
  final String authorName;
  final String content;
  final String timestamp;
  final String? initial;

  const CommentData({
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.initial,
  });
}

/// [TissueComments] — Inline threaded history box
class TissueComments extends StatelessWidget {
  final List<CommentData> comments;
  final void Function(String)? onCommentSubmitted;

  const TissueComments({
    super.key,
    required this.comments,
    this.onCommentSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return CellBox(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Annotations',
            style: OrganismTheme.labelLarge(context).copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: OrganismTheme.spacingMd),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingLg),
              child: Center(
                child: Text('No comments yet.', style: OrganismTheme.bodyMedium(context)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: OrganismTheme.spacingLg),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CellAvatar(
                      name: comment.initial ?? comment.authorName.substring(0, 1),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.authorName,
                                style: OrganismTheme.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(comment.timestamp, style: OrganismTheme.labelMedium(context)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: colors.surfaceHover,
                              borderRadius: OrganismTheme.borderSm,
                            ),
                            child: Text(comment.content, style: OrganismTheme.bodyMedium(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          if (onCommentSubmitted != null) ...[
            const SizedBox(height: OrganismTheme.spacingLg),
            const CellDivider(),
            const SizedBox(height: OrganismTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  child: CellInput(
                    placeholder: 'Write an annotation...',
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        onCommentSubmitted!(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
