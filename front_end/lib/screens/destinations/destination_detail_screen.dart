import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/destination.dart';
import '../../models/trek_route.dart';
import '../../models/weather.dart';
import '../../models/trek_itinerary.dart';
import '../../models/cost_breakdown.dart';
import '../../services/destination_service.dart';
import '../../services/trip_planner_service.dart';
import '../../config/app_theme.dart';
import '../../providers/mountain_mode_provider.dart';
import '../../widgets/cost_breakdown_chart.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> with SingleTickerProviderStateMixin {
  final DestinationService _destinationService = DestinationService();
  final TripPlannerService _tripPlannerService = TripPlannerService();
  static const double _usdToNpr = 133.0;
  late TabController _tabController;
  
  List<TrekRoute> _routePoints = [];
  List<Detour> _detours = [];
  CostBreakdown? _costBreakdown;
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _routePoints = await _destinationService.getDestinationRoute(widget.destination.id);
    _weather = await _destinationService.getDestinationWeather(widget.destination.id);
    _detours = await _tripPlannerService.getDetours(widget.destination.id);

    try {
      _costBreakdown = await _tripPlannerService.getCostBreakdown(
        destinationId: widget.destination.id,
        durationDays: widget.destination.durationDays,
        numberOfPeople: 1,
        nationality: 'INTERNATIONAL',
        includeGuide: true,
        includePorter: false,
      );
    } catch (_) {
      _costBreakdown = null;
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final disableImages = context.watch<MountainModeProvider>().disableImageLoading;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.destination.name,
                style: TextStyle(
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
                background: widget.destination.image != null && !disableImages
                  ? Image.network(
                      widget.destination.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Quick Info Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          Icons.calendar_today,
                          'Duration',
                          '${widget.destination.durationDays} Days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.terrain,
                          'Altitude',
                          '${widget.destination.altitude}m',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.attach_money,
                          'Price',
                          'NPR ${widget.destination.price.toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Difficulty Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getDifficultyColor(widget.destination.difficulty)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppTheme.getDifficultyColor(widget.destination.difficulty),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Difficulty: ${widget.destination.difficulty}',
                          style: TextStyle(
                            color: AppTheme.getDifficultyColor(widget.destination.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Weather Alert (if available)
                if (_weather != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildWeatherCard(_weather!),
                  ),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Route Map'),
                    Tab(text: 'Weather'),
                    Tab(text: 'Plan & Cost'),
                  ],
                ),
                
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildRouteMapTab(),
                      _buildWeatherTab(),
                      _buildPlanTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Weather weather) {
    return Card(
      color: AppTheme.getRiskColor(weather.riskLevel).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: AppTheme.getRiskColor(weather.riskLevel),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Weather',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              weather.weatherCondition,
              style: TextStyle(fontSize: 16),
            ),
            if (weather.warningMessage != 'No warnings') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getRiskColor(weather.riskLevel).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getRiskColor(weather.riskLevel),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.getRiskColor(weather.riskLevel),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weather.warningMessage,
                        style: TextStyle(
                          color: AppTheme.getRiskColor(weather.riskLevel),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Trek',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.destination.description,
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.location_on, 'Location', widget.destination.location),
          _buildDetailRow(Icons.wb_sunny, 'Best Season', widget.destination.bestSeason ?? 'All Year'),
          _buildDetailRow(Icons.directions_bus, 'Bus / Jeep Access', _getTransportAccessInfo()),
          _buildDetailRow(Icons.hiking, 'Walking Starts From', _getWalkStartInfo()),
        ],
      ),
    );
  }

  String _getTransportAccessInfo() {
    final name = widget.destination.name.toLowerCase();

    if (name.contains('annapurna base camp')) {
      return 'From Pokhara, bus/jeep to Nayapul or Jhinu Danda.';
    }
    if (name.contains('everest') || name.contains('ebc')) {
      return 'Flight to Lukla, or road to Salleri and then jeep to Phaplu.';
    }
    if (name.contains('langtang')) {
      return 'From Kathmandu, bus/jeep to Syabrubesi.';
    }
    if (name.contains('manaslu')) {
      return 'From Kathmandu, bus to Arughat or jeep to Machha Khola.';
    }
    if (name.contains('mardi')) {
      return 'From Pokhara, local vehicle to Kande or Phedi.';
    }
    if (name.contains('poon hill') || name.contains('ghorepani')) {
      return 'From Pokhara, bus/jeep to Nayapul, Hile, or Ulleri.';
    }

    return 'Use local bus/jeep from the nearest city to the road-head near ${widget.destination.location}.';
  }

  String _getWalkStartInfo() {
    final name = widget.destination.name.toLowerCase();

    if (name.contains('annapurna base camp')) {
      return 'Most trekkers start walking from Nayapul/Jhinu toward Ghandruk-Chhomrong.';
    }
    if (name.contains('everest') || name.contains('ebc')) {
      return 'Trek starts from Lukla (or from Phaplu if coming by road).';
    }
    if (name.contains('langtang')) {
      return 'Walking starts at Syabrubesi.';
    }
    if (name.contains('manaslu')) {
      return 'Typical trail starts from Machha Khola/Soti Khola.';
    }
    if (name.contains('mardi')) {
      return 'Start from Kande/Phedi and continue via Forest Camp.';
    }
    if (name.contains('poon hill') || name.contains('ghorepani')) {
      return 'Start from Nayapul/Ulleri and walk via Tikhedhunga-Ghorepani.';
    }

    return 'Start walking from the nearest trailhead after the final motorable point.';
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMapTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_routePoints.isEmpty) {
      return Center(
        child: Text('No route data available'),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(widget.destination.latitude, widget.destination.longitude),
        initialZoom: 10.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trekking_app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayer(
          markers: _routePoints.map((point) {
            return Marker(
              point: LatLng(point.latitude, point.longitude),
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Icon(Icons.location_pin, color: Colors.red, size: 30),
                  if (point.locationName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        point.locationName,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeatherTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_weather == null) {
      return Center(
        child: Text('Weather data not available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeatherDetailCard('Temperature', '${_weather!.temperature.toStringAsFixed(1)}°C', Icons.thermostat),
          _buildWeatherDetailCard('Condition', _weather!.weatherCondition, Icons.wb_cloudy),
          _buildWeatherDetailCard('Description', _weather!.description, Icons.info_outline),
          _buildWeatherDetailCard('Humidity', '${_weather!.humidity}%', Icons.water_drop),
          _buildWeatherDetailCard('Wind Speed', '${_weather!.windSpeed} m/s', Icons.air),
          _buildWeatherDetailCard('Risk Level', _weather!.riskLevel, Icons.warning),
        ],
      ),
    );
  }

  Widget _buildPlanTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optional Detours & Stops',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_detours.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No optional detours configured for this destination yet.'),
              ),
            )
          else
            _buildDetourChartCard(),
          const SizedBox(height: 16),
          Text(
            'Estimated Cost Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_costBreakdown != null)
            CostBreakdownChart(
              costBreakdown: _costBreakdown!,
              currencyCode: 'NPR',
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Cost breakdown unavailable right now. Please try again later.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetourChartCard() {
    final maxCost = _detours
        .map((d) => d.extraCostUsd)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detour Cost Chart',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._detours.map((detour) {
              final ratio = maxCost > 0 ? (detour.extraCostUsd / maxCost) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            detour.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text('Rs ${(detour.extraCostUsd * _usdToNpr).toStringAsFixed(0)}  (+${detour.extraDays}d)'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.terrain, size: 80, color: Colors.grey[500]),
      ),
    );
  }

}
