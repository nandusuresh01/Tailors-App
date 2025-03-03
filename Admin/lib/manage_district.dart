

import 'package:flutter/material.dart';
import 'package:project/main.dart';

class ManageDistrict extends StatefulWidget {
  const ManageDistrict({super.key});

  @override
  State<ManageDistrict> createState() => _ManageDistrictState();
}

class _ManageDistrictState extends State<ManageDistrict> {

  final TextEditingController districtController = TextEditingController();

  Future<void> insertDistrict() async {
    try {
      await supabase.from('tbl_district').insert({
        'district_name': districtController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("data inserted")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to insert data")));
      print(e);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage District',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: districtController,
          decoration: InputDecoration(
            labelText: "District",
            border: OutlineInputBorder()
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(child: ElevatedButton(onPressed: (){
          insertDistrict();
        }, child: Text("Submit")))
      ],
     ),
    );
  }
}