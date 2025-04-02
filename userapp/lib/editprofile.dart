import 'package:flutter/material.dart';
import 'package:userapp/main.dart'; // Import Supabase instance

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String userEmail = "Loading...";
  String profileImage = "https://cdn-icons-png.flaticon.com/512/149/149071.png"; // Default avatar

  /// Fetch user data from `tbl_user`
  Future<void> fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', user.id)
          .single();

      setState(() {
        nameController.text = response['user_name'] ?? "";
        addressController.text = response['user_address'] ?? "";
        contactController.text = response['user_contact'] ?? "";
        userEmail = response['user_email'] ?? "";
        profileImage = response['user_photo'] ?? profileImage;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  /// Update user profile
  Future<void> updateUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      await supabase.from('tbl_user').update({
        'user_name': nameController.text,
        'user_address': addressController.text,
        'user_contact': contactController.text,
      }).eq('user_id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully!")),
      );
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle profile picture update
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                          radius: 60,
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(Icons.camera_alt, color: Colors.blue, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nameController.text,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  buildTextField("Full Name", Icons.person, nameController),
                  const SizedBox(height: 15),
                  buildTextField("Address", Icons.location_city, addressController),
                  const SizedBox(height: 15),
                  buildTextField("Contact Number", Icons.phone, contactController),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
