import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'item_detail_page.dart';
import 'package:abaya_designer/screens/checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 239, 236),
      appBar: AppBar(
        title: const Text("My Cart",
            style: TextStyle(color: Color.fromARGB(255, 240, 215, 205))),
        backgroundColor: const Color.fromARGB(255, 1, 63, 52),
      ),
      body: SafeArea(
        child: globalCart.isEmpty
            ? const Center(
                child: Text("Your cart is empty",
                    style: TextStyle(color: Colors.black54)))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: globalCart.length,
                itemBuilder: (context, index) {
                  final item = globalCart[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03, vertical: 5),
                    child: Card(
                      color: const Color.fromARGB(255, 11, 11, 11)
                          .withValues(alpha: .1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/${item.image}',
                            key: ValueKey(
                                '${item.image}_$index'), // ADD THIS LINE
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            // Add this to handle errors if an image name is misspelled in DB
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total: Rs. ${item.total}"),
                            const SizedBox(height: 6),
                            // Updated interactive "Edit" hint
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "Size: ${item.size} | Qty: ${item.quantity}",
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.edit,
                                      size: 12,
                                      color: Color.fromARGB(255, 1, 63, 52)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () =>
                              setState(() => globalCart.removeAt(index)),
                        ),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetailPage(item: item)))
                              .then((_) => setState(() {}));
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: globalCart.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.15,
                vertical:
                    screenHeight * 0.08, // Original fixed position preserved
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CheckoutPage()),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 1, 70, 59),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "CHECKOUT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
