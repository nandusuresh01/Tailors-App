import 'package:flutter/material.dart';

class UserComplaintsPage extends StatefulWidget {
  @override
  _UserComplaintsPageState createState() => _UserComplaintsPageState();
}

class _UserComplaintsPageState extends State<UserComplaintsPage> {
  TextEditingController complaintController = TextEditingController();
  List<Map<String, String>> complaints = [
    {"date": "2025-03-10", "status": "Resolved", "message": "Delayed delivery"},
    {"date": "2025-03-15", "status": "Pending", "message": "Wrong measurement"}
  ];

  void _submitComplaint() {
    if (complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your complaint')),
      );
      return;
    }
    setState(() {
      complaints.add({
        "date": DateTime.now().toString().split(' ')[0],
        "status": "Pending",
        "message": complaintController.text
      });
      complaintController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Complaint submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Complaints')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: complaintController,
              decoration: InputDecoration(
                labelText: 'Enter your complaint',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitComplaint,
              child: Text('Submit Complaint'),
            ),
            SizedBox(height: 20),
            Text('Complaint History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Date: ${complaint['date']}'),
                      subtitle: Text('Complaint: ${complaint['message']}'),
                      trailing: Text(
                        complaint['status']!,
                        style: TextStyle(
                          color: complaint['status'] == 'Resolved' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}