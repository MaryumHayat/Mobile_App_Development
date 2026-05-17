// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'cart_model.dart';

class ItemDetailPage extends StatefulWidget {
  final CartItem item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Details"),backgroundColor: const Color.fromARGB(255, 215, 228, 223),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/images/${widget.item.image}', height: 300)),
            const SizedBox(height: 20),
            Text(widget.item.description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            const Text("Select Size:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            
            _buildSizeOption("Small", 0),
            _buildSizeOption("Medium", 200),
            _buildSizeOption("Large", 300),
            _buildSizeOption("XLarge", 400),
            
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if(widget.item.quantity > 1) widget.item.quantity--; })),
                    Text(widget.item.quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => widget.item.quantity++)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color.fromARGB(255, 215, 228, 223), borderRadius: BorderRadius.circular(0)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Unit Price:"), Text("Rs. ${widget.item.basePrice + widget.item.sizeSurcharge}")]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("Rs. ${widget.item.total}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, int surcharge) {
    return RadioListTile<String>(
      title: Text("$label (+$surcharge)"),
      value: label,
      groupValue: widget.item.size,
      activeColor: const Color.fromARGB(255, 2, 53, 44),
      onChanged: (v) => setState(() {
        widget.item.size = v!;
        widget.item.sizeSurcharge = surcharge;
      }),
    );
  }
}