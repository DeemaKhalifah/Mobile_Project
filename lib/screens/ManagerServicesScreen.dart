import 'package:flutter/material.dart';
import 'dart:io';
import '../../styles/app_styles.dart';
import '../../styles/strings.dart';
import '../../services/api_service.dart';
import 'ManagerServiceDetailsScreen.dart';
import '../../services/shared_preferences_service.dart';
import 'package:image_picker/image_picker.dart';

class ManagerServicesScreen extends StatefulWidget {
  const ManagerServicesScreen({super.key});

  @override
  State<ManagerServicesScreen> createState() => _ManagerServicesScreenState();
}

class _ManagerServicesScreenState extends State<ManagerServicesScreen> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await ApiService.managerGetServices();
      setState(() => _services = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _safe(dynamic v) => (v ?? '').toString();

  Future<void> _openDialog({Map<String, dynamic>? service}) async {
    final isEdit = service != null;

    final nameCtrl = TextEditingController(text: _safe(service?['name']));
    final priceCtrl = TextEditingController(text: _safe(service?['price']));
    final imageCtrl = TextEditingController(text: _safe(service?['image']));
    final descCtrl = TextEditingController(
      text: _safe(service?['description']),
    );

    File? pickedFile;

    Future<void> pickImage(StateSetter setDialogState) async {
      final picker = ImagePicker();
      final XFile? x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return;
      setDialogState(() {
        pickedFile = File(x.path);
      });
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? AppStrings.edit : AppStrings.services),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: AppStrings.name),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.price,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Image",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => pickImage(setDialogState),
                        icon: const Icon(Icons.image),
                        label: const Text("Pick Image"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (pickedFile != null)
                      IconButton(
                        tooltip: "Remove",
                        onPressed: () =>
                            setDialogState(() => pickedFile = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (pickedFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      pickedFile!,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Text(
                    imageCtrl.text.trim().isEmpty
                        ? "No image selected"
                        : (isEdit
                              ? "Current: ${imageCtrl.text.trim()}"
                              : "No image selected"),
                    style: const TextStyle(color: Colors.black54),
                  ),

                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.description,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              style: AppStyles.primaryButtonStyleRounded,
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.error)),
                  );
                  return;
                }

                try {
                  Map<String, dynamic> res;

                  if (isEdit) {
                    final id = int.tryParse(_safe(service['id'])) ?? 0;
                    if (id == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppStrings.error)),
                      );
                      return;
                    }

                    res = await ApiService.managerUpdateServiceMultipart(
                      id: id,
                      name: name,
                      price: price,
                      description: descCtrl.text.trim(),
                      imageFile: pickedFile,
                      imageValueIfNoFile: imageCtrl.text.trim(),
                    );
                  } else {
                    res = await ApiService.managerAddServiceMultipart(
                      name: name,
                      price: price,
                      description: descCtrl.text.trim(),
                      imageFile: pickedFile,
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _safe(res['message']).isEmpty
                            ? AppStrings.success
                            : _safe(res['message']),
                      ),
                    ),
                  );

                  if (mounted) Navigator.pop(context);
                  _load();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AppStrings.error)));
                }
              },
              child: const Text(AppStrings.done),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(Map<String, dynamic> service) async {
    final refreshed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagerServiceDetailsScreen(service: service),
      ),
    );

    if (refreshed == true) _load();
  }

  Future<void> _logout() async {
    // 1) Show confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.logout),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Cancel

    // 2) Do logout
    await SharedPreferencesService.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: const Text(AppStrings.services),

        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),

        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDialog(),
        backgroundColor: const Color(0xFF89CFF0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _services.isEmpty
          ? const Center(child: Text("No services found"))
          : ListView.builder(
              padding: const EdgeInsets.all(AppStyles.standardPadding16),
              itemCount: _services.length,
              itemBuilder: (_, i) {
                final s = _services[i];
                return Card(
                  shape: AppStyles.cardShape,
                  child: ListTile(
                    onTap: () => _openDetails(s),
                    title: Text(_safe(s['name'])),
                    subtitle: Text("Price: ${_safe(s['price'])}"),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
