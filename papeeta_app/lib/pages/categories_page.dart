import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  CategoriesPage({super.key});

  final Map<String, String> categories = {
    'Mexicana': 'mexicana',
    'Pastas': 'pastas',
    'Asiática': 'asiatica',
    'Entradas': 'entradas',
    'Carne Vacuna': 'carne',
    'Frutas': 'frutas',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías', style: const TextStyle(color: Colors.white)),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          mainAxisExtent: 180,
        ),
        padding: EdgeInsets.all(20.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryName = categories.keys.elementAt(index);
          final categoryImage =
              'images/categories/${categories.values.elementAt(index)}.png';
          return Container(
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 0.3,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
                  child: Image.asset(
                    categoryImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 20,
                  child: Text(
                    categoryName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
