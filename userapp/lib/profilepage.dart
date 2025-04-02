import 'package:flutter/material.dart';
import 'package:userapp/editprofile.dart';
import 'package:userapp/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String userEmail = "";
  String contactNumber = "";
  String address = "";
  String profileImage = "";

  /// Fetch user data from `tbl_user`
  Future<void> fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser!.id;

      final response =
          await supabase.from('tbl_user').select().eq('user_id', user).single();

      setState(() {
        userName = response['user_name'] ?? "No Name";
        userEmail = response['user_email'] ?? "No Email";
        contactNumber = response['user_contact'] ?? "No Contact";
        address = response['user_address'] ?? "No Address";
        profileImage = response['user_photo'] ??
            "https://cdn-icons-png.flaticon.com/512/149/149071.png"; // Default avatar
      });
    } catch (e) {
      print("Error fetching user profile: $e");
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
      appBar:
          AppBar(title: const Text("Profile"), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Profile Details Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profileImage),
                    radius: 75,
                  ),
                  const SizedBox(height: 10),
                  Text(userName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(userEmail,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54)),
                  Text(contactNumber,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54)),
                  Text(address,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Profile Options
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text("Edit Profile"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: const Text("Change Password"),
                  onTap: () {
                    // Navigate to Change Password Screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () async {
                    await supabase.auth.signOut();
                    Navigator.pushReplacementNamed(
                        context, '/login'); // Redirect to login
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
