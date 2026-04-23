import 'package:flutter/material.dart';
import '../models/cost_breakdown.dart';

/// Cost Breakdown Pie Chart Widget with Detailed Expense Analysis
/// 
/// Shows the distribution of trek costs across:
/// - Lodging (accommodation)
/// - Meals
/// - Local Transport
/// - Permits
/// - Guide services
/// - Porter services
/// - Optional detours
/// 
/// Includes per-person breakdown and daily averages
class CostBreakdownChart extends StatefulWidget {
  final CostBreakdown costBreakdown;
  final VoidCallback? onRefresh;
  final String currencyCode;

  const CostBreakdownChart({
    super.key,
    required this.costBreakdown,
    this.onRefresh,
    this.currencyCode = 'NPR',
  });

  @override
  State<CostBreakdownChart> createState() => _CostBreakdownChartState();
}

class _CostBreakdownChartState extends State<CostBreakdownChart> {
  int? _selectedSegment;

  static const double _usdToNpr = 133.0;

  bool get _showNpr => widget.currencyCode.toUpperCase() == 'NPR';

  double _convert(double usdAmount) {
    return _showNpr ? usdAmount * _usdToNpr : usdAmount;
  }

  String _formatAmount(double usdAmount) {
    final converted = _convert(usdAmount);
    final symbol = _showNpr ? 'Rs ' : '\$';
    final decimals = _showNpr ? 0 : 2;
    return '$symbol${converted.toStringAsFixed(decimals)}';
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.costBreakdown;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cost Estimation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: widget.onRefresh,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailedExpensesList(breakdown),
            const SizedBox(height: 12),
            _buildMinimumBudgetSummary(breakdown),
            const SizedBox(height: 12),
            _buildPerPersonSummary(breakdown),
          ],
        ),
      ),
    );
  }

  /// Build detailed expense breakdown by category
  Widget _buildDetailedExpensesList(CostBreakdown breakdown) {
    final expenses = [
      ('Hotel', breakdown.detailedExpenses['lodging'] ?? 0.0),
      ('Food', breakdown.detailedExpenses['meals'] ?? 0.0),
      ('Bus Rent', breakdown.detailedExpenses['local_transport'] ?? 0.0),
      ('Permits', breakdown.detailedExpenses['permits'] ?? 0.0),
      if ((breakdown.detailedExpenses['guide'] ?? 0.0) > 0)
        ('Guide', breakdown.detailedExpenses['guide'] ?? 0.0),
      if ((breakdown.detailedExpenses['porter'] ?? 0.0) > 0)
        ('Porter', breakdown.detailedExpenses['porter'] ?? 0.0),
      if ((breakdown.detailedExpenses['detours'] ?? 0.0) > 0)
        ('Detours', breakdown.detailedExpenses['detours'] ?? 0.0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Expenses',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...expenses.map((expense) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(expense.$1, style: const TextStyle(fontSize: 14)),
                Text(
                  _formatAmount(expense.$2),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMinimumBudgetSummary(CostBreakdown breakdown) {
    final lodging = (breakdown.detailedExpenses['lodging'] ?? 0.0) as double;
    final meals = (breakdown.detailedExpenses['meals'] ?? 0.0) as double;
    final transport = (breakdown.detailedExpenses['local_transport'] ?? 0.0) as double;
    final permits = (breakdown.detailedExpenses['permits'] ?? 0.0) as double;
    final minimumBudget = lodging + meals + transport + permits;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minimum Budget (Essential)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Food + Hotel + Bus + Permits',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(minimumBudget),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Per-person and summary info
  Widget _buildPerPersonSummary(CostBreakdown breakdown) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Trek Cost',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatAmount(breakdown.totalCost),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Per Person Estimate',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                _formatAmount(breakdown.totalCost / breakdown.numberOfPeople),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
