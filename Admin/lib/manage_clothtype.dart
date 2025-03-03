import 'package:flutter/material.dart';
import 'package:project/main.dart';

class Manageclothtype extends StatefulWidget {
  const Manageclothtype({super.key});

  @override
  State<Manageclothtype> createState() => _ManageDistrictState();
}

class _ManageDistrictState extends State<Manageclothtype> {

  final TextEditingController clothtypeController = TextEditingController();

  Future<void> insert() async {
    try{
      await supabase.from('tbl_clothtype').insert({
        'clothtype_name': clothtypeController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("data inserted")));
     }catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to insert data")));
        print("Error: $e");
      }
    }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage Cloth Type',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: clothtypeController,
          decoration: InputDecoration(
            labelText: "Cloth Type",
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