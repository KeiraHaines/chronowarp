import 'dart:async';
import 'package:flutter/material.dart';
import '../models/media_item.dart';

Future<void> showMediaRatingSheet({
  required BuildContext context,
  required String title,
  CategoryRating? initialRating,
  required FutureOr<void> Function(CategoryRating) onSave,
  required Color bgCard,
  required Color bgChip,
  required Color textCard,
  required Color textCardMuted,
  required Color accentPrimary,
  required Color accentSecondary,
}) {
  final ratings = <String, double?>{
    'Story': initialRating?.story,
    'Acting': initialRating?.acting,
    'Action': initialRating?.action,
    'Visuals': initialRating?.visuals,
    'Sound': initialRating?.sound,
  };

  Widget sheetStarRow(
    String label,
    double? value,
    void Function(double) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textCard,
                ),
              ),
              Text(
                value != null ? '${value.toInt()}/10' : 'Not rated',
                style: TextStyle(
                  fontSize: 12,
                  color: value != null ? accentSecondary : textCardMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (i) {
              final v = (i + 1).toDouble();
              final filled = value != null && v <= value;
              return GestureDetector(
                onTap: () => onTap(v),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 26,
                  color: filled ? accentSecondary : bgChip,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SingleChildScrollView(
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          double? avg() {
            final filled = ratings.values.whereType<double>().toList();
            if (filled.isEmpty) return null;
            return filled.reduce((a, b) => a + b) / filled.length;
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textCard,
                  ),
                ),
                const SizedBox(height: 20),
                ...ratings.entries.map(
                  (entry) => sheetStarRow(
                    entry.key,
                    entry.value,
                    (val) => setSheetState(() => ratings[entry.key] = val),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: avg() == null
                        ? null
                        : () async {
                            await onSave(
                              CategoryRating(
                                story: ratings['Story'],
                                acting: ratings['Acting'],
                                action: ratings['Action'],
                                visuals: ratings['Visuals'],
                                sound: ratings['Sound'],
                              ),
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: accentPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      avg() != null
                          ? 'Save — ${avg()!.toStringAsFixed(1)}/10'
                          : 'Rate to save',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
