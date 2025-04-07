import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:project/form_validation.dart';

class Managecategory extends StatefulWidget {
  const Managecategory({super.key});

  @override
  State<Managecategory> createState() => _ManagecategoryState();
}

class _ManagecategoryState extends State<Managecategory> {
  final TextEditingController categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> insert() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await supabase.from('tbl_category').insert({
        'category_name': categoryController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Category Type Added'),
      ));
      categoryController.clear();
      fetchCategory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed'),
      ));
      print("Error: $e");
    }
  }

  List<Map<String, dynamic>> category = [];

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
     setState(() {
       category = response;
     });
    } catch (e) {
      print("Error: $e");
    }
  }

     Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_category').delete().eq('category_id', id);
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted")));{
       fetchCategory();
     };
    } catch (e) {
      print("Error: $e");
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCategory();
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
     body: Form(
      key: _formKey,
      child: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: categoryController,
          validator: (value) => FormValidation.validateValue(value),
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
        }, child: Text("Submit"))),
        SizedBox(
          height: 20,
        ),
        ListView.builder(
          itemCount: category.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final data = category[index];
          return ListTile(
            leading: Text((index + 1).toString()),
            title: Text(data['category_name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                delete(data['category_id']);
              },
            ),
          );
        },)
      ],
     ),
    ),
    );
  }
}