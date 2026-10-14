import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/recommendation_service.dart';
import '../theme/app_colors.dart';

/// Presentation-ready “Why we recommend this house” card.
class AiExplanationCard extends StatelessWidget {
  final AiMatchResult match;
  final bool showBreakdown;

  const AiExplanationCard({
    super.key,
    required this.match,
    this.showBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    final matched = match.matchedReasons;
    final missed = match.reasons.where((r) => !r.matched).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.chartBlue.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why we recommend this house',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'AI compatibility score: ${match.percent}%',
                      style: const TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (matched.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...matched.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.text,
                        style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (missed.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...missed.take(3).map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.circle, size: 16, color: AppColors.inkMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.text,
                        style: const TextStyle(
                          color: AppColors.inkMuted,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (showBreakdown) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Score breakdown',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            _WeightBar(label: 'Budget (25%)', value: match.budgetScore, color: AppColors.primary),
            _WeightBar(label: 'Location / Distance (20%)', value: match.locationScore, color: AppColors.chartBlue),
            _WeightBar(label: 'House type (15%)', value: match.houseTypeScore, color: AppColors.accent),
            _WeightBar(label: 'Bedrooms (15%)', value: match.bedroomScore, color: AppColors.warning),
            _WeightBar(label: 'Amenities (15%)', value: match.amenitiesScore, color: AppColors.success),
            _WeightBar(label: 'User behaviour (10%)', value: match.behaviourScore, color: AppColors.primaryDark),
          ],
        ],
      ),
    );
  }
}

class _WeightBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _WeightBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
