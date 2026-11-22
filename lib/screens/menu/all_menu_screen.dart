
import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../cart/cart_screen.dart';

class AllMenuScreen extends StatefulWidget {
  const AllMenuScreen({super.key});

  @override
  State<AllMenuScreen> createState() =>
      _AllMenuScreenState();
}

class _AllMenuScreenState extends State<AllMenuScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF7F9F7);

  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Snacks',
    'Dinner',
    'Beverage',
  ];

  String selectedCategory = 'All';

  late Future<List<FoodItem>> foods;

  final cart = CartService.instance;

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  // =====================================
  // LOAD FOOD ITEMS
  // =====================================
  void loadFoods() {
    foods = ApiService.getFoodItems(
      category: selectedCategory,
      menuType: 'all',
    );
  }

  // =====================================
  // REFRESH FOOD ITEMS
  // =====================================
  Future<void> refreshFoods() async {
    setState(loadFoods);

    try {
      await foods;
    } catch (_) {
      // FutureBuilder displays the error.
    }
  }

  // =====================================
  // CHANGE CATEGORY
  // =====================================
  void changeCategory(String category) {
    if (selectedCategory == category) return;

    setState(() {
      selectedCategory = category;
      loadFoods();
    });
  }

  // =====================================
  // OPEN CART
  // =====================================
  Future<void> openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // =====================================
  // CATEGORY FILTER
  // =====================================
  Widget buildCategoryFilter() {
    return Container(
      height: 65,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected =
              category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              selectedColor: green,
              backgroundColor:
              const Color(0xFFF0F4F0),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? green
                    : Colors.grey.shade300,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              onSelected: (_) {
                changeCategory(category);
              },
            ),
          );
        },
      ),
    );
  }

  // =====================================
  // FOOD LIST
  // =====================================
  Widget buildFoodList() {
    return FutureBuilder<List<FoodItem>>(
      future: foods,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: green,
            ),
          );
        }

        if (snapshot.hasError) {
          return buildErrorState(snapshot.error);
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return RefreshIndicator(
            color: green,
            onRefresh: refreshFoods,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.grey,
                  size: 65,
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No food items available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: green,
          onRefresh: refreshFoods,
          child: ListView.separated(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return buildFoodCard(items[index]);
            },
          ),
        );
      },
    );
  }

  // =====================================
  // ERROR STATE
  // =====================================
  Widget buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 55,
            ),

            const SizedBox(height: 15),

            Text(
              'Error: $error',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                setState(loadFoods);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // FOOD CARD
  // =====================================
  Widget buildFoodCard(FoodItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5ECE6),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // FOOD IMAGE
          ClipRRect(
            borderRadius:
            BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 110,
              child: item.imageUrl != null &&
                  item.imageUrl!.isNotEmpty
                  ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    buildPlaceholder(),
              )
                  : buildPlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // FOOD NAME
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // DESCRIPTION
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 5),

                // CALORIES
                Text(
                  '${item.calories ?? 0} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                // PRICE AND QUANTITY
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment:
                  WrapCrossAlignment.center,
                  alignment:
                  WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ListenableBuilder(
                      listenable: cart,
                      builder: (context, _) {
                        final quantity =
                        cart.quantityFor(item.id);

                        if (quantity == 0) {
                          return ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor:
                              Colors.white,
                              minimumSize:
                              const Size(65, 36),
                            ),
                            onPressed: () {
                              cart.addItem(item);
                            },
                            child: const Text('Add'),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFFE5F3E8),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              IconButton(
                                constraints:
                                const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  cart.decreaseItem(
                                    item.id,
                                  );
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: green,
                                ),
                              ),

                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              IconButton(
                                constraints:
                                const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  cart.addItem(item);
                                },
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // FOOD IMAGE PLACEHOLDER
  // =====================================
  Widget buildPlaceholder() {
    return Container(
      color: const Color(0xFFE5F3E8),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: green,
          size: 42,
        ),
      ),
    );
  }

  // =====================================
  // VIEW CART BUTTON
  // =====================================
  Widget buildViewCartButton() {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            10,
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: openCart,
              icon: const Icon(
                Icons.shopping_cart_checkout,
              ),
              label: Text(
                'View Cart (${cart.itemCount})  •  '
                    '₹${cart.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================
  // MAIN SCREEN
  // =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // =====================================
      // APP BAR
      // =====================================
      appBar: AppBar(
        title: const Text(
          'All Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
        const Color(0xFFEDF4EF),
        elevation: 0,
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (context, _) {
              return Badge(
                isLabelVisible:
                cart.itemCount > 0,
                label: Text(
                  '${cart.itemCount}',
                ),
                child: IconButton(
                  tooltip: 'Open Cart',
                  onPressed: openCart,
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),

      // =====================================
      // BODY
      // =====================================
      body: Column(
        children: [
          buildCategoryFilter(),

          Expanded(
            child: buildFoodList(),
          ),
        ],
      ),

      // =====================================
      // VIEW CART + COMMON BOTTOM NAVIGATION
      // =====================================
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildViewCartButton(),

          const AppBottomNavBar(
            selectedIndex: 0,
          ),
        ],
      ),
    );
  }
}
