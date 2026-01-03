import 'package:flutter/material.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _sidebarExpanded = false;
  int _selectedIndex = 0;
  String _stationLocation = 'location of\npolice station';
  
  // Filter states
  String _filterName = '';
  String _filterLocation = '';
  String _filterType = '';
  DateTime? _filterDate;
  
  List<String> _locationSuggestions = [];
  
  // Controllers for on-demand filtering
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _locationFilterController = TextEditingController();
  final TextEditingController _typeFilterController = TextEditingController();
  
  // Track IDs that are currently being resolved to show loading state
  final Set<String> _resolvingIds = {};
  final Set<String> _locallyHiddenIds = {}; // For Optimistic UI updates
  
  late Stream<List<Map<String, dynamic>>> _incidentsStream;
  late Stream<List<Map<String, dynamic>>> _sosStream;
  late Stream<List<Map<String, dynamic>>> _citizensStream;
  late Stream<List<Map<String, dynamic>>> _queriesStream;

  final String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    _locationFilterController.dispose();
    _typeFilterController.dispose();
    super.dispose();
  }

  void _initStreams() {
    _incidentsStream = PoliceSupabaseService.getAllIncidents();
    _sosStream = PoliceSupabaseService.getSOSAlerts();
    _citizensStream = PoliceSupabaseService.getCitizens();
    _queriesStream = PoliceSupabaseService.getCitizenQueries();
    _fetchLocationSuggestions();
    _fetchCurrentLocation(); // Auto-fetch on startup
  }

  void _refreshAll() {
    setState(() {
      _locallyHiddenIds.clear(); // Clear local hidden cache on manual refresh
      _initStreams();
    });
  }
  
  Future<void> _fetchLocationSuggestions() async {
    final Set<String> locations = {};
    try {
      // Fetch from multiple sources to populate suggestions
      final pendingStruct = await PoliceSupabaseService.getPendingIncidents().first;
      for (var doc in pendingStruct) {
        final data = doc;
        final loc = (data['address'] ?? data['location'] ?? '').toString();
        if (loc.isNotEmpty) locations.add(loc);
      }
      final solvedStruct = await PoliceSupabaseService.getSolvedCases().first;
      for (var doc in solvedStruct) {
        final data = doc;
        final loc = (data['address'] ?? data['location'] ?? '').toString();
        if (loc.isNotEmpty) locations.add(loc);
      }
      final sosStruct = await PoliceSupabaseService.getSOSAlerts().first;
      for (var doc in sosStruct) {
        final data = doc;
        final loc = (data['location'] ?? '').toString();
        if (loc.isNotEmpty) locations.add(loc);
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
    }
    if (mounted) {
      setState(() {
        _locationSuggestions = locations.toList()..sort();
      });
    }
  }


  
  void _applyFilters() {
    setState(() {
      _filterName = _nameFilterController.text.trim();
      _filterLocation = _locationFilterController.text.trim();
      _filterType = _typeFilterController.text.trim();
    });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Silent fail as per user request for "auto"
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      // Get current position
      debugPrint('Fetching position...');
      final position = await Geolocator.getCurrentPosition();
      debugPrint('Position: ${position.latitude}, ${position.longitude}');
      
      String? address;
      try {
        // Reverse geocode
        debugPrint('Attempting reverse geocoding...');
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = [
            p.subLocality,
            p.locality, 
            p.administrativeArea
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
        
        // Fallback: Try OpenStreetMap Nominatim API
        try {
          debugPrint('Attempting Nominatim fallback...');
          final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
          final response = await http.get(url, headers: {'User-Agent': 'PoliceDashboard/1.0'});
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final displayName = data['display_name'];
            if (displayName != null) {
              // Extract a shorter address if possible, or use display_name
              final addr = data['address'];
              if (addr != null) {
                // Try to construct a detailed address similar to native geocoder
                final parts = <String>[];
                
                if (addr['house_number'] != null) parts.add(addr['house_number']);
                if (addr['road'] != null) parts.add(addr['road']);
                
                final area = addr['suburb'] ?? addr['neighbourhood'] ?? addr['residential'] ?? addr['village'];
                if (area != null) parts.add(area);
                
                final city = addr['city'] ?? addr['town'] ?? addr['city_district'] ?? addr['county'];
                if (city != null) parts.add(city);
                
                if (addr['postcode'] != null) parts.add(addr['postcode']);
                
                // Only add state if we have very little info
                if (parts.length < 2 && addr['state'] != null) {
                  parts.add(addr['state']);
                }

                address = parts.join(', ');
              } 
              if (address == null || address.isEmpty) {
                 address = displayName; // Fallback to full string
              }
            }
          }
        } catch (nominatimError) {
           debugPrint('Nominatim fallback failed: $nominatimError');
        }
      }
      
      if (mounted) {
        setState(() {
          _stationLocation = (address != null && address.isNotEmpty) 
              ? address 
              : 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // No manual dialog needed as per request


  // Citizen queries now come from Firestore

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _nameFilterController,
              decoration: const InputDecoration(
                hintText: 'Filter by Name (Press Enter)',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RawAutocomplete<String>(
              textEditingController: _locationFilterController,
              focusNode: FocusNode(),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _locationSuggestions.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _applyFilters();
              },
              fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Filter by Location',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  onSubmitted: (String value) {
                    _applyFilters();
                  },
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SizedBox(
                        width: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _typeFilterController,
              decoration: const InputDecoration(
                hintText: 'Filter by Type (Press Enter)',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(_filterDate == null ? 'Select Date' : _filterDate.toString().split(' ')[0]),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _filterDate = picked);
              }
            },
          ),
          if (_filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => setState(() => _filterDate = null),
            ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(Map<String, dynamic> data, {String? nameKey, String? locationKey}) {
    final name = (data[nameKey ?? 'user_name'] ?? data['userName'] ?? data['name'] ?? data['citizen'] ?? data['user_id'] ?? data['userId'] ?? '').toString().toLowerCase();
    final location = (data[locationKey ?? 'location'] ?? data['address'] ?? '').toString().toLowerCase();
    final type = (data['type'] ?? 'INCIDENT').toString().toLowerCase();
    
    if (_filterName.isNotEmpty && !name.contains(_filterName.toLowerCase())) {
      return false;
    }
    if (_filterLocation.isNotEmpty && !location.contains(_filterLocation.toLowerCase())) {
      return false;
    }
    if (_filterType.isNotEmpty && !type.contains(_filterType.toLowerCase())) {
      return false;
    }
    if (_filterDate != null) {
      final timestamp = data['timestamp'];
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        if (date.year != _filterDate!.year || date.month != _filterDate!.month || date.day != _filterDate!.day) {
          return false;
        }
      } else {
        // Try text matching if timestamp missing
        try {
           final timeStr = (data['time'] ?? data['date'] ?? '').toString();
           if (timeStr.isNotEmpty) {
             final ymd = timeStr.split(' ')[0]; // Assumes YYYY-MM-DD or similar
             final parts = ymd.split('-');
             if (parts.length == 3) {
               final y = int.tryParse(parts[0]);
               final m = int.tryParse(parts[1]);
               final d = int.tryParse(parts[2]);
               if (y != null && m != null && d != null) {
                  if (y != _filterDate!.year || m != _filterDate!.month || d != _filterDate!.day) {
                    return false;
                  }
               }
             }
           }
        } catch (_) {}
      }
    }
    return true;
  }

  // Helper method to create watermark background
  Widget _buildWatermark() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.26,
        child: Image.asset(
          'assets/images/tn_police_watermark.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Transform.scale(
                scale: 1.05, // Slightly zoom to hide any edge artifacts
                child: Image.asset(
                  'assets/images/tn_police_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('தமிழ்நாடு காவல்துறை', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('TAMIL NADU POLICE', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _fetchCurrentLocation, // Retry on tap
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _stationLocation,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PoliceLoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 28),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return MouseRegion(
      onEnter: (_) => setState(() => _sidebarExpanded = true),
      onExit: (_) => setState(() => _sidebarExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _sidebarExpanded ? 220 : 70,
        color: const Color(0xFF5A6A7A),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              _buildSidebarItem(0, Icons.dashboard, 'Dashboard'),
              _buildSidebarItem(1, Icons.description, 'Reported Incidents'),
              _buildSidebarItem(5, Icons.sos, 'Reported SOS'),
              _buildSidebarItem(2, Icons.check_circle_outline, 'Solved cases'),
              _buildSidebarItem(3, Icons.people_outline, 'Citizen data'),
              _buildSidebarItem(4, Icons.feedback_outlined, 'Citizen Queries'),
              _buildSidebarItem(7, Icons.folder_special, 'Previous Evidences'),
              _buildSidebarItem(6, Icons.chat_bubble_outline, 'AI Chatbot Replies'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5A6A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 1:
        return _buildPendingReportsView();
      case 2:
        return _buildSolvedCasesView();
      case 3:
        return _buildCitizenDataView();
      case 4:
        return _buildCitizenQueriesView();
      case 5:
        return _buildReportedSOSView();
      case 6:
        return _buildAIChatbotsView();
      case 7:
        return _buildPreviousEvidencesView();
      default:
        return _buildMainDashboard();
    }
  }

  Widget _buildMainDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        
        return Container(
          color: const Color(0xFFE8EBF0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildWatermark(),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
                child: isWide
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildIncidentReportsSection(constraints)),
                              const SizedBox(width: 60),
                              Expanded(child: _buildSOSSection(constraints)),
                            ],
                          ),
                          // Temporarily commented out to fix Firestore streaming errors
                          // const SizedBox(height: 60),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Expanded(flex: 2, child: _buildSolvedCasesSection(constraints)),
                          //     const SizedBox(width: 60),
                          //     Expanded(child: _buildResolvedSOSSection(constraints)),
                          //   ],
                          // ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIncidentReportsSection(constraints),
                          const SizedBox(height: 30),
                          _buildSOSSection(constraints),
                          // Temporarily commented out to fix Firestore streaming errors
                          // const SizedBox(height: 60),
                          // _buildSolvedCasesSection(constraints),
                          // const SizedBox(height: 30),
                          // _buildResolvedSOSSection(constraints),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncidentReportsSection(BoxConstraints constraints) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: PoliceSupabaseService.getPendingIncidents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error loading incidents: ${snapshot.error}');
        }
        final docs = snapshot.data ?? [];
        // Client-side filtering for pending status
        final pendingDocs = docs.where((doc) {
          final data = doc;
          return data['status'] == 'pending';
        }).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PENDING INCIDENT REPORTS',
              style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (pendingDocs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No Pending Incident Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (pendingDocs.isNotEmpty)
              ...pendingDocs.take(3).map((doc) {
                final data = doc;
                return _buildIncidentCard({
                  'id': doc['id'],
                  'status': data['status'],
                  'type': (data['type'] ?? 'INCIDENT').toString(),
                  'color': _getSeverityColor((data['severity'] ?? 'low') as String),
                  'description': (data['description'] ?? '').toString(),
                  'address': data['address'] ?? data['location'],
                  'location': data['location'],
                  'timestamp': data['timestamp'],
                  'time': data['time'],
                  'images': data['images'] ?? [],
                  'videos': data['videos'] ?? [],
                  'audios': data['audios'] ?? [],
                });
              }),
          ],
        );
      },
    );
  }

  Widget _buildSOSSection(BoxConstraints constraints) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: PoliceSupabaseService.getSOSAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading SOS alerts'));
        }
        final docs = snapshot.data ?? [];
        final items = docs.where((doc) {
          final data = doc;
          if ((data['status'] ?? 'active') != 'active') return false;
          return _matchesFilter(data, nameKey: 'userName', locationKey: 'location');
        }).toList();
        
        final sorted = List<Map<String, dynamic>>.from(items);
        sorted.sort((a, b) {
          final da = a;
          final db = b;
          final ta = da['timestamp'];
          final tb = db['timestamp'];
          final ma = ta is String ? DateTime.parse(ta).millisecondsSinceEpoch : 0;
          final mb = tb is String ? DateTime.parse(tb).millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });
        final latestDoc = sorted.isNotEmpty ? sorted.first : null;
        final latest = latestDoc != null ? latestDoc : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SOS', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: latest == null
                  ? const Text('No active SOS alerts', style: TextStyle(color: Colors.white, fontSize: 18))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active SOS Alert', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20)),
                        const SizedBox(height: 12),
                        Text('location: ${latest['location'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('time: ${_formatTimestamp(latest['timestamp'] ?? latest['time'])}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('person: ${latest['user_name'] ?? latest['user_id'] ?? 'Citizen'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (latestDoc != null) {
                              try {
                                await PoliceSupabaseService.resolveSOSAlert(latestDoc['id']);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating status: ${e.toString().contains("permission-denied") ? "Permission denied. Check Firestore Rules." : e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Mark Done', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (incident['type'] ?? 'INCIDENT').toString().toUpperCase(),
            style: TextStyle(color: incident['color'] ?? Colors.grey, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if ((incident['description'] ?? '').toString().isNotEmpty)
            Text(incident['description'], style: TextStyle(color: Colors.grey[800], fontSize: 16))
          else
            Text('No description provided', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 8),
          Text('Reporter: ${incident['user_name'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('address: ${incident['address'] ?? incident['location'] ?? 'Unknown'}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 4),
          Text('time: ${_formatTimestamp(incident['timestamp'] ?? incident['time'])}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final images = (incident['images'] is List) ? List.from(incident['images']) : const [];
            final videos = (incident['videos'] is List) ? List.from(incident['videos']) : const [];
            final audios = (incident['audios'] is List) ? List.from(incident['audios']) : const [];
            if (images.isEmpty && videos.isEmpty && audios.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton.icon(
                onPressed: () => _showMediaDialog(context, images, videos, audios),
                icon: const Icon(Icons.remove_red_eye, color: Color(0xFF1E3A8A)),
                label: const Text('View Media', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            );
          }),
          if ((incident['status'] ?? '') != 'resolved' && (incident['id'] ?? '') != '')
            Align(
              alignment: Alignment.centerLeft,
              child: Builder(builder: (context) {
                final id = (incident['id'] ?? '').toString();
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: _resolvingIds.contains(id) ? null : () async {
                  if (id.isEmpty) return;
                  setState(() => _resolvingIds.add(id));
                  try {
                    await PoliceSupabaseService.updateIncidentStatus(id, 'resolved');
                    if (mounted) {
                      setState(() => _locallyHiddenIds.add(id));
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incident marked resolved')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to resolve: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _resolvingIds.remove(id));
                    }
                  }
                },
                  child: _resolvingIds.contains(id) 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Mark Done', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingReportsView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) crossAxisCount = 2;
        if (constraints.maxWidth < 500) crossAxisCount = 1;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _incidentsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading reports: ${snapshot.error}'));
            }
            final docs = snapshot.data ?? [];
            // Client-side filtering for pending status
             final pendingDocs = docs.where((doc) {
               final data = doc;
               final id = data['id']?.toString() ?? '';
               if (data['status'] != 'pending' || _locallyHiddenIds.contains(id)) return false;
               return _matchesFilter(data, nameKey: 'userName', locationKey: 'address');
             }).toList();
            
            final sorted = List<Map<String, dynamic>>.from(pendingDocs);
            sorted.sort((a, b) {
              final da = a;
              final db = b;
              
              // Primary Sort: Severity (High > Medium > Low)
              final sa = (da['severity'] ?? 'low').toString().toLowerCase();
              final sb = (db['severity'] ?? 'low').toString().toLowerCase();
              
              int getSeverityVal(String s) {
                if (s == 'high') return 3;
                if (s == 'medium') return 2;
                return 1; // low
              }
              
              final va = getSeverityVal(sa);
              final vb = getSeverityVal(sb);
              
              if (va != vb) return vb.compareTo(va); // Descending (3 > 2 > 1)

              // Secondary Sort: Timestamp (Newest first)
              final ta = da['timestamp'];
              final tb = db['timestamp'];
              final ma = ta is String ? DateTime.parse(ta).millisecondsSinceEpoch : 0;
              final mb = tb is String ? DateTime.parse(tb).millisecondsSinceEpoch : 0;
              return mb.compareTo(ma);
            });

            return Container(
              color: const Color(0xFFE8EBF0),
              child: Stack(
                children: [
                  _buildWatermark(),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENDING INCIDENT REPORTS',
                          style: TextStyle(
                            color: const Color(0xFF1E3A8A),
                            fontSize: constraints.maxWidth * 0.025 > 28 ? 28 : constraints.maxWidth * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (docs.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('No pending incident reports'),
                            ),
                          ),
                        if (docs.isNotEmpty)
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: sorted.length,
                              itemBuilder: (context, index) {
                                final data = sorted[index];
                                final id = (data['id'] ?? '').toString();
                                final severity = (data['severity'] ?? 'low') as String;
                                final color = _getSeverityColor(severity);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        (data['type'] ?? 'INCIDENT').toString().toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Reporter: ${data['user_name'] ?? 'Unknown'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'address: ${data['address'] ?? data['location'] ?? 'Unknown'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        'time: ${_formatTimestamp(data['timestamp'] ?? data['time'])}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      Builder(builder: (context) {
                                        final images = (data['images'] is List) ? List.from(data['images']) : const [];
                                        final videos = (data['videos'] is List) ? List.from(data['videos']) : const [];
                                        final audios = (data['audios'] is List) ? List.from(data['audios']) : const [];
                                        if (images.isEmpty && videos.isEmpty && audios.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                if (images.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                                                    child: Text('images: ${images.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                if (videos.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                                                    child: Text('videos: ${videos.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                if (audios.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                                                    child: Text('audios: ${audios.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton.icon(
                                              onPressed: () => _showMediaDialog(context, images, videos, audios),
                                              icon: const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                                              label: const Text('View Media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.white10,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: _resolvingIds.contains(id) ? null : () async {
                                          setState(() => _resolvingIds.add(id));
                                          try {
                                            await PoliceSupabaseService.updateIncidentStatus(id, 'resolved');
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Incident marked resolved')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to resolve: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() => _resolvingIds.remove(id));
                                            }
                                          }
                                        },
                                        child: _resolvingIds.contains(id)
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Text('Mark Done', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportedSOSView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) crossAxisCount = 2;
        if (constraints.maxWidth < 500) crossAxisCount = 1;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _sosStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading SOS alerts: ${snapshot.error}'));
            }
            final docs = snapshot.data ?? [];
            final activeDocs = docs.where((doc) {
              final data = doc;
              final id = data['id']?.toString() ?? '';
              return (data['status'] ?? 'active') == 'active' && !_locallyHiddenIds.contains(id);
            }).toList();
            
            final sorted = List<Map<String, dynamic>>.from(activeDocs);
            sorted.sort((a, b) {
              final da = a;
              final db = b;
              final ta = da['timestamp'];
              final tb = db['timestamp'];
              final ma = ta is String ? DateTime.parse(ta).millisecondsSinceEpoch : 0;
              final mb = tb is String ? DateTime.parse(tb).millisecondsSinceEpoch : 0;
              return mb.compareTo(ma);
            });

            return Container(
              color: const Color(0xFFE8EBF0),
              child: Stack(
                children: [
                  _buildWatermark(),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REPORTED SOS ALERTS',
                          style: TextStyle(
                            color: const Color(0xFF1E3A8A),
                            fontSize: constraints.maxWidth * 0.025 > 28 ? 28 : constraints.maxWidth * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (docs.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('No active SOS alerts'),
                            ),
                          ),
                        if (docs.isNotEmpty)
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: sorted.length,
                              itemBuilder: (context, index) {
                                final data = sorted[index];
                                final id = (data['id'] ?? '').toString();
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'location: ${data['location'] ?? 'Unknown'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        'time: ${_formatTimestamp(data['timestamp'] ?? data['time'])}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        'person: ${data['user_name'] ?? data['user_id'] ?? 'Citizen'}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: _resolvingIds.contains(id) ? null : () async {
                                          setState(() => _resolvingIds.add(id));
                                          try {
                                            await PoliceSupabaseService.resolveSOSAlert(id);
                                            if (mounted) {
                                              setState(() => _locallyHiddenIds.add(id));
                                            }
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('SOS marked resolved')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to resolve: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() => _resolvingIds.remove(id));
                                            }
                                          }
                                        },
                                        child: _resolvingIds.contains(id)
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Text('Mark Done', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is String) {
      final d = DateTime.parse(value).toLocal();
      final s = d.toString();
      return s.length >= 16 ? s.substring(0, 16) : s;
    }
    if (value is String) {
      return value;
    }
    return '';
  }
  // _buildReportCard removed - pending reports now use live Firestore data above.

  Widget _buildSolvedCasesView() {
    return Container(
      color: const Color(0xFFE8EBF0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildWatermark(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterBar(),
                const SizedBox(height: 20),
                const Text(
                  'SOLVED CASES HISTORY',
                  style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: PoliceSupabaseService.getSolvedCases(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading solved cases: ${snapshot.error}');
                    }
                    final docs = snapshot.data ?? [];
                    // Client-side filtering for resolved status
                    final resolvedDocs = docs.where((doc) {
                      final data = doc;
                      if (data['status'] != 'resolved') return false;
                      return _matchesFilter(data, nameKey: 'user_name', locationKey: 'address');
                    }).toList();
                    
                    if (resolvedDocs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No Solved Cases Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: resolvedDocs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final data = doc;
                        return _buildSolvedCaseCard({
                          'id': 'CASE-${(index + 1).toString().padLeft(3, '0')}',
                          'type': (data['type'] ?? 'INCIDENT').toString(),
                          'location': (data['address'] ?? data['location'] ?? 'Unknown').toString(),
                          'date': _formatTimestamp(data['timestamp'] ?? data['time']),
                          'citizen': (data['user_name'] ?? data['name'] ?? data['userName'] ?? data['user_id'] ?? data['userId'] ?? 'Citizen').toString(),
                          'status': 'Resolved',
                        });
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
                const Text(
                  'RESOLVED SOS ALERTS',
                  style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: PoliceSupabaseService.getSolvedSOSAlerts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading resolved SOS: ${snapshot.error}');
                    }
                    final docs = snapshot.data ?? [];
                    // Client-side filtering for resolved status
                    final resolvedDocs = docs.where((doc) {
                      final data = doc;
                      if (data['status'] != 'resolved') return false;
                      return _matchesFilter(data, nameKey: 'user_name', locationKey: 'location');
                    }).toList();
                    
                    if (resolvedDocs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No Resolved SOS Alerts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: resolvedDocs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final data = doc;
                        return _buildSolvedCaseCard({
                          'id': 'SOS-${(index + 1).toString().padLeft(3, '0')}',
                          'type': 'SOS ALERT',
                          'location': (data['location'] ?? 'Unknown').toString(),
                          'date': _formatTimestamp(data['timestamp'] ?? data['time']),
                          'citizen': (data['user_name'] ?? data['name'] ?? data['userName'] ?? data['user_id'] ?? data['userId'] ?? 'Citizen').toString(),
                          'status': 'Resolved',
                        });
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolvedCaseCard(Map<String, dynamic> caseData) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(caseData['id'], style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(caseData['status'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Type: ${caseData['type']}', style: const TextStyle(fontSize: 16)),
                Text('Location: ${caseData['location']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text('Date: ${caseData['date']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text('Citizen: ${caseData['citizen']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenDataView() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _incidentsStream,
      builder: (context, incSnapshot) {
        if (incSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (incSnapshot.hasError) {
          return const Center(child: Text('Error loading citizen data'));
        }
        final incDocs = incSnapshot.data ?? [];
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _sosStream,
          builder: (context, sosSnapshot) {
            if (sosSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (sosSnapshot.hasError) {
              return const Center(child: Text('Error loading citizen data'));
            }
            final sosDocs = sosSnapshot.data ?? [];
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _citizensStream,
              builder: (context, citizensSnapshot) {
                if (citizensSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final citizensDocs = citizensSnapshot.data ?? [];
                // Create a profile lookup map by UID (and fallback username)
                final Map<String, Map<String, dynamic>> profilesByUid = {};
                for (final prof in citizensDocs) {
                  final uid = prof['user_id']?.toString();
                  if (uid != null) profilesByUid[uid] = prof;
                  final uname = prof['username']?.toString();
                  if (uname != null) profilesByUid[uname] = prof;
                }

                final Map<String, Map<String, dynamic>> reporters = {};
                for (final doc in incDocs) {
                  final data = doc;
                  final userId = (data['user_id'] ?? '').toString();
                  final name = (data['user_name'] ?? userId ?? 'Unknown').toString();
                  if (name.isEmpty) continue;
                  
                  final entry = reporters.putIfAbsent(name, () {
                    final profile = profilesByUid[userId];
                    return {
                      'name': name,
                      'phone': (profile?['phone'] ?? userId).toString(),
                      'aadhar': (profile?['aadhar'] ?? 'N/A').toString(),
                      'address': (data['address'] ?? data['location'] ?? 'Unknown').toString(),
                      'cases': 0,
                    };
                  });
                  entry['cases'] = (entry['cases'] as int) + 1;
                }
                for (final doc in sosDocs) {
                  final data = doc;
                  final userId = (data['user_id'] ?? '').toString();
                  final name = (data['user_name'] ?? userId ?? 'Unknown').toString();
                  if (name.isEmpty) continue;
                  
                  final entry = reporters.putIfAbsent(name, () {
                    final profile = profilesByUid[userId];
                    return {
                      'name': name,
                      'phone': (profile?['phone'] ?? userId).toString(),
                      'aadhar': (profile?['aadhar'] ?? 'N/A').toString(),
                      'address': (data['location'] ?? 'Unknown').toString(),
                      'cases': 0,
                    };
                  });
                  entry['cases'] = (entry['cases'] as int) + 1;
                }
                
                // Filter reporters list
                final filteredReporters = reporters.values.where((citizen) {
                   return _matchesFilter(citizen, nameKey: 'name', locationKey: 'address');
                }).toList();

                final reporterList = filteredReporters
                  ..sort((a, b) => (b['cases'] as int).compareTo(a['cases'] as int));
                return Container(
                  color: const Color(0xFFE8EBF0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildWatermark(),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CITIZEN DATA',
                              style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _buildFilterBar(),
                            const SizedBox(height: 10),
                            Text('Citizens who reported: ${reporterList.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            const SizedBox(height: 30),
                            ...reporterList.map((citizen) => _buildCitizenCard(citizen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCitizenCard(Map<String, dynamic> citizen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Color(0xFF1E3A8A), size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(citizen['name'], style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${citizen['cases']} cases', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(citizen['phone'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    const SizedBox(width: 24),
                    const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Aadhar: ${citizen['aadhar']}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(citizen['address'], style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenQueriesView() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: PoliceSupabaseService.getCitizenQueries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading queries'));
        }
        final docs = snapshot.data ?? [];

        return Container(
          color: const Color(0xFFE8EBF0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildWatermark(),
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CITIZEN QUERIES & REQUESTS',
                      style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Reviews and change requests from citizens',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 20),
                    _buildFilterBar(),
                    const SizedBox(height: 10),
                    if (docs.isEmpty)
                      const Text('No queries yet.')
                    else
                      ...docs.where((doc) {
                        final data = doc;
                        return _matchesFilter(data, nameKey: 'citizen', locationKey: 'address'); // Queries might not have location
                      }).map((doc) {
                        final data = doc;
                        return _buildQueryCard(doc['id'], data);
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueryCard(String queryId, Map<String, dynamic> query) {
    final status = query['status'] ?? 'pending';
    final isPending = status == 'pending';
    final isResponded = status == 'responded' || status == 'resolved';
    Color typeColor;
    IconData typeIcon;
    
    switch (query['type']) {
      case 'Review':
        typeColor = Colors.blue;
        typeIcon = Icons.rate_review;
        break;
      case 'Change Request':
        typeColor = Colors.orange;
        typeIcon = Icons.edit_note;
        break;
      case 'Feedback':
        typeColor = Colors.green;
        typeIcon = Icons.thumb_up;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.message;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: typeColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(query['citizen'], style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(query['type'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.orange : (isResponded ? Colors.green : Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isPending ? 'PENDING' : (isResponded ? 'RESPONDED' : status.toString().toUpperCase()), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(query['message'], style: const TextStyle(fontSize: 16, height: 1.4)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(query['date'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    if (isPending) ...[
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => _showQueryResponseDialog(queryId, query),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Respond', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                if (isResponded && query.containsKey('response')) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.reply, size: 16, color: Color(0xFF1E3A8A)),
                            SizedBox(width: 6),
                            Text('POLICE RESPONSE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(query['response'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQueryResponseDialog(String queryId, Map<String, dynamic> query) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Respond to ${query['citizen']}'),
        content: SizedBox(
          width: 450, // Force a fixed width to ensure text wraps instead of expanding the dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message: ${query['message']}',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                softWrap: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type your response here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final response = controller.text.trim();
              if (response.isEmpty) return;
              
              try {
                await PoliceSupabaseService.respondToQuery(queryId, response);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Response sent successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sending response: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            child: const Text('Send Response', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Removed unused _buildSolvedCasesSection

  // Removed unused _buildResolvedSOSSection

  Widget _buildAIChatbotsView() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: PoliceSupabaseService.getAIChatLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading AI chats'));
        }
        
        // Group messages by userId
        final docs = snapshot.data ?? [];
        final Map<String, Map<String, dynamic>> userChats = {};

        for (var doc in docs) {
            final data = doc;
            final userId = (data['user_id'] ?? '').toString();
            if (userId.isEmpty) continue;
            
            if (!userChats.containsKey(userId)) {
                userChats[userId] = {
                    'user_id': userId,
                    'user_name': data['user_name'] ?? 'Unknown User',
                    'messages': <Map<String, dynamic>>[],
                };
            }
            // Add message to list
            (userChats[userId]!['messages'] as List<Map<String, dynamic>>).add(data);
        }

        final users = userChats.values.toList();

        return Container(
          color: const Color(0xFFE8EBF0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildWatermark(),
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI CHATBOT REPLY',
                      style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Total conversations: ${users.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 30),
                    if (users.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No AI chat conversations yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ),
                      ),
                    if (users.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: users.map((userChat) {
                            final userName = userChat['user_name'];
                            final messages = userChat['messages'] as List<Map<String, dynamic>>;
                            // Sort messages by created_at ascending for the chat view
                            messages.sort((a, b) {
                                final ta = a['created_at'] as String?;
                                final tb = b['created_at'] as String?;
                                if (ta == null || tb == null) return 0;
                                return ta.compareTo(tb); 
                            });

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showChatDialog(context, userName, messages);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E3A8A),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      'view user chat and response',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviousEvidencesView() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: PoliceSupabaseService.getAllIncidents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading evidences'));
        }
        final docs = snapshot.data ?? [];
        final evidenceDocs = docs.where((doc) {
            final images = doc['images'] as List?;
            final videos = doc['videos'] as List?;
            final audios = doc['audios'] as List?;
            return (images != null && images.isNotEmpty) || 
                   (videos != null && videos.isNotEmpty) || 
                   (audios != null && audios.isNotEmpty);
        }).toList();

        if (evidenceDocs.isEmpty) {
            return Container(
                color: const Color(0xFFE8EBF0),
                child: const Center(child: Text('No previous evidences found.', style: TextStyle(fontSize: 18, color: Colors.grey))),
            );
        }

        return Container(
            color: const Color(0xFFE8EBF0),
            child: Stack(
                fit: StackFit.expand,
                children: [
                    _buildWatermark(),
                    SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    'PREVIOUS EVIDENCES',
                                    style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Total records with media: ${evidenceDocs.length}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                                const SizedBox(height: 30),
                                ...evidenceDocs.map((doc) => _buildEvidenceCard(doc)),
                            ],
                        ),
                    ),
                ],
            ),
        );
      },
    );
  }

  Widget _buildEvidenceCard(Map<String, dynamic> doc) {
    final images = doc['images'] as List? ?? [];
    final videos = doc['videos'] as List? ?? [];
    final audios = doc['audios'] as List? ?? [];
    final status = doc['status'] ?? 'unknown';
    final severity = _getSeverityColor((doc['severity'] ?? 'low').toString());
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
        border: Border(left: BorderSide(color: severity, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
                children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: severity.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: severity.withOpacity(0.5)),
                        ),
                        child: Text(
                            (doc['type'] ?? 'INCIDENT').toString().toUpperCase(),
                            style: TextStyle(color: severity, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: status == 'resolved' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: status == 'resolved' ? Colors.green : Colors.orange),
                        ),
                        child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(
                                color: status == 'resolved' ? Colors.green : Colors.orange, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 12
                            ),
                        ),
                    ),
                    const Spacer(),
                    Text(
                        _formatTimestamp(doc['timestamp'] ?? doc['time']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                ],
            ),
            const SizedBox(height: 16),
            Text(
                doc['description'] ?? 'No description',
                style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
                children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Reporter: ${doc['user_name'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
            ),
            const SizedBox(height: 8),
            Row(
                children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(doc['location'] ?? 'Unknown location', style: TextStyle(color: Colors.grey[700])),
                ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Attached Evidence:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                    if (images.isNotEmpty)
                        ActionChip(
                            avatar: const Icon(Icons.image, size: 16),
                            label: Text('${images.length} Images'),
                            onPressed: () => _showMediaDialog(context, images, [], []),
                        ),
                    if (videos.isNotEmpty)
                        ActionChip(
                            avatar: const Icon(Icons.videocam, size: 16),
                            label: Text('${videos.length} Videos'),
                            onPressed: () => _showMediaDialog(context, [], videos, []),
                        ),
                    if (audios.isNotEmpty)
                        ActionChip(
                            avatar: const Icon(Icons.mic, size: 16),
                            label: Text('${audios.length} Audio Clips'),
                            onPressed: () => _showMediaDialog(context, [], [], audios),
                        ),
                     ElevatedButton.icon(
                        onPressed: () => _showMediaDialog(context, images, videos, audios),
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: const Text('View All Evidence'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                        ),
                    ),
                ],
            ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context, String userName, List<Map<String, dynamic>> messages) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Text(
                    'Conversation with $userName',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: messages.isEmpty 
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index];
                        final isUser = data['sender'] == 'user';
                        final message = data['message'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isUser)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.support_agent, size: 24, color: Color(0xFF1E3A8A)),
                                ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? const Color(0xFF1E3A8A)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (isUser)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.person, size: 24, color: Colors.grey),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMediaDialog(BuildContext context, List<dynamic> images, List<dynamic> videos, List<dynamic> audios) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          constraints: const BoxConstraints(maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Incident Media', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty) ...[
                        const Text('Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: images.map((url) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                url,
                                width: 220,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 220,
                                  height: 160,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (videos.isNotEmpty || audios.isNotEmpty) ...[
                        const Text('Other Media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...videos.map((url) => ListTile(
                          leading: const Icon(Icons.videocam, color: Color(0xFF1E3A8A)),
                          title: const Text('Incident Video'),
                          subtitle: Text(url.toString().split('/').last),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () async {
                             final uri = Uri.parse(url);
                             if (!await launchUrl(uri)) {
                               debugPrint('Could not launch $url');
                             }
                          },
                        )),
                        ...audios.map((url) => ListTile(
                          leading: const Icon(Icons.mic, color: Color(0xFF1E3A8A)),
                          title: const Text('Incident Audio'),
                          subtitle: Text(url.toString().split('/').last),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () async {
                             final uri = Uri.parse(url);
                             if (!await launchUrl(uri)) {
                               debugPrint('Could not launch $url');
                             }
                          },
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
