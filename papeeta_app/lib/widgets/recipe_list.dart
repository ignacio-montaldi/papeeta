import 'package:flutter/material.dart';

class RecipeList extends StatelessWidget {
  const RecipeList({super.key, required this.recetas});

  final List<String> recetas;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...recetas.map(
            (recetas) => GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'recipe');
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 243, 243),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('images/example.jpg'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Carne | Arroz | Papas | Plato principal',
                          style: TextStyle(
                            color: Color(0xff999999),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          recetas,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
