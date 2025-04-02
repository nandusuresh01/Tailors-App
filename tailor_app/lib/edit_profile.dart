import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:tailor_app/main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? pickedImage;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> districtList = [];
  String? selectedDistrict;
  List<Map<String, dynamic>> placeList = [];
  String? selectedPlace;

  bool isLoading = true;
  String originalPhoto = "";

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    fetchUserProfile();
  }

  /// Fetch Districts from Supabase
  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  /// Fetch Places based on selected district
  Future<void> fetchPlaces(String districtId) async {
    try {
      final response =
          await supabase.from("tbl_place").select().eq('district', districtId);
      setState(() {
        placeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  /// Fetch current user profile
  Future<void> fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('tbl_tailor')
          .select("*,tbl_place(place_name,tbl_district(*))")
          .eq('tailor_id', user)
          .single();

      setState(() {
        nameController.text = response['tailor_name'] ?? "";
        contactController.text = response['tailor_contact'] ?? "";
        addressController.text = response['tailor_address'] ?? "";
        originalPhoto = response['tailor_photo'] ?? "";
        selectedPlace = response['place_id'].toString();
        selectedDistrict =
            response['tbl_place']['tbl_district']['district_id'].toString();
        fetchPlaces(selectedDistrict!);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user profile: $e");
    }
  }

  /// Handle Profile Image Selection
  Future<void> handleImagePick() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  /// Upload Image to Supabase Storage
  Future<String?> uploadPhoto(File imageFile) async {
    try {
      final bucketName = 'tailor';
      String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${imageFile.path.split('/').last}";

      await supabase.storage.from(bucketName).upload(filePath, imageFile);
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print("Error uploading photo: $e");
      return null;
    }
  }

  /// Update Profile
  Future<void> updateProfile() async {
    try {
      final user = supabase.auth.currentUser!.id;

      final String? imageUrl =
          pickedImage != null ? await uploadPhoto(pickedImage!) : originalPhoto;

      await supabase.from('tbl_tailor').update({
        'tailor_name': nameController.text,
        'tailor_contact': contactController.text,
        'tailor_address': addressController.text,
        'tailor_photo': imageUrl ?? '',
        'place_id': selectedPlace,
      }).eq('tailor_id', user);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")));
      Navigator.pop(context, true);
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Profile Image Picker
                    GestureDetector(
                      onTap: handleImagePick,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage!)
                            : (originalPhoto.isNotEmpty
                                ? NetworkImage(originalPhoto)
                                : null) as ImageProvider?,
                        child: pickedImage == null && originalPhoto.isEmpty
                            ? const Icon(Icons.camera_alt,
                                size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: "Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),

                    /// Contact
                    TextFormField(
                      controller: contactController,
                      decoration: const InputDecoration(
                          labelText: "Contact", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),

                    /// Address
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: "Address", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),

                    /// District Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      hint: const Text("Select District"),
                      items: districtList.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['district_id'].toString(),
                          child: Text(data['district_name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                          selectedPlace = null;
                          placeList.clear();
                        });
                        fetchPlaces(newValue!);
                      },
                      decoration: const InputDecoration(
                          labelText: 'District', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),

                    /// Place Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      hint: const Text("Select Place"),
                      items: placeList.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['place_id'].toString(),
                          child: Text(data['place_name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPlace = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                          labelText: 'Place', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),

                    /// Update Button
                    ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Update Profile"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
