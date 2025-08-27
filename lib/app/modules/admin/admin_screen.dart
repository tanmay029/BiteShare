// lib/app/modules/admin/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/dummy_data_generator.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('Generate Dummy Data'),
                subtitle: const Text('Create dummy creators and recipes'),
                onTap: () async {
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );
                  
                  try {
                    await DummyDataGenerator.generateDummyData();
                    Get.back(); // Close loading dialog
                    Get.snackbar('Success', 'Dummy data generated successfully!');
                  } catch (e) {
                    Get.back(); // Close loading dialog
                    Get.snackbar('Error', 'Failed to generate dummy  $e');
                  }
                },
              ),
            ),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Clear Dummy Data'),
                subtitle: const Text('Remove all dummy creators and recipes'),
                onTap: () async {
                  bool? confirmed = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Clear Dummy Data'),
                      content: const Text('Are you sure you want to delete all dummy data?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    
                    try {
                      await DummyDataGenerator.clearDummyData();
                      Get.back(); // Close loading dialog
                      Get.snackbar('Success', 'Dummy data cleared successfully!');
                    } catch (e) {
                      Get.back(); // Close loading dialog
                      Get.snackbar('Error', 'Failed to clear dummy  $e');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
