import 'package:flutter/material.dart';
import 'package:project/main.dart';

class Managecategory extends StatefulWidget {
  const Managecategory({super.key});

  @override
  State<Managecategory> createState() => _ManagecategoryState();
}

class _ManagecategoryState extends State<Managecategory> {
  final TextEditingController categoryController = TextEditingController();
  
  Future<void> insert() async {
    try {
      await supabase.from('tbl_category').insert({
        'category_name': categoryController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Category Type Added'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed'),
      ));
      print("Error: $e");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage Category Type',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: categoryController,
          decoration: InputDecoration(
            labelText: "Category Type",
            border: OutlineInputBorder()
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(child: ElevatedButton(onPressed: (){
          insert();
        }, child: Text("Submit")))
      ],
     ),
    );
  }
}