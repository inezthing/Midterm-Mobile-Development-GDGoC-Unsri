import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'cart_page.dart';

class ExplorePage extends StatefulWidget {
  final String? initialCategory;
  const ExplorePage({super.key, this.initialCategory});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All', 'Woman Fashion', 'Man Fashion', 'Health & Beauty',
    'Keychain', 'Trinket', 'Shoes', 'Playing Card', 'Sticker',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFiltered(List<Product> all) {
    List<Product> products = _query.isEmpty
        ? all
        : all.where((p) {
            final q = _query.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.sellerName.toLowerCase().contains(q);
          }).toList();
    if (_selectedCategory != 'All') {
      products =
          products.where((p) => p.category == _selectedCategory).toList();
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Search + Cart ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Kolom pencarian produk',
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2D1B2E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2D1B2E),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama, brand, kategori...',
                            hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[400],
                                fontSize: 13),
                            prefixIcon: const Icon(Icons.search,
                                color: AppTheme.primary, size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 16, color: Colors.grey),
                                    onPressed: () {
                                      setState(() => _query = '');
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Consumer<AppState>(
                    builder: (context, state, _) => Semantics(
                      label: 'Keranjang, ${state.cartCount} item',
                      button: true,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const CartPage())),
                        child: Stack(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2D1B2E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.shopping_bag_outlined,
                                  color: AppTheme.primary, size: 22),
                            ),
                            if (state.cartCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle),
                                  child: Text(
                                    '${state.cartCount}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter kategori ────────────────────────────────────────
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark
                                  ? Colors.white24
                                  : Colors.grey[300]!),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white60
                                  : Colors.grey[600]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Grid dengan LayoutBuilder ─────────────────────────────
            Expanded(
              child: Selector<AppState, List<Product>>(
                selector: (_, state) => state.products,
                builder: (context, allProducts, _) {
                  final filtered = _getFiltered(allProducts);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[500]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba kata kunci lain',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (_query.isNotEmpty || _selectedCategory != 'All')
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${filtered.length} produk ditemukan',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      // LayoutBuilder untuk breakpoint responsif (rubrik C)
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenW =
                                MediaQuery.of(context).size.width;
                            int cols;
                            if (screenW >= 1000) {
                              cols = 4;
                            } else if (screenW >= 600) {
                              cols = 3;
                            } else {
                              cols = 2;
                            }
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) =>
                                  ProductCard(product: filtered[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
