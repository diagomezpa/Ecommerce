import 'package:flutter/material.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'pages/product_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Detail Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProductTestHomePage(),
    );
  }
}

class ProductTestHomePage extends StatelessWidget {
  const ProductTestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Product Detail Page Test',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap any button below to test the ProductDetailPage with different products:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Test buttons for different products
              _buildTestButton(
                context,
                productId: 1,
                title: 'Test Product #1',
                description: 'Test with the first product',
                icon: Icons.laptop,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                context,
                productId: 2,
                title: 'Test Product #2',
                description: 'Test with the second product',
                icon: Icons.watch,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                context,
                productId: 3,
                title: 'Test Product #3',
                description: 'Test with the third product',
                icon: Icons.checkroom,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                context,
                productId: 20,
                title: 'Test Product #20',
                description: 'Test with the twentieth product',
                icon: Icons.diamond,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required int productId,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(productId: productId),
            ),
          );
        },
        icon: Icon(icon),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
