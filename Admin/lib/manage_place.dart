import 'package:flutter/material.dart';

class ManagePlace extends StatefulWidget {
  const ManagePlace({super.key});

  @override
  State<ManagePlace> createState() => _ManagePlaceState();
}

class _ManagePlaceState extends State<ManagePlace> {
  final TextEditingController placeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage Place',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: placeController,
          decoration: InputDecoration(
            labelText: "Place",
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