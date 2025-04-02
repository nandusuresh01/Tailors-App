import 'package:flutter/material.dart';
import 'package:userapp/booking.dart';
import 'package:userapp/complaints.dart';
import 'package:userapp/profilepage.dart';
import 'package:userapp/search_tailor.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Welcome!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://cdn.dribbble.com/userupload/4154378/file/original-64ea0b52830b08ec31aef276115d1158.png?resize=400x0',
                ),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore the features below:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            _buildFeatureCard(
              context,
              title: 'Find a Tailor',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchTailor()),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Your Bookings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileBookingPage()),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Complaints',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserComplaintsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.asset(
          'assets/tailor.jpg', // Local image
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 40); // Fallback if image fails
          },
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}