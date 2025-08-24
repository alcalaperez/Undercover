import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/preferences_service.dart';

class QuickNameSuggestionsDialog extends StatefulWidget {
  final Function(String) onNameSelected;
  final List<String> existingNames;

  const QuickNameSuggestionsDialog({
    super.key,
    required this.onNameSelected,
    required this.existingNames,
  });

  @override
  State<QuickNameSuggestionsDialog> createState() => _QuickNameSuggestionsDialogState();
}

class _QuickNameSuggestionsDialogState extends State<QuickNameSuggestionsDialog> {
  List<String> _availableNames = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableNames();
  }

  void _loadAvailableNames() {
    final quickNames = PreferencesService.instance.getQuickNames();
    setState(() {
      _availableNames = quickNames
          .where((name) => !widget.existingNames.contains(name))
          .toList();
    });
  }

  List<String> get _filteredNames {
    if (_searchQuery.isEmpty) {
      return _availableNames;
    }
    return _availableNames
        .where((name) => name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNames = _filteredNames;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Names',
                  style: AppTextStyles.h3,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search names',
                hintText: 'Type to filter names',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Names list
            Expanded(
              child: filteredNames.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No names match "$_searchQuery"'
                                : 'No available names',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: filteredNames.length,
                      itemBuilder: (context, index) {
                        final name = filteredNames[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              widget.onNameSelected(name);
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  name,
                                  style: AppTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Footer info
            Text(
              '${filteredNames.length} names available',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}