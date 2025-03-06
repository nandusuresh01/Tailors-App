import 'package:flutter/material.dart';
import 'package:project/main.dart';

class ManageAttribute extends StatefulWidget {
  const ManageAttribute({super.key});

  @override
  State<ManageAttribute> createState() => _ManageAttributeState();
}

class _ManageAttributeState extends State<ManageAttribute> {
  final TextEditingController attributeController = TextEditingController();
String? selectedAttribute;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchcategory();
    fetchattribute();
  }
  
Future<void> insert() async {
    try {
      await supabase.from('tbl_attribute').insert({
        'attribute_name': attributeController.text,
        'attribute_id': selectedAttribute,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('attribute Added'),
      ));
      attributeController.clear();
      selectedAttribute = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed'),
      ));
      print("Error: $e");
    }
  }

 List<Map<String, dynamic>> category = [];

  Future<void> fetchcategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
     setState(() {
       category = response;
     });
    } catch (e) {
      print("Error: $e");
    }
  }
List<Map<String, dynamic>> attribute = [];

  Future<void> fetchattribute() async {
    try {
      final response = await supabase.from('tbl_attribute').select('*,tbl_category(*)');
     setState(() {
       attribute = response;
     });
    } catch (e) {
      print("Error: $e");
    }
  }

    Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_attribute').delete().eq('attribute_id',id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted")));
                fetchattribute();
    } catch (e) {
      print("Error: $e");
      
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage attribute',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: ListView(
      padding: EdgeInsets.all(20),
      children: [
         DropdownButtonFormField<String>(
            value: selectedAttribute,
            hint: Text('Select Place'),
            items: category.map((categoryItem) {
              return DropdownMenuItem<String>(
                value: categoryItem['category_id'].toString(), 
                child: Text(categoryItem['category_name']),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedAttribute = newValue;
              });
            },
            decoration: InputDecoration(
              labelText: "Attribute name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
          height: 10,
          ),
        TextFormField(
          controller: attributeController,
          decoration: InputDecoration(
            labelText: "Attribute",
            border: OutlineInputBorder()
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(child: ElevatedButton(onPressed: (){
          insert();
        }, child: Text("Submit"))),
        SizedBox(
          height: 20,
        ),

        ListView.builder(
          itemCount: attribute.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final data = attribute[index];
          return ListTile(
            leading: Text((index + 1).toString()),
            title: Text(data['attribute_name']),
            subtitle: Text(data['tbl_category']['category_name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: ()  {
                delete(data['attribute_id']);
                
              },
            ),
          );
        },)
      ],
     ),
    );
  }
}