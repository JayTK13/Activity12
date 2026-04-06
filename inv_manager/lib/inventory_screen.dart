import 'package:flutter/material.dart';
import 'item.dart';
import 'item_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ItemService service = ItemService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? editingId;

  @override
  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final qty = int.parse(qtyController.text.trim());

    if (editingId != null) {
      service.updateItem(Item(id: editingId!, name: name, quantity: qty));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item updated')));
    } else {
      service.addItem(Item(id: '', name: name, quantity: qty));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added')));
    }

    nameController.clear();
    qtyController.clear();
    editingId = null;
  }

  void _editItem(Item item) {
    nameController.text = item.name;
    qtyController.text = item.quantity.toString();
    editingId = item.id;
  }

  void _deleteItem(Item item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              service.deleteItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Item deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter item name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter quantity';
                        final parsed = int.tryParse(value);
                        if (parsed == null) return 'Must be a number';
                        if (parsed <= 0) return 'Must be greater than 0';
                        return null;
                      },
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.check), onPressed: _submit),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: service.streamItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty)
                    return const Center(child: Text('No items yet.'));

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editItem(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                      );
                    },
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
