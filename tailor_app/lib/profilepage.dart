import 'package:flutter/material.dart';
import 'package:tailor_app/change_password.dart';
import 'package:tailor_app/complaints.dart';
import 'package:tailor_app/edit_profile.dart';
import 'package:tailor_app/login.dart';
import 'package:tailor_app/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final primaryColor = const Color(0xFF6A1B9A); // Deep purple from home.dart
  final accentColor = const Color(0xFFE91E63); // Pink accent from home.dart
  
  String name = "";
  String email = "";
  String contact = "";
  String address = "";
  String photo = "";
  String place = "";
  String district = "";
  bool isLoading = true;

  // For Service Management
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> tailorServices = [];
  List<int> selectedCategoryIndices = [];
  bool isLoadingCategories = true;
  bool isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchCategories();
    fetchTailorServices(); // Fetch existing services
  }

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
        photo = response['tailor_photo'] ?? "";
        place = response['tbl_place']['place_name'] ?? "No Place";
        district = response['tbl_place']['tbl_district']['district_name'] ?? "No District";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user profile: $e");
    }
  }

  /// Fetch categories from `tbl_category`
  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      print("Error fetching categories: $e");
    }
  }

  /// Fetch tailor's existing services from `tbl_service`
  Future<void> fetchTailorServices() async {
    try {
      final tailorId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_service')
          .select('*, tbl_category(category_name)')
          .eq('tailor_id', tailorId);
      setState(() {
        tailorServices = List<Map<String, dynamic>>.from(response);
        isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        isLoadingServices = false;
      });
      print("Error fetching tailor services: $e");
    }
  }

  /// Insert multiple selected categories into `tbl_service`
  Future<void> addServices() async {
    try {
      final tailorId = supabase.auth.currentUser!.id;
      final selectedCategoryIds = selectedCategoryIndices.map((index) => categories[index]['category_id']).toList();

      for (var categoryId in selectedCategoryIds) {
        await supabase.from('tbl_service').insert({
          'category_id': categoryId,
          'tailor_id': tailorId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added ${selectedCategoryIds.length} service(s) successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        selectedCategoryIndices.clear(); // Reset selection
      });
      await fetchTailorServices(); // Refresh the services list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding services: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error adding services: $e");
    }
  }

  /// Update a service's categories
  Future<void> updateService(int serviceId, List<int> newCategoryIndices) async {
    try {
      final tailorId = supabase.auth.currentUser!.id;
      final newCategoryIds = newCategoryIndices.map((index) => categories[index]['category_id']).toList();

      // Delete the existing service
      await supabase.from('tbl_service').delete().eq('service_id', serviceId);

      // Insert new entries for each selected category
      for (var categoryId in newCategoryIds) {
        await supabase.from('tbl_service').insert({
          'category_id': categoryId,
          'tailor_id': tailorId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Service updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      await fetchTailorServices(); // Refresh the services list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating service: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error updating service: $e");
    }
  }

  /// Delete a service
  Future<void> deleteService(int serviceId) async {
    try {
      await supabase.from('tbl_service').delete().eq('service_id', serviceId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Service deleted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      await fetchTailorServices(); // Refresh the services list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting service: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error deleting service: $e");
    }
  }

  /// Show dialog to add services
  void showAddServiceDialog() {
    setState(() {
      selectedCategoryIndices.clear(); // Reset selection
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Add Services"),
              content: isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? const Text("No categories available.")
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Select categories for your services:",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  categories.length,
                                  (index) => ChoiceChip(
                                    label: Text(categories[index]['category_name'] ?? "Unknown"),
                                    selected: selectedCategoryIndices.contains(index),
                                    onSelected: (bool selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedCategoryIndices.add(index);
                                        } else {
                                          selectedCategoryIndices.remove(index);
                                        }
                                      });
                                    },
                                    selectedColor: primaryColor.withOpacity(0.2),
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: selectedCategoryIndices.contains(index)
                                          ? primaryColor
                                          : Colors.black,
                                      fontWeight: selectedCategoryIndices.contains(index)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selectedCategoryIndices.isEmpty
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await addServices();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Add Services"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Show dialog to edit a service
  void showEditServiceDialog(int serviceId, List<int> currentCategoryIndices) {
    setState(() {
      selectedCategoryIndices = List.from(currentCategoryIndices); // Pre-select current categories
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Edit Service"),
              content: isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? const Text("No categories available.")
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Update categories for this service:",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  categories.length,
                                  (index) => ChoiceChip(
                                    label: Text(categories[index]['category_name'] ?? "Unknown"),
                                    selected: selectedCategoryIndices.contains(index),
                                    onSelected: (bool selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedCategoryIndices.add(index);
                                        } else {
                                          selectedCategoryIndices.remove(index);
                                        }
                                      });
                                    },
                                    selectedColor: primaryColor.withOpacity(0.2),
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: selectedCategoryIndices.contains(index)
                                          ? primaryColor
                                          : Colors.black,
                                      fontWeight: selectedCategoryIndices.contains(index)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: selectedCategoryIndices.isEmpty
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await updateService(serviceId, selectedCategoryIndices);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Update Service"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: photo.isEmpty
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : "T",
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      photo,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Profile Info
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Details Section
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.phone, "Contact", contact),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.location_on, "Address", address),
                        const Divider(height: 20),
                        _buildInfoRow(Icons.place, "Location", "$place, $district"),
                      ],
                    ),
                  ),

                  // Services Section
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Services",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        isLoadingServices
                            ? const Center(child: CircularProgressIndicator())
                            : tailorServices.isEmpty
                                ? const Text(
                                    "No services added yet. Add some services!",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: tailorServices.length,
                                    itemBuilder: (context, index) {
                                      final service = tailorServices[index];
                                      final serviceId = service['service_id'];
                                      final categoryName = service['tbl_category']['category_name'] ?? "Unknown";

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.category, color: primaryColor, size: 24),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                categoryName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                                                // Find the category index for editing
                                                final currentCategoryIndex = categories.indexWhere(
                                                  (category) =>
                                                      category['category_id'] == service['category_id'],
                                                );
                                                showEditServiceDialog(
                                                  serviceId,
                                                  currentCategoryIndex != -1
                                                      ? [currentCategoryIndex]
                                                      : [],
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    title: const Text("Delete Service"),
                                                    content: const Text(
                                                      "Are you sure you want to delete this service?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text("Cancel"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          await deleteService(serviceId);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        child: const Text("Delete"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),

                  // Actions Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildActionButton(
                          "Edit Profile",
                          Icons.edit,
                          Colors.blue,
                          () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              fetchUserProfile();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          "Change Password",
                          Icons.lock,
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          "Complaints",
                          Icons.report_problem_outlined,
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Complaints(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          "Add Service",
                          Icons.add_business,
                          Colors.purple,
                          () {
                            showAddServiceDialog();
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          "Logout",
                          Icons.logout,
                          Colors.red,
                          () async {
                            await supabase.auth.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}