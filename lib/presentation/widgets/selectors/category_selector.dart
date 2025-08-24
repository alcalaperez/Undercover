import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/repositories/word_repository.dart';

class CategorySelector extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onSelectionChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<String> _allCategories = [];
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      await WordRepository.instance.initialize();
      final categories = WordRepository.instance.getAllCategories();
      final counts = WordRepository.instance.getCategoryCounts();
      
      setState(() {
        _allCategories = categories;
        _categoryCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleCategory(String category) {
    final selectedCategories = List<String>.from(widget.selectedCategories);
    
    if (selectedCategories.contains(category)) {
      if (selectedCategories.length > 1) {
        selectedCategories.remove(category);
      }
    } else {
      selectedCategories.add(category);
    }
    
    widget.onSelectionChanged(selectedCategories);
  }

  void _selectAll() {
    widget.onSelectionChanged(List.from(_allCategories));
  }

  void _selectNone() {
    if (widget.selectedCategories.length > 1) {
      widget.onSelectionChanged([widget.selectedCategories.first]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Word Categories',
              style: AppTextStyles.labelLarge,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _selectAll,
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: _selectNone,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allCategories.map((category) {
            final isSelected = widget.selectedCategories.contains(category);
            final wordCount = _categoryCounts[category] ?? 0;
            final isLastSelected = widget.selectedCategories.length == 1 && isSelected;
            
            return FilterChip(
              label: Text(
                '$category ($wordCount)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
              selected: isSelected,
              onSelected: isLastSelected ? null : (selected) {
                _toggleCategory(category);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? AppColors.primary 
                      : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '${widget.selectedCategories.length} categories selected • '
          '${_getTotalWordCount()} word pairs available',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
        if (widget.selectedCategories.length == 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'At least one category must be selected',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
      ],
    );
  }

  int _getTotalWordCount() {
    return widget.selectedCategories
        .map((category) => _categoryCounts[category] ?? 0)
        .fold(0, (sum, count) => sum + count);
  }
}