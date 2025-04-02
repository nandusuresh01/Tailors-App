import 'package:flutter/material.dart';

class AdminComplaintsPage extends StatefulWidget {
  @override
  _AdminComplaintsPageState createState() => _AdminComplaintsPageState();
}

class _AdminComplaintsPageState extends State<AdminComplaintsPage> {
  List<Map<String, String>> complaints = [
    {"date": "2025-03-10", "status": "Resolved", "message": "Delayed delivery", "user": "John Doe", "reply": "Issue has been resolved."},
    {"date": "2025-03-15", "status": "Pending", "message": "Wrong measurement", "user": "Jane Smith", "reply": ""}
  ];

  String selectedStatusFilter = "All";
  List<String> statusOptions = ["All", "Pending", "Resolved"];
  TextEditingController replyController = TextEditingController();
  Map<int, bool> isDropdownVisible = {};

  void _updateComplaintStatus(int index, String newStatus) {
    setState(() {
      complaints[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Complaint status updated to $newStatus')),
    );
  }

  void _submitReply(int index) {
    setState(() {
      complaints[index]['reply'] = replyController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reply sent successfully')),
    );
    replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin - Complaints Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complaints List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedStatusFilter,
              items: statusOptions.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (newFilter) {
                setState(() {
                  selectedStatusFilter = newFilter!;
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  if (selectedStatusFilter != "All" && complaint['status'] != selectedStatusFilter) {
                    return SizedBox.shrink();
                  }
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${complaint['user']} - ${complaint['message']}', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: Icon(isDropdownVisible[index] == true ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                onPressed: () {
                                  setState(() {
                                    isDropdownVisible[index] = !(isDropdownVisible[index] ?? false);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (isDropdownVisible[index] == true) ...[
                            Text('Date: ${complaint['date']}'),
                            SizedBox(height: 10),
                            DropdownButton<String>(
                              value: complaint['status'],
                              items: ['Pending', 'Resolved'].map((status) {
                                return DropdownMenuItem(value: status, child: Text(status));
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  _updateComplaintStatus(index, newStatus);
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: replyController,
                              decoration: InputDecoration(
                                labelText: 'Enter reply',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: () => _submitReply(index),
                              child: Text('Send Reply'),
                            ),
                            if (complaint['reply']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text('Reply: ${complaint['reply']}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                          ],
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
    );
  }
}
