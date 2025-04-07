import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:project/form_validation.dart';

class ManagePlace extends StatefulWidget {
  const ManagePlace({super.key});

  @override
  State<ManagePlace> createState() => _ManagePlaceState();
}

class _ManagePlaceState extends State<ManagePlace> {
  final TextEditingController placeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedDistrict;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdistrict();
    fetchplace();
  }

Future<void> insert() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDistrict == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a district'),
        ));
      }
      return;
    }

    try {
      await supabase.from('tbl_place').insert({
        'place_name': placeController.text,
        'district': selectedDistrict,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Place Added'),
        ));
      }
      placeController.clear();
      selectedDistrict = null;
      fetchplace();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed'),
        ));
      }
      print("Error: $e");
    }
  }

 List<Map<String, dynamic>> district = [];

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
     setState(() {
       district = response;
     });
    } catch (e) {
      print("Error: $e");
    }
  }


List<Map<String, dynamic>> place = [];


Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_place').delete().eq('place_id', id);
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted")));{
       fetchplace();
     };
    } catch (e) {
      print("Error: $e");
    }
}



  Future<void> fetchplace() async {
    try {
      final response = await supabase.from('tbl_place').select('*,tbl_district(*)');
     setState(() {
       place = response;
     });
    } catch (e) {
      print("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 56, 232),
        title:  Text('Manage Place',
        style: TextStyle(color:Colors.red),
        )
     ),
     body: Form(
      key: _formKey,
      child: ListView(
      padding: EdgeInsets.all(20),
      children: [
         DropdownButtonFormField<String>(
            value: selectedDistrict,
            hint: Text('Select District'),
            validator: (value) => FormValidation.validateDropdown(value),
            items: district.map((districtItem) {
              return DropdownMenuItem<String>(
                value: districtItem['district_id'].toString(),
                child: Text(districtItem['district_name']),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedDistrict = newValue;
              });
            },
            decoration: InputDecoration(
              labelText: "District",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
          height: 10,
          ),
        TextFormField(
          controller: placeController,
          validator: (value) => FormValidation.validateValue(value),
          decoration: InputDecoration(
            labelText: "Place",
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
          itemCount: place.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final data = place[index];
          return ListTile(
            leading: Text((index + 1).toString()),
            title: Text(data['place_name']),
            subtitle: Text(data['tbl_district']['district_name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                delete(data['place_id']);
              },
          ));
        },)
      ],
     ),
    ),
    );
  }
}