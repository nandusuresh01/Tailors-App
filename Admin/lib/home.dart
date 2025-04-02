import 'package:flutter/material.dart';
import 'package:project/manage_attribute.dart';
import 'package:project/manage_category.dart';
import 'package:project/manage_clothtype.dart';
import 'package:project/manage_complaint.dart';
import 'package:project/manage_district.dart';
import 'package:project/manage_place.dart';
import 'package:project/manage_tailors.dart';


class Tail extends StatelessWidget {
  const Tail({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('Tailors App',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800])),
                    SizedBox(height: 8),
                    Text('Welcome, Administrator',
                        style: TextStyle(
                            fontSize: 16, color: Colors.blueGrey[600]))
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => options[index]['page']),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: options[index]['color'],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(options[index]['icon'], size: 40, color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              options[index]['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> options = [
  {'title': 'Manage District', 'page': ManageDistrict(), 'color': Colors.blue, 'icon': Icons.location_city},
  {'title': 'Manage Cloth Type', 'page': Manageclothtype(), 'color': Colors.orange, 'icon': Icons.shopping_bag},
  {'title': 'Manage Category', 'page': Managecategory(), 'color': Colors.green, 'icon': Icons.category},
  {'title': 'Manage Attribute', 'page': ManageAttribute(), 'color': Colors.purple, 'icon': Icons.settings},
  {'title': 'Manage Place', 'page': ManagePlace(), 'color': Colors.teal, 'icon': Icons.place},
  {'title': 'Manage Complaint', 'page': AdminComplaintsPage(), 'color': Colors.red, 'icon': Icons.report_problem},
  {'title': 'Manage Tailors', 'page': AdminTailors(), 'color': Colors.red, 'icon': Icons.report_problem},
];
