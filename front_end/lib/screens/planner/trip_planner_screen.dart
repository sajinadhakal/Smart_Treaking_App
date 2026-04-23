import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/trek_itinerary.dart';
import '../../providers/itinerary_provider.dart';
import '../../providers/mountain_mode_provider.dart';
import '../../widgets/cost_breakdown_chart.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  static const int _minDaysOffset = 2;
  static const int _maxDaysOffset = 5;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _peopleController =
      TextEditingController(text: '1');
  final TextEditingController _portersController =
      TextEditingController(text: '0');

  String _nationality = 'NEPALI';
  bool _includeGuide = true;
  bool _includePorter = false;

  static const double _usdToNpr = 133.0;
  static const double _maxPerPersonBudgetNpr = 20000.0;

  // Show Rupees to all users for simpler budgeting.
  bool get _showNprCurrency => true;

  double _displayToUsd(double amount) {
    if (_showNprCurrency) {
      return amount / _usdToNpr;
    }
    return amount;
  }

  double _usdToDisplay(double amount) {
    if (_showNprCurrency) {
      return amount * _usdToNpr;
    }
    return amount;
  }

  String _priceLabel(double usdAmount, {int usdDecimals = 2}) {
    if (_showNprCurrency) {
      return 'Rs ${_usdToDisplay(usdAmount).toStringAsFixed(0)}';
    }
    return 'USD ${usdAmount.toStringAsFixed(usdDecimals)}';
  }

  int _currentPeopleCount() {
    final parsed = int.tryParse(_peopleController.text.trim());
    if (parsed == null || parsed < 1) {
      return 1;
    }
    return parsed;
  }

  double _maxAllowedBudgetNpr() {
    return _maxPerPersonBudgetNpr * _currentPeopleCount();
  }

  @override
  void initState() {
    super.initState();
    _budgetController.text = _maxPerPersonBudgetNpr.toStringAsFixed(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItineraryProvider>().bootstrapPlanner();
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _daysController.dispose();
    _peopleController.dispose();
    _portersController.dispose();
    super.dispose();
  }

  String? _validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      // Budget is only mandatory for optimize action.
      return null;
    }

    final doubleValue = double.tryParse(value.trim());
    if (doubleValue == null) {
      return 'Maximum Budget must be numeric';
    }

    if (doubleValue < 0) {
      return 'Maximum Budget cannot be negative';
    }

    final budgetInUsd = _displayToUsd(doubleValue);
    if (budgetInUsd < 100) {
      return _showNprCurrency
          ? 'Minimum allowed budget is Rs ${(100 * _usdToNpr).toStringAsFixed(0)}'
          : 'Minimum allowed budget is 100 USD';
    }

    if (_showNprCurrency && doubleValue > _maxAllowedBudgetNpr()) {
      return 'For budget-friendly planning, keep maximum budget up to Rs ${_maxAllowedBudgetNpr().toStringAsFixed(0)} (${_currentPeopleCount()} x Rs ${_maxPerPersonBudgetNpr.toStringAsFixed(0)}).';
    }

    return null;
  }

  String? _validateDays(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Available Days is required';
    }

    final destination = context.read<ItineraryProvider>().selectedDestination;
    if (destination == null) {
      return 'Please select a destination first';
    }

    final intValue = int.tryParse(value.trim());
    if (intValue == null) {
      return 'Available Days must be a whole number';
    }

    if (intValue < 0) {
      return 'Available Days cannot be negative';
    }

    final recommendedDays = destination.durationDays;
    final minAllowedDays = (recommendedDays - _minDaysOffset) < 1
        ? 1
        : (recommendedDays - _minDaysOffset);
    final maxAllowedDays = recommendedDays + _maxDaysOffset;

    if (intValue < minAllowedDays) {
      return 'Selected days are too short for this trek';
    }

    if (intValue > maxAllowedDays) {
      return 'Selected days exceed realistic trekking duration';
    }

    return null;
  }

  String _daysHelperText(ItineraryProvider planner) {
    final destination = planner.selectedDestination;
    if (destination == null) {
      return 'Select a destination to view realistic day range';
    }

    final recommendedDays = destination.durationDays;
    final minAllowedDays = (recommendedDays - _minDaysOffset) < 1
        ? 1
        : (recommendedDays - _minDaysOffset);
    final maxAllowedDays = recommendedDays + _maxDaysOffset;
    return 'Recommended: $recommendedDays days • Allowed: $minAllowedDays-$maxAllowedDays days';
  }

  String? _requiredPositiveInt(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1) {
      return '$label must be at least 1';
    }

    return null;
  }

  Future<void> _previewCost() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final planner = context.read<ItineraryProvider>();

    await planner.calculateCost(
      durationDays: int.parse(_daysController.text.trim()),
      numberOfPeople: int.parse(_peopleController.text.trim()),
      nationality: _nationality,
      includeGuide: _includeGuide,
      includePorter: _includePorter,
      numberOfPorters:
          _includePorter ? int.parse(_portersController.text.trim()) : 0,
    );
  }

  Future<void> _createItinerary() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final planner = context.read<ItineraryProvider>();
    await planner.createItinerary(
      durationDays: int.parse(_daysController.text.trim()),
      numberOfPeople: int.parse(_peopleController.text.trim()),
      nationality: _nationality,
      includeGuide: _includeGuide,
      includePorter: _includePorter,
      numberOfPorters:
          _includePorter ? int.parse(_portersController.text.trim()) : 0,
    );
  }

  Future<void> _optimizeKnapsack() async {
    final budgetText = _budgetController.text.trim();
    if (budgetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _showNprCurrency
                ? 'Maximum Budget (Rs) is required for optimization.'
                : 'Maximum Budget (USD) is required for optimization.',
          ),
        ),
      );
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final enteredBudget = double.parse(budgetText);
    final cappedBudget = enteredBudget > _maxAllowedBudgetNpr()
        ? _maxAllowedBudgetNpr()
        : enteredBudget;

    if (cappedBudget != enteredBudget) {
      _budgetController.text = cappedBudget.toStringAsFixed(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Budget adjusted to Rs ${cappedBudget.toStringAsFixed(0)} to keep Rs ${_maxPerPersonBudgetNpr.toStringAsFixed(0)} per person.',
          ),
        ),
      );
    }

    final budgetUsd = _displayToUsd(cappedBudget);

    FocusScope.of(context).unfocus();
    final planner = context.read<ItineraryProvider>();
    await planner.optimizeWithKnapsack(
      maxBudgetUsd: budgetUsd,
      maxDays: int.parse(_daysController.text.trim()),
      numberOfPeople: int.parse(_peopleController.text.trim()),
      nationality: _nationality,
      includeGuide: _includeGuide,
      includePorter: _includePorter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1024;

    return Consumer<ItineraryProvider>(
      builder: (context, planner, _) {
        final destination = planner.selectedDestination;
        final itinerary = planner.currentItinerary;

        if (planner.error != null && planner.error!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(planner.error!),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Custom Trip Planner'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: planner.isLoading && destination == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: isWide ? 1200 : 720),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isWide ? 560 : double.infinity,
                              child: _buildInputPanel(planner),
                            ),
                            SizedBox(
                              width: isWide ? 560 : double.infinity,
                              child: _buildOutputPanel(planner, itinerary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInputPanel(ItineraryProvider planner) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useStackedFields = constraints.maxWidth < 460;
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dynamic Itinerary Inputs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: planner.selectedDestination?.id,
                    isExpanded: true,
                    items: planner.destinations
                        .map(
                          (destination) => DropdownMenuItem<int>(
                            value: destination.id,
                            child: Text(
                              destination.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) => planner.destinations
                        .map(
                          (destination) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              destination.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Destination'),
                    onChanged: (value) {
                      if (value != null) {
                        planner.selectDestination(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (useStackedFields) ...[
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _showNprCurrency
                            ? 'Max Budget (Rs)'
                            : 'Max Budget (USD)',
                        helperText: _showNprCurrency
                            ? 'Budget limit: Rs ${_maxPerPersonBudgetNpr.toStringAsFixed(0)} per person'
                            : null,
                      ),
                      validator: _validateBudget,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Available Days',
                        helperText: _daysHelperText(planner),
                      ),
                      validator: _validateDays,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: _showNprCurrency
                                  ? 'Max Budget (Rs)'
                                  : 'Max Budget (USD)',
                              helperText: _showNprCurrency
                                  ? 'Rs ${_maxPerPersonBudgetNpr.toStringAsFixed(0)} / person'
                                  : null,
                            ),
                            validator: _validateBudget,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Available Days',
                              helperText: _daysHelperText(planner),
                            ),
                            validator: _validateDays,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (useStackedFields) ...[
                    TextFormField(
                      controller: _peopleController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Number of People'),
                      validator: (v) =>
                          _requiredPositiveInt(v, 'Number of People'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _nationality,
                      items: const [
                        DropdownMenuItem(
                            value: 'INTERNATIONAL',
                            child: Text('International')),
                        DropdownMenuItem(
                            value: 'NEPALI', child: Text('Nepali')),
                      ],
                      decoration:
                          const InputDecoration(labelText: 'Nationality'),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _nationality = value);
                        }
                      },
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _peopleController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Number of People'),
                            validator: (v) =>
                                _requiredPositiveInt(v, 'Number of People'),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _nationality,
                            items: const [
                              DropdownMenuItem(
                                  value: 'INTERNATIONAL',
                                  child: Text('International')),
                              DropdownMenuItem(
                                  value: 'NEPALI', child: Text('Nepali')),
                            ],
                            decoration:
                                const InputDecoration(labelText: 'Nationality'),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _nationality = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (_showNprCurrency)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Budget-Friendly Rule: One trek should stay within Rs ${_maxPerPersonBudgetNpr.toStringAsFixed(0)} per person. Current group cap: Rs ${_maxAllowedBudgetNpr().toStringAsFixed(0)}.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (planner.selectedDestination?.isRestrictedArea == true)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'Restricted Area: Guide selection is mandatory (No Guide, No Trek).',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  Text(
                    'Guide Profiles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (planner.availableGuides.isEmpty)
                    const Text('No active guides available right now.')
                  else
                    ...planner.availableGuides.map(
                      (guide) => Card(
                        child: ListTile(
                          isThreeLine: useStackedFields,
                          onTap: () => planner.selectGuide(guide.id),
                          leading: CircleAvatar(
                            backgroundColor: planner.selectedGuideId == guide.id
                                ? Colors.green
                                : Colors.blueGrey,
                            child: Icon(
                              planner.selectedGuideId == guide.id
                                  ? Icons.check
                                  : Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(guide.name),
                          subtitle: Text(
                            '${guide.specialization} • ${guide.experienceYears} yrs • ${_priceLabel(guide.dailyRate)} / day',
                            maxLines: useStackedFields ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: useStackedFields
                              ? null
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Verified License',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _showNprCurrency
                          ? 'Include Guide (${_priceLabel(25, usdDecimals: 0)}-${_priceLabel(30, usdDecimals: 0)}/day)'
                          : 'Include Guide (USD 25-30/day)',
                    ),
                    value: _includeGuide,
                    onChanged: (value) => setState(() => _includeGuide = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _showNprCurrency
                          ? 'Include Porter (${_priceLabel(20, usdDecimals: 0)}/day)'
                          : 'Include Porter (USD 20/day)',
                    ),
                    value: _includePorter,
                    onChanged: (value) =>
                        setState(() => _includePorter = value),
                  ),
                  if (_includePorter)
                    TextFormField(
                      controller: _portersController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Number of Porters'),
                      validator: (v) =>
                          _requiredPositiveInt(v, 'Number of Porters'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Optional Detours (DAG Nodes)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (planner.availableDetours.isEmpty)
                    const Text(
                        'No optional detours available for this destination.')
                  else
                    ...planner.availableDetours.map(
                      (detour) => CheckboxListTile(
                        value: planner.selectedDetourIds.contains(detour.id),
                        onChanged: (selected) =>
                            planner.toggleDetour(detour.id, selected ?? false),
                        title: Text(detour.name),
                        subtitle: Text(
                          '+${detour.extraDays} days | +${_priceLabel(detour.extraCostUsd, usdDecimals: 0)} | ${detour.distanceKm.toStringAsFixed(1)} km',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: planner.isLoading ? null : _previewCost,
                        icon: const Icon(Icons.pie_chart_outline),
                        label: const Text('Preview Cost'),
                      ),
                      ElevatedButton.icon(
                        onPressed: planner.isCreating ? null : _createItinerary,
                        icon: planner.isCreating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.route),
                        label: const Text('Create Itinerary'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            planner.isCreating ? null : _optimizeKnapsack,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Optimize (Knapsack)'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutputPanel(
      ItineraryProvider planner, TrekItinerary? itinerary) {
    final weatherRisk = planner.currentWeatherRisk;
    final costBreakdown = planner.currentCostBreakdown;

    return Column(
      children: [
        if (weatherRisk != null)
          Card(
            child: ListTile(
              leading:
                  Icon(Icons.shield, color: Color(weatherRisk.getRiskColor())),
              title: Text('Weather Risk: ${weatherRisk.riskLevel}'),
              subtitle: Text(weatherRisk.recommendations.isEmpty
                  ? 'Monitor weather before departure.'
                  : weatherRisk.recommendations.first),
            ),
          ),
        if (costBreakdown != null)
          CostBreakdownChart(
            costBreakdown: costBreakdown,
            currencyCode: _showNprCurrency ? 'NPR' : 'USD',
          ),
        if (costBreakdown != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Cash Required (Cash-Only Logistics)'),
              subtitle: Text(
                _showNprCurrency
                    ? 'Rs ${costBreakdown.suggestedCashNpr.toStringAsFixed(0)}'
                    : 'USD ${costBreakdown.suggestedCashUsd.toStringAsFixed(2)}',
              ),
            ),
          ),
        if (itinerary != null) ...[
          if (itinerary.selectedGuide != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.green),
                title: Text('Guide: ${itinerary.selectedGuide!.name}'),
                subtitle: Text(
                  '${itinerary.selectedGuide!.specialization} • License ${itinerary.selectedGuide!.licenseNumber}',
                ),
                trailing: const Text('Verified License'),
              ),
            ),
          if (!itinerary.isSafe)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                itinerary.safetyWarnings.isNotEmpty
                    ? '⚠ ${itinerary.safetyWarnings.first}'
                    : '⚠ Safety Alert: This itinerary has high-altitude risk. Add an acclimatization day.',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Saved Trip Cash Required'),
              subtitle: Text(
                _showNprCurrency
                    ? 'Rs ${(itinerary.cashRecommendationNpr > 0 ? itinerary.cashRecommendationNpr : itinerary.suggestedCashNpr).toStringAsFixed(0)}'
                    : 'USD ${((itinerary.cashRecommendationNpr > 0 ? itinerary.cashRecommendationNpr : itinerary.suggestedCashNpr) / _usdToNpr).toStringAsFixed(2)}',
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Itinerary Flow',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Stepper(
                    currentStep: 0,
                    controlsBuilder: (_, __) => const SizedBox.shrink(),
                    physics: const NeverScrollableScrollPhysics(),
                    steps: itinerary.activities.isEmpty
                        ? [
                            const Step(
                              title: Text('Awaiting activity generation'),
                              content: Text('No activity nodes available yet.'),
                              isActive: true,
                            ),
                          ]
                        : itinerary.activities
                            .map(
                              (activity) => Step(
                                isActive: true,
                                title: Text(
                                  'Day ${activity.dayNumber}: ${activity.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${activity.activityType} | ${activity.difficulty}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                content: Text(
                                  'Altitude: ${activity.altitudeM ?? 0} m, Duration: ${activity.estimatedTimeHours.toStringAsFixed(1)}h',
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
          _buildAltitudeProfile(itinerary),
          _buildRouteMap(planner, itinerary),
        ],
      ],
    );
  }

  Widget _buildAltitudeProfile(TrekItinerary itinerary) {
    final points = itinerary.activities
        .where((a) => a.altitudeM != null)
        .map((a) => a.altitudeM!.toDouble())
        .toList();

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Altitude Profiler',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _AltitudeProfilePainter(
                  points,
                  highlightRisk: !itinerary.isSafe,
                ),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteMap(ItineraryProvider planner, TrekItinerary itinerary) {
    final mountainMode = context.watch<MountainModeProvider>();
    final destination = planner.selectedDestination;
    if (destination == null) return const SizedBox.shrink();

    final polylinePoints = <LatLng>[
      LatLng(destination.latitude, destination.longitude)
    ];
    final markers = <Marker>[
      Marker(
        point: LatLng(destination.latitude, destination.longitude),
        width: 70,
        height: 30,
        child: const Chip(label: Text('Base')),
      ),
    ];

    for (final detour in planner.availableDetours
        .where((d) => planner.selectedDetourIds.contains(d.id))) {
      final start = LatLng(detour.startLatitude, detour.startLongitude);
      final end = LatLng(detour.endLatitude, detour.endLongitude);
      polylinePoints.add(start);
      polylinePoints.add(end);
      markers.add(
        Marker(
          point: end,
          width: 110,
          height: 32,
          child:
              Chip(label: Text(detour.name, overflow: TextOverflow.ellipsis)),
        ),
      );
    }

    polylinePoints.add(LatLng(destination.latitude, destination.longitude));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route Map (OpenStreetMap)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: mountainMode.disableImageLoading
                    ? Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Text(
                          'Dark theme active: map tiles paused to improve performance.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                              destination.latitude, destination.longitude),
                          initialZoom: 8,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.nepal.trekking.app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: polylinePoints,
                                strokeWidth: 4,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AltitudeProfilePainter extends CustomPainter {
  final List<double> points;
  final bool highlightRisk;

  _AltitudeProfilePainter(this.points, {this.highlightRisk = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.width <= 0 || size.height <= 0) return;

    final minY = points.reduce((a, b) => a < b ? a : b);
    final maxY = points.reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).abs() < 1 ? 1 : maxY - minY;

    final plotted = <ui.Offset>[];
    final path = ui.Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minY) / range) * size.height;
      if (!x.isFinite || !y.isFinite) {
        continue;
      }
      final point = ui.Offset(x, y);
      plotted.add(point);
      if (plotted.length == 1) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (plotted.length < 2) return;

    final fillPath = ui.Path()
      ..addPath(path, ui.Offset.zero)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fill = Paint()
      ..color = Colors.blue.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final dangerStroke = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, stroke);

    // Risk highlighting comes from backend safety analysis.
    if (highlightRisk) {
      canvas.drawPath(path, dangerStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _AltitudeProfilePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
