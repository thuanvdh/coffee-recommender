import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:coffee_recommender/core/theme/app_colors.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';

class SuggestScreen extends ConsumerStatefulWidget {
  const SuggestScreen({super.key});

  @override
  ConsumerState<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends ConsumerState<SuggestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contributorNameController = TextEditingController();
  final _contributorEmailController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedDistrict = 'Hải Châu';
  TimeOfDay _openTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);

  int _minPrice = 25000;
  int _maxPrice = 65000;

  // Selected Tags
  final List<String> _selectedPurposes = [];
  final List<String> _selectedSpaces = [];
  final List<String> _selectedAmenities = [];

  // Dynamic drinks list
  final List<Map<String, String>> _drinks = [];

  // Form Submission States
  bool _isLoading = false;
  bool _isSubmitted = false;

  // Static tags for display (fallback if api isn't loaded)
  final List<String> _purposes = [
    'Học tập/Làm việc',
    'Gặp gỡ bạn bè',
    'Hẹn hò',
    'Đọc sách',
    'Sống ảo',
    'Trò chuyện gia đình'
  ];

  final List<String> _spaces = [
    'Sân vườn',
    'Máy lạnh',
    'Trong nhà',
    'Yên tĩnh',
    'Tối giản',
    'Cổ điển',
    'Hiện đại',
    'Tầng thượng'
  ];

  final List<String> _amenities = [
    'Wifi mạnh',
    'Bàn ghế cao',
    'Máy lạnh tốt',
    'View đẹp',
    'Chỗ đậu ô tô',
    'Ổ cắm điện mọi bàn',
    'Thức ăn nhẹ',
    'Mở cửa khuya'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _contributorNameController.dispose();
    _contributorEmailController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _toggleTag(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _addDrink() {
    setState(() {
      _drinks.add({'name': '', 'price': ''});
    });
  }

  void _removeDrink(int index) {
    setState(() {
      _drinks.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final openStr = _formatTimeOfDay(_openTime);
    final closeStr = _formatTimeOfDay(_closeTime);
    final openingHours = '$openStr - $closeStr';

    final priceRange = '${_minPrice.toString()}đ - ${_maxPrice.toString()}đ';

    final drinkList = _drinks
        .where((d) => d['name']!.trim().isNotEmpty)
        .map((d) => {
              'name': d['name']!.trim(),
              'price': d['price']!.trim(),
            })
        .toList();

    final data = {
      'shop_name': _nameController.text.trim(),
      'district': _selectedDistrict,
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'image_url': _imageUrlController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb'
          : _imageUrlController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'opening_hours': openingHours,
      'price_range': priceRange,
      'purposes': _selectedPurposes,
      'spaces': _selectedSpaces,
      'amenities': _selectedAmenities,
      'drinks': drinkList,
      'contributor_name': _contributorNameController.text.trim().isEmpty
          ? null
          : _contributorNameController.text.trim(),
      'contributor_email': _contributorEmailController.text.trim().isEmpty
          ? null
          : _contributorEmailController.text.trim(),
      'reason': _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    };

    final notifier = ref.read(searchNotifierProvider.notifier);
    final success = await notifier.submitSuggestion(data);

    setState(() {
      _isLoading = false;
      if (success) {
        _isSubmitted = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Không thể gửi đề xuất. Vui lòng kiểm tra lại thông tin.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _contributorNameController.clear();
      _contributorEmailController.clear();
      _reasonController.clear();
      _selectedDistrict = 'Hải Châu';
      _openTime = const TimeOfDay(hour: 7, minute: 0);
      _closeTime = const TimeOfDay(hour: 22, minute: 0);
      _minPrice = 25000;
      _maxPrice = 65000;
      _selectedPurposes.clear();
      _selectedSpaces.clear();
      _selectedAmenities.clear();
      _drinks.clear();
      _isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textLightColor =
        isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final cardBgColor = isDark ? AppColors.darkBgLight : AppColors.lightBgLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (_isSubmitted) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.circle_check,
                    size: 64,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cảm ơn bạn đã đóng góp!',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Thông tin quán đã được gửi đến đội ngũ của chúng mình để kiểm duyệt.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textLightColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _resetForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Gửi thêm đề xuất'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất quán mới'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Intro Banner
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đóng góp cộng đồng',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chia sẻ quán yêu thích của bạn',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gửi thông tin quán cà phê bạn tâm đắc. Đội ngũ admin sẽ duyệt và đưa quán lên bản đồ Danang Coffee nhé!',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textLightColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 1: Basic Info
                _SectionHeader(
                    icon: LucideIcons.map_pin,
                    title: 'Thông tin cơ bản',
                    color: primaryColor),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên quán cà phê *',
                    hintText: 'Ví dụ: Lumi Lab',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Vui lòng nhập tên quán'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDistrict,
                        decoration: const InputDecoration(
                          labelText: 'Quận *',
                        ),
                        items: [
                          'Hải Châu',
                          'Thanh Khê',
                          'Sơn Trà',
                          'Ngũ Hành Sơn',
                          'Liên Chiểu',
                          'Cẩm Lệ'
                        ]
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDistrict = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          hintText: '0905...',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ chi tiết *',
                    hintText: 'Ví dụ: 99 Lê Lợi',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Vui lòng nhập địa chỉ'
                      : null,
                ),
                const SizedBox(height: 20),

                // Section 2: Hours & Prices
                _SectionHeader(
                    icon: LucideIcons.clock,
                    title: 'Hoạt động & Giá cả',
                    color: primaryColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Giờ mở cửa *',
                          ),
                          child: Text(_formatTimeOfDay(_openTime)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Giờ đóng cửa *',
                          ),
                          child: Text(_formatTimeOfDay(_closeTime)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _minPrice.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá thấp nhất (VNĐ) *',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Nhập giá tối thiểu';
                          }
                          final num = int.tryParse(val);
                          if (num == null) {
                            return 'Sai định dạng';
                          }
                          return null;
                        },
                        onChanged: (val) => _minPrice = int.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _maxPrice.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá cao nhất (VNĐ) *',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Nhập giá tối đa';
                          }
                          final num = int.tryParse(val);
                          if (num == null) {
                            return 'Sai định dạng';
                          }
                          if (num < _minPrice) {
                            return 'Phải lớn hơn giá tối thiểu';
                          }
                          return null;
                        },
                        onChanged: (val) => _maxPrice = int.tryParse(val) ?? 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Section 3: Tags
                _SectionHeader(
                    icon: LucideIcons.tags,
                    title: 'Tags phân loại',
                    color: primaryColor),
                const SizedBox(height: 12),
                Text(
                  'Mục đích',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: primaryColor),
                ),
                const SizedBox(height: 6),
                _TagChips(
                  source: _purposes,
                  selected: _selectedPurposes,
                  activeColor: accentColor,
                  onSelected: (tag) => _toggleTag(_selectedPurposes, tag),
                ),
                const SizedBox(height: 12),
                Text(
                  'Không gian',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: primaryColor),
                ),
                const SizedBox(height: 6),
                _TagChips(
                  source: _spaces,
                  selected: _selectedSpaces,
                  activeColor: accentColor,
                  onSelected: (tag) => _toggleTag(_selectedSpaces, tag),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tiện ích',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: primaryColor),
                ),
                const SizedBox(height: 6),
                _TagChips(
                  source: _amenities,
                  selected: _selectedAmenities,
                  activeColor: accentColor,
                  onSelected: (tag) => _toggleTag(_selectedAmenities, tag),
                ),
                const SizedBox(height: 20),

                // Section 4: Signature Drinks
                _SectionHeader(
                    icon: LucideIcons.coffee,
                    title: 'Thức uống nổi bật',
                    color: primaryColor),
                const SizedBox(height: 12),
                ...List.generate(_drinks.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Tên món',
                              hintText: 'VD: Cà phê muối',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            onChanged: (val) => _drinks[idx]['name'] = val,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Giá (VD: 35000)',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            onChanged: (val) => _drinks[idx]['price'] = val,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash_2,
                              color: Colors.redAccent),
                          onPressed: () => _removeDrink(idx),
                        )
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addDrink,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Thêm món nước'),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section 5: Media & Desc
                _SectionHeader(
                    icon: LucideIcons.image,
                    title: 'Hình ảnh & Mô tả',
                    color: primaryColor),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Ảnh đại diện quán',
                    hintText: 'Nhập link ảnh (unsplash, imgur...)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Giới thiệu ngắn về quán',
                    hintText:
                        'Không không gian chill, hợp làm việc, nhiều góc checkin...',
                  ),
                ),
                const SizedBox(height: 20),

                // Section 6: Contributor Info
                _SectionHeader(
                    icon: LucideIcons.user,
                    title: 'Thông tin người đề xuất',
                    color: primaryColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contributorNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên của bạn',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _contributorEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email liên hệ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Lý do bạn đề xuất quán này?',
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Gửi đề xuất ngay'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TagChips extends StatelessWidget {
  const _TagChips({
    required this.source,
    required this.selected,
    required this.activeColor,
    required this.onSelected,
  });

  final List<String> source;
  final List<String> selected;
  final Color activeColor;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: source.map((tag) {
        final isSelected = selected.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => onSelected(tag),
        );
      }).toList(),
    );
  }
}
