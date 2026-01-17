import 'package:flutter/material.dart';
import 'dart:io';
import '../../styles/app_styles.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';
import 'package:image_picker/image_picker.dart';

class ManagerServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  const ManagerServiceDetailsScreen({super.key, required this.service});

  @override
  State<ManagerServiceDetailsScreen> createState() =>
      _ManagerServiceDetailsScreenState();
}

class _ManagerServiceDetailsScreenState
    extends State<ManagerServiceDetailsScreen> {
  String _safe(dynamic v) => (v ?? '').toString();

  bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');

  String _toServerUrl(String img) {
    final v = img.trim();
    if (v.isEmpty) return '';
    if (_isHttp(v)) return v;
    if (v.startsWith('/')) {
      return '${ApiService.baseUrl}$v';
    }
    if (v.startsWith('uploads/')) {
      return '${ApiService.baseUrl}/$v';
    }
    return '${ApiService.baseUrl}/uploads/$v';
  }

  String _toAssetPath(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (v.startsWith('assets/')) return v;
    if (v.contains('/')) return 'assets/$v';
    return 'assets/images/$v';
  }

  Widget _serviceImage(String rawImage) {
    final img = rawImage.trim();

    if (img.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("No image"),
      );
    }

    final assetPath = _toAssetPath(img);
    final serverUrl = _toServerUrl(img);

    if (_isHttp(img)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          img,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 180,
            alignment: Alignment.center,
            color: Colors.grey[200],
            child: const Text("Image not available"),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        serverUrl,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            assetPath,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: Text(
                "Image not available\nServer: $serverUrl\nAsset: $assetPath",
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editServiceDialog() async {
    final s = widget.service;

    final nameCtrl = TextEditingController(text: _safe(s['name']));
    final priceCtrl = TextEditingController(text: _safe(s['price']));
    final imageCtrl = TextEditingController(text: _safe(s['image']));
    final descCtrl = TextEditingController(text: _safe(s['description']));

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
          title: const Text("Edit Service"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Price"),
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
                        : "Current: ${imageCtrl.text.trim()}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: AppStyles.primaryButtonStyleRounded,
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final id = int.tryParse(_safe(s['id'])) ?? 0;

                if (id == 0 || name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter valid name & price")),
                  );
                  return;
                }

                try {
                  final res = await ApiService.managerUpdateServiceMultipart(
                    id: id,
                    name: name,
                    price: price,
                    description: descCtrl.text.trim(),
                    imageFile: pickedFile,
                    imageValueIfNoFile: imageCtrl.text.trim(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _safe(res['message']).isEmpty
                            ? "Updated"
                            : _safe(res['message']),
                      ),
                    ),
                  );

                  if (!mounted) return;

                  Navigator.pop(context);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Failed: $e")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final id = int.tryParse(_safe(widget.service['id'])) ?? 0;
    if (id == 0) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Service"),
        content: const Text("Are you sure you want to delete this service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: AppStyles.primaryButtonStyleRounded,
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final res = await ApiService.managerDeleteService(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _safe(res['message']).isEmpty ? "Deleted" : _safe(res['message']),
          ),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  Future<void> _logout() async {
    // 1) Show confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
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
    final s = widget.service;

    final name = _safe(s['name']);
    final price = _safe(s['price']);
    final image = _safe(s['image']);
    final desc = _safe(s['description']);

    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: const Text("Service Details"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding16),
        child: Card(
          shape: AppStyles.cardShape,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  name.isEmpty ? "Unnamed Service" : name,
                  style: AppStyles.titleStyle,
                ),
                const SizedBox(height: 8),
                Text("Price: $price", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                _serviceImage(image),
                const SizedBox(height: 16),
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(desc.isEmpty ? "No description" : desc),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: AppStyles.primaryButtonStyleRounded,
                        onPressed: _editServiceDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
