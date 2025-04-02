import 'package:flutter/material.dart';
import 'package:tailor_app/change_password.dart';
import 'package:tailor_app/edit_profile.dart';
import 'package:tailor_app/login.dart';
import 'package:tailor_app/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String contact = "";
  String address = "";
  String photo = "";
  String place = "";
  String district = "";
  bool isLoading = true;

  /// Fetch user data from `tbl_user`
  Future<void> fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('tbl_tailor')
          .select("*,tbl_place(place_name,tbl_district(district_name))")
          .eq('tailor_id', user)
          .single();
      print("response: $response");
      setState(() {
        name = response['tailor_name'] ?? "No Name";
        email = response['tailor_email'] ?? "No Email";
        contact = response['tailor_contact'] ?? "No Contact";
        address = response['tailor_address'] ?? "No Address";
        photo = response['tailor_photo'] ?? ""; // Default avatar
        place = response['tbl_place']['place_name'] ?? "No Place";
        district = response['tbl_place']['tbl_district']['district_name'] ??
            "No District";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Profile Details Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        photo == ""
                            ? CircleAvatar(
                                radius: 40,
                                child: Text(name[0],
                                    style: const TextStyle(fontSize: 40)),
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(photo),
                                radius: 75,
                              ),
                        const SizedBox(height: 10),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(email,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                        Text(contact,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                        Text(address,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                                Text("$place, $district",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
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
                          final result = Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(),));
                          if(result == true) {
                            fetchUserProfile();
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock, color: Colors.blue),
                        title: const Text("Change Password"),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(),));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text("Logout"),
                        onTap: () async {
                          await supabase.auth.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                            (route) => false,
                          );
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
