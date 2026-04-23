import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/models/okhi_location_manager_configuration.dart';
import 'package:okhi_flutter/okhi_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OkHiDemoApp());
}

// ---------------------------------------------------------------------------
// Root app
// ---------------------------------------------------------------------------
class OkHiDemoApp extends StatelessWidget {
  const OkHiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OkHi Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF008080),
        useMaterial3: true,
      ),
      home: const OkHiHomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Home page — full OkHi lifecycle
// ---------------------------------------------------------------------------
class OkHiHomePage extends StatefulWidget {
  const OkHiHomePage({super.key});

  @override
  State<OkHiHomePage> createState() => _OkHiHomePageState();
}

class _OkHiHomePageState extends State<OkHiHomePage> {
  // ── Scaffold messenger key for SnackBars from async callbacks ────────────
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // ── UI state ─────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isUserSet = false;

  // ── OkHi state ───────────────────────────────────────────────────────────
  OkHiEnv _selectedEnv = OkHiEnv.sandbox;
  String _appUserId = '';
  String _userId = '';
  String _savedAddressId = '';
  OkHiLocation? _savedLocation;

  // ── Text controllers ──────────────────────────────────────────────────────
  final _phoneCtrl = TextEditingController(text: '+254');
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _appUserIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _branchIdCtrl = TextEditingController();
  final _clientKeyCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _appUserIdCtrl.dispose();
    _emailCtrl.dispose();
    _branchIdCtrl.dispose();
    _clientKeyCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) => setState(() => _isLoading = value);

  void _showSnackBar(String message, {bool isError = false}) {
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[700] : Colors.teal[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showSnackBarError(String message) =>
      _showSnackBar(message, isError: true);

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied to clipboard');
  }

  // ── OkHi config builder ───────────────────────────────────────────────────

  OkHiAppConfiguration _getConfig() => OkHiAppConfiguration(
    branchId: _branchIdCtrl.text.trim(),
    clientKey: _clientKeyCtrl.text.trim(),
    env: _selectedEnv,
  );

  OkHiUser _getUser() => OkHiUser(
    phone: _phoneCtrl.text.trim(),
    firstName: _firstNameCtrl.text.trim(),
    lastName: _lastNameCtrl.text.trim(),
    appUserId: _appUserIdCtrl.text.trim(),
    email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    id: _userId.isEmpty ? null : _userId,
  );

  OkHiLocationManagerConfiguration _getLocationManagerConfig() =>
      OkHiLocationManagerConfiguration(
        color: '#008080',
        appName: 'OkHi Flutter Demo',
        logoUrl: 'https://cdn.okhi.co/icon.png',
        withAppBar: true,
        withCreateMode: true,
        withHomeAddressType: true,
        withWorkAddressType: false,
        withStreetView: true,
      );

  // ── Permission actions ────────────────────────────────────────────────────

  Future<void> _requestLocationServices() async {
    _setLoading(true);
    final granted = await OkHi.requestEnableLocationServices();
    _setLoading(false);
    _showSnackBar(granted ? 'Location services enabled' : 'Not enabled');
  }

  Future<void> _requestLocationPermission() async {
    _setLoading(true);
    final granted = await OkHi.requestLocationPermission();
    _setLoading(false);
    _showSnackBar(
      granted ? 'Location permission granted' : 'Permission denied',
    );
  }

  Future<void> _requestBackgroundPermission() async {
    _setLoading(true);
    final granted = await OkHi.requestBackgroundLocationPermission();
    _setLoading(false);
    _showSnackBar(
      granted ? 'Background permission granted' : 'Permission denied',
    );
  }

  Future<void> _requestProtectedAppsPermission() async {
    _setLoading(true);
    final canOpen = await OkHi.canOpenProtectedApps();
    bool granted = false;
    if (canOpen) {
      await OkHi.openProtectedApps();
      granted = true;
    }
    _setLoading(false);
    _showSnackBar(
      granted ? 'Protected Apps permission granted' : 'Permission denied',
    );
  }

  // ── OkHi login ────────────────────────────────────────────────────────────

  Future<void> _login() async {
    if (_branchIdCtrl.text.trim().isEmpty ||
        _clientKeyCtrl.text.trim().isEmpty) {
      _showSnackBarError('Branch ID and Client Key are required');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty ||
        _firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _appUserIdCtrl.text.trim().isEmpty) {
      _showSnackBarError(
        'Phone, first name, last name and app user ID are required',
      );
      return;
    }

    _setLoading(true);
    OkHi.login(_getConfig(), _getUser(), _getLocationManagerConfig())
        .then((result) {
          setState(() {
            _isUserSet = true;
            _appUserId = _appUserIdCtrl.text.trim();
          });
          _setLoading(false);
          _showSnackBar('Login successful');
        })
        .onError((error, stackTrace) {
          _setLoading(false);
          if (error is OkHiException) {
            _showSnackBarError('[${error.code}] ${error.message}');
          } else {
            _showSnackBarError(error.toString());
          }
        });
  }

  // ── OkHi logout ───────────────────────────────────────────────────────────

  Future<void> _logout() async {
    _setLoading(true);
    OkHi.logout()
        .then((result) {
          setState(() {
            _isUserSet = false;
            _appUserId = '';
            _userId = '';
            _savedAddressId = '';
            _savedLocation = null;
          });
          _setLoading(false);
          _showSnackBar('Logged out');
        })
        .onError((error, stackTrace) {
          _setLoading(false);
          if (error is OkHiException) {
            _showSnackBarError('[${error.code}] ${error.message}');
          } else {
            _showSnackBarError(error.toString());
          }
        });
  }

  // ── Address operations ────────────────────────────────────────────────────

  void _onAddressSuccess(dynamic user, dynamic location) {
    final loc = location as OkHiLocation;
    final locationId = loc.id ?? '';
    setState(() {
      _savedAddressId = locationId;
      _savedLocation = loc;
    });
    _setLoading(false);
    _copyToClipboard(locationId, 'Location ID');
    _showSnackBar('Success — Location ID: $locationId');
  }

  void _onAddressError(OkHiException error) {
    _setLoading(false);
    _showSnackBarError('[${error.code}] ${error.message}');
  }

  Future<void> _startDigitalVerification() async {
    _setLoading(true);
    OkHi.startDigitalAddressVerification(
      locationId: _savedAddressId.isEmpty ? null : _savedAddressId,
      onSuccess: _onAddressSuccess,
      onError: _onAddressError,
    );
  }

  Future<void> _startPhysicalVerification() async {
    _setLoading(true);
    OkHi.startPhysicalAddressVerification(
      onSuccess: _onAddressSuccess,
      onError: _onAddressError,
    );
  }

  Future<void> _startDigitalAndPhysicalVerification() async {
    _setLoading(true);
    OkHi.startDigitalAndPhysicalAddressVerification(
      onSuccess: _onAddressSuccess,
      onError: _onAddressError,
    );
  }

  Future<void> _createAddress() async {
    _setLoading(true);
    OkHi.createAddress(onSuccess: _onAddressSuccess, onError: _onAddressError);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OkHi Flutter Demo'),
          centerTitle: true,
          backgroundColor: const Color(0xFF008080),
          foregroundColor: Colors.white,
          actions: [
            if (_isUserSet)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: _isLoading ? null : _logout,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Status chip ──────────────────────────────────────
                    _StatusChip(isLoggedIn: _isUserSet, appUserId: _appUserId),
                    const SizedBox(height: 20),

                    // ── Credentials section ──────────────────────────────
                    if (!_isUserSet) ...[
                      _SectionHeader('Environment'),
                      _EnvSelector(
                        selected: _selectedEnv,
                        onChanged: (env) => setState(() => _selectedEnv = env),
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader('App Credentials'),
                      _buildTextField(
                        _branchIdCtrl,
                        'Branch ID',
                        Icons.vpn_key,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _clientKeyCtrl,
                        'Client Key',
                        Icons.lock_outline,
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader('User Details'),
                      _buildTextField(
                        _phoneCtrl,
                        'Phone (+2547...)',
                        Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _firstNameCtrl,
                        'First Name',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _lastNameCtrl,
                        'Last Name',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _appUserIdCtrl,
                        'App User ID',
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _emailCtrl,
                        'Email (optional)',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                        style: _primaryButtonStyle(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Permissions section ──────────────────────────────
                    _SectionHeader('Permissions'),
                    _PermissionRow(
                      label: 'Enable Location Services',
                      icon: Icons.location_on_outlined,
                      onTap: _isLoading ? null : _requestLocationServices,
                    ),
                    const SizedBox(height: 8),
                    _PermissionRow(
                      label: 'Request Location Permission',
                      icon: Icons.my_location,
                      onTap: _isLoading ? null : _requestLocationPermission,
                    ),
                    const SizedBox(height: 8),
                    _PermissionRow(
                      label: 'Request Background Location',
                      icon: Icons.gps_fixed,
                      onTap: _isLoading ? null : _requestBackgroundPermission,
                    ),
                    const SizedBox(height: 8),
                    _PermissionRow(
                      label: 'Request Protected Apps Permission',
                      icon: Icons.shield_outlined,
                      onTap: _isLoading
                          ? null
                          : _requestProtectedAppsPermission,
                    ),

                    if (_isUserSet) ...[
                      const SizedBox(height: 24),
                      // ── Address operations ───────────────────────────
                      _SectionHeader('Address Verification'),
                      _ActionButton(
                        label: 'Digital Verification',
                        icon: Icons.verified_outlined,
                        subtitle: _savedAddressId.isEmpty
                            ? 'Creates a new address'
                            : 'Re-verifying: ${_savedAddressId.substring(0, 8)}…',
                        onTap: _startDigitalVerification,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Physical Verification',
                        icon: Icons.home_work_outlined,
                        subtitle: 'Schedule a physical visit',
                        onTap: _startPhysicalVerification,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Digital + Physical',
                        icon: Icons.sync_alt,
                        subtitle: 'Both verification methods',
                        onTap: _startDigitalAndPhysicalVerification,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Create Address Only',
                        icon: Icons.add_location_alt_outlined,
                        subtitle: 'No verification — address book only',
                        onTap: _createAddress,
                      ),

                      // ── Saved address ────────────────────────────────
                      if (_savedLocation != null) ...[
                        const SizedBox(height: 24),
                        _SectionHeader('Saved Address'),
                        _OkHiLocationCard(
                          location: _savedLocation!,
                          onCopy: _copyToClipboard,
                        ),
                      ],

                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF008080),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    textStyle: const TextStyle(fontSize: 16),
  );
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Color(0xFF008080),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isLoggedIn;
  final String appUserId;
  const _StatusChip({required this.isLoggedIn, required this.appUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLoggedIn
            ? Colors.teal.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLoggedIn ? Colors.teal : Colors.orange),
      ),
      child: Row(
        children: [
          Icon(
            isLoggedIn ? Icons.check_circle_outline : Icons.info_outline,
            color: isLoggedIn ? Colors.teal : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLoggedIn
                  ? 'Logged in as $appUserId'
                  : 'Not logged in — fill in credentials below',
              style: TextStyle(
                color: isLoggedIn ? Colors.teal[800] : Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvSelector extends StatelessWidget {
  final OkHiEnv selected;
  final ValueChanged<OkHiEnv> onChanged;

  const _EnvSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<OkHiEnv>(
      segments: const [
        ButtonSegment(value: OkHiEnv.dev, label: Text('Dev')),
        ButtonSegment(value: OkHiEnv.sandbox, label: Text('Sandbox')),
        ButtonSegment(value: OkHiEnv.prod, label: Text('Prod')),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PermissionRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF008080),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _OkHiLocationCard extends StatelessWidget {
  final OkHiLocation location;
  final Future<void> Function(String text, String label) onCopy;

  const _OkHiLocationCard({required this.location, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF008080)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.title ?? location.id ?? 'Location',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (location.id != null)
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    tooltip: 'Copy location ID',
                    onPressed: () => onCopy(location.id!, 'Location ID'),
                  ),
              ],
            ),
            const Divider(),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        row.$1,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(row.$2, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _buildRows() {
    String fmt(double? v) => v?.toStringAsFixed(6) ?? '—';

    return [
      ('ID', location.id ?? '—'),
      ('Lat / Lng', '${fmt(location.lat)}, ${fmt(location.lng)}'),
      if (location.title != null) ('Title', location.title!),
      if (location.subtitle != null) ('Subtitle', location.subtitle!),
      if (location.displayTitle != null)
        ('Display Title', location.displayTitle!),
      if (location.formattedAddress != null)
        ('Formatted Address', location.formattedAddress!),
      if (location.addressLine != null) ('Address Line', location.addressLine!),
      if (location.propertyNumber != null)
        ('Property No.', location.propertyNumber!),
      if (location.propertyName != null)
        ('Property Name', location.propertyName!),
      if (location.streetName != null) ('Street', location.streetName!),
      if (location.neighborhood != null)
        ('Neighborhood', location.neighborhood!),
      if (location.ward != null && location.ward!.isNotEmpty)
        ('Ward', location.ward!),
      if (location.lga != null) ('LGA', location.lga!),
      if (location.lgaCode != null) ('LGA Code', location.lgaCode!),
      if (location.district != null && location.district!.isNotEmpty)
        ('District', location.district!),
      if (location.city != null) ('City', location.city!),
      if (location.state != null) ('State', location.state!),
      if (location.country != null) ('Country', location.country!),
      if (location.countryCode != null) ('Country Code', location.countryCode!),
      if (location.postCode != null) ('Post Code', location.postCode!),
      if (location.plusCode != null) ('Plus Code', location.plusCode!),
      if (location.directions != null && location.directions!.isNotEmpty)
        ('Directions', location.directions!),
      if (location.otherInformation != null)
        ('Other Info', location.otherInformation!),
      if (location.businessName != null)
        ('Business Name', location.businessName!),
      if (location.unit != null && location.unit!.isNotEmpty)
        ('Unit', location.unit!),
      if (location.type != null && location.type!.isNotEmpty)
        ('Type', location.type!),
      if (location.gpsAccuracy != null) ('GPS Accuracy', location.gpsAccuracy!),
      if (location.usageTypes != null && location.usageTypes!.isNotEmpty)
        ('Usage Types', location.usageTypes!.join(', ')),
      if (location.placeId != null) ('Place ID', location.placeId!),
      if (location.url != null) ('URL', location.url!),
      if (location.photoUrl != null) ('Photo URL', location.photoUrl!),
      if (location.streetViewPanoId != null)
        ('Street View Pano ID', location.streetViewPanoId!),
      if (location.userId != null) ('User ID', location.userId!),
    ];
  }
}
