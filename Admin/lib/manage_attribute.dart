import 'package:flutter/material.dart';

class ManageAttribute extends StatefulWidget {
  const ManageAttribute({super.key});

  @override
  State<ManageAttribute> createState() => _ManageAttributeState();
}

class _ManageAttributeState extends State<ManageAttribute> {
  
  final TextEditingController categoryController = TextEditingController();
 @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage Attribute Type',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: categoryController,
          decoration: InputDecoration(
            labelText: "Attribute Type",
            border: OutlineInputBorder()
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(child: ElevatedButton(onPressed: (){}, child: Text("Submit")))
      ],
     ),
    );
  }
}