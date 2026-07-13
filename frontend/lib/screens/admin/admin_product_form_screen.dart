import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product; // If null, it's create mode. If provided, it's edit mode.

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _salePriceCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imageUrlCtrl;
  
  String _selectedCategory = 'skincare';
  final List<String> _categories = ['skincare', 'makeup', 'perfume', 'accessories'];
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?['name']?.toString() ?? '');
    _priceCtrl = TextEditingController(text: p?['price']?.toString() ?? '0');
    _salePriceCtrl = TextEditingController(text: p?['sale_price']?.toString() ?? '0');
    _brandCtrl = TextEditingController(text: p?['brand']?.toString() ?? '');
    _skuCtrl = TextEditingController(text: p?['sku']?.toString() ?? '');
    _descCtrl = TextEditingController(text: p?['description']?.toString() ?? '');
    _stockCtrl = TextEditingController(text: p?['stock']?.toString() ?? '0');
    
    String imgUrl = '';
    if (p != null && p['images'] != null && (p['images'] as List).isNotEmpty) {
      imgUrl = p['images'][0].toString();
    }
    _imageUrlCtrl = TextEditingController(text: imgUrl);

    if (p != null && p['category'] != null) {
      if (_categories.contains(p['category'])) {
        _selectedCategory = p['category'];
      }
    }
    _isActive = p?['is_active'] ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _brandCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final data = <String, dynamic>{
      'name': _nameCtrl.text,
      'price': num.tryParse(_priceCtrl.text) ?? 0,
      'sale_price': num.tryParse(_salePriceCtrl.text) ?? 0,
      'brand': _brandCtrl.text,
      'sku': _skuCtrl.text,
      'description': _descCtrl.text,
      'stock': num.tryParse(_stockCtrl.text) ?? 0,
      'category': _selectedCategory,
      'category_id': 'cat_$_selectedCategory',
      'images': [_imageUrlCtrl.text],
      'is_active': _isActive,
    };

    try {
      if (widget.product == null) {
        await context.read<ProductProvider>().createProduct(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm thành công')));
      } else {
        await context.read<ProductProvider>().updateProduct(widget.product!['id'], data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Vui lòng nhập $label';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Thêm Sản Phẩm' : 'Sửa Sản Phẩm'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameCtrl, 'Tên sản phẩm'),
              _buildTextField(_priceCtrl, 'Giá', isNumber: true),
              _buildTextField(_salePriceCtrl, 'Giá khuyến mãi (nếu có)', isNumber: true),
              _buildTextField(_brandCtrl, 'Thương hiệu'),
              _buildTextField(_skuCtrl, 'SKU'),
              _buildTextField(_descCtrl, 'Mô tả', maxLines: 3),
              _buildTextField(_stockCtrl, 'Số lượng tồn kho', isNumber: true),
              _buildTextField(_imageUrlCtrl, 'URL Hình ảnh'),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.toUpperCase()))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Đang hiển thị (is_active)'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                  child: const Text('Lưu Sản Phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
