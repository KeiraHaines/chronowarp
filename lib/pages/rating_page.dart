import 'package:chronowarp/models/media_item.dart';
import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  final MediaItem item;
  final void Function(CategoryRating rating) onRated;
  final Color bgPage;
  final Color bgCard;
  final Color bgChip;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textMuted;
  final Color textCard;
  final Color textCardMuted;

  const RatingPage({
    super.key,
    required this.item,
    required this.onRated,
    required this.bgPage,
    required this.bgCard,
    required this.bgChip,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textMuted,
    required this.textCard,
    required this.textCardMuted,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  late Map<String, double?> _ratings;

  double? get _average {
    final filled = _ratings.values.whereType<double>().toList();
    if (filled.isEmpty) return null;
    return filled.reduce((a, b) => a + b) / filled.length;
  }

  @override
  void initState() {
    super.initState();
    final cr = widget.item.categoryRating;
    _ratings = {
      'Story': cr?.story,
      'Acting': cr?.acting,
      'Action': cr?.action,
      'Visuals': cr?.visuals,
      'Sound': cr?.sound,
    };
  }

  @override
  Widget build(BuildContext context) {
    final avg = _average;

    return Scaffold(
      backgroundColor: widget.bgPage,
      body: Stack(
        children: [
          // ── Poster background ─────────────────────────────
          if (widget.item.posterPath != null)
            Positioned.fill(
              child: Image.asset(widget.item.posterPath!, fit: BoxFit.cover),
            ),

          // ── Dark overlay ──────────────────────────────────
          Positioned.fill(
            child: Container(
              color: widget.bgPage.withValues(
                alpha: widget.item.posterPath != null ? 0.82 : 1.0,
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button ─────────────────────────────
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: widget.textMuted),
                    style: IconButton.styleFrom(
                      backgroundColor: widget.bgCard.withValues(alpha: 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Title + year ────────────────────────────
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: widget.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.item.year}',
                    style: TextStyle(fontSize: 13, color: widget.textMuted),
                  ),
                  const SizedBox(height: 32),

                  // ── Average score card ──────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: widget.bgCard.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          avg != null ? avg.toStringAsFixed(1) : '—',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: avg != null
                                ? widget.accentSecondary
                                : widget.textMuted,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'out of 10',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.textMuted,
                          ),
                        ),
                        if (avg != null) ...[
                          const SizedBox(height: 12),
                          _buildStarDisplay(avg),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Per-factor rating rows ──────────────────
                  ..._ratings.entries.map(
                    (entry) => _buildFactorRow(entry.key, entry.value),
                  ),
                  const SizedBox(height: 32),

                  // ── Save button ─────────────────────────────
                  if (avg != null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          widget.onRated(
                            CategoryRating(
                              story: _ratings['Story'],
                              acting: _ratings['Acting'],
                              action: _ratings['Action'],
                              visuals: _ratings['Visuals'],
                              sound: _ratings['Sound'],
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.accentPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save rating — ${avg.toStringAsFixed(1)}/10',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorRow(String label, double? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: widget.bgCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.textCard,
                ),
              ),
              Text(
                value != null ? '${value.toInt()}/10' : 'Not rated',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: value != null
                      ? widget.accentSecondary
                      : widget.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (i) {
              final starValue = (i + 1).toDouble();
              final filled = value != null && starValue <= value;
              return GestureDetector(
                onTap: () => setState(() => _ratings[label] = starValue),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 28,
                  color: filled ? widget.accentSecondary : widget.bgChip,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStarDisplay(double avg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (i) {
        final filled = (i + 1) <= avg.round();
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 20,
          color: filled ? widget.accentSecondary : widget.bgChip,
        );
      }),
    );
  }
}
