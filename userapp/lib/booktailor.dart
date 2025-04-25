import 'package:flutter/material.dart';
import 'package:userapp/main.dart';
import 'package:userapp/selectmaterial.dart';

class BookTailor extends StatefulWidget {
  final String id;
  final bool booking;
  const BookTailor({super.key, required this.id, this.booking = false});

  @override
  State<BookTailor> createState() => _BookTailorState();
}

class _BookTailorState extends State<BookTailor> {
  List<Map<String, dynamic>> dressData = [];
  int bookingId = 0;

  final primaryColor = const Color(0xFF6A1B9A); // Deep purple
  final accentColor = const Color(0xFFE91E63); // Pink accent
  final double fabricWidthMeters = 1.12; // 44 inches ≈ 1.12 meters

  bool isLoading = false;

  Future<void> fetchBooking() async {
    try {
      final booking = await supabase
          .from('tbl_booking')
          .select(
              "id, status, tbl_dress(*, tbl_material(material_amount, material_photo, material_colors, tbl_clothtype(clothtype_name)), tbl_measurement(*, tbl_attribute(attribute_name)), tbl_category(category_name))")
          .eq('tailor_id', widget.id)
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('status', 0)
          .maybeSingle()
          .limit(1);
      if (booking != null) {
        setState(() {
          bookingId = booking['id'];
        });
        if (booking['tbl_dress'].isNotEmpty) {
          setState(() {
            dressData = (booking['tbl_dress'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
          });
        } else {
          print("No dresses found in booking.");
          setState(() {
            dressData = [];
          });
        }
      } else {
        print("No booking found for this tailor.");
        setState(() {
          dressData = [];
        });
      }
    } catch (e) {
      print("Error fetching booking: $e");
    }
  }

  Future<void> fetchfromBooking() async {
    try {
      final booking = await supabase
          .from('tbl_booking')
          .select(
              "id, status, tbl_dress(*, tbl_material(material_amount, material_photo, material_colors, tbl_clothtype(clothtype_name)), tbl_measurement(*, tbl_attribute(attribute_name)), tbl_category(category_name))")
          .eq('id', widget.id)
          .maybeSingle()
          .limit(1);
      if (booking != null) {
        setState(() {
          bookingId = booking['id'];
        });
        if (booking['tbl_dress'].isNotEmpty) {
          setState(() {
            dressData = (booking['tbl_dress'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
          });
        } else {
          print("No dresses found in booking.");
          setState(() {
            dressData = [];
          });
        }
      } else {
        print("No booking found for this tailor.");
        setState(() {
          dressData = [];
        });
      }
    } catch (e) {
      print("Error fetching booking: $e");
    }
  }

  // Convert Hex String to Color
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  // Calculate Total Material Cost (for all dresses)
  double calculateTotalCost() {
    return dressData.fold(
      0.0,
      (sum, dress) {
        final material = dress['tbl_material'];
        if (material == null) return sum; // No material, cost is 0
        final materialAmount = material['material_amount'];
        // Parse material_amount as a String to double
        return sum +
            (materialAmount != null
                ? double.tryParse(materialAmount.toString()) ?? 0.0
                : 0.0);
      },
    );
  }

  // Calculate Fabric Length for a Single Dress (in meters)
  double calculateFabricLength(List<dynamic> measurements) {
    const double cmToMeters = 0.01; // 1 cm = 0.01 meters

    if (measurements.isEmpty) return 0.0;
    final maxMeasurement = measurements
        .map((m) => (m['measurement_value'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    double lengthMeters = maxMeasurement * cmToMeters;
    return (lengthMeters / 0.5).ceil() * 0.5; // Round to nearest 0.5 meter
  }

  // Delete a Dress
  Future<void> deleteDress(int dressId) async {
    try {
      // First, attempt to delete measurements (if any)
      await supabase.from('tbl_measurement').delete().eq('dress_id', dressId);
      // Then delete the dress
      await supabase.from('tbl_dress').delete().eq('dress_id', dressId);
      await fetchBooking(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Dress deleted successfully."),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      print("Error deleting dress: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to delete dress. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Edit a Dress
  Future<void> editDress(Map<String, dynamic> dress) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectMaterial(
          tailor: widget.id,
          dress: dress, // Pass the full dress object for editing
        ),
      ),
    );
    if (result != null && result['success'] == true) {
      await fetchBooking(); // Refresh the list after editing
    }
  }

  // Add a New Dress
  Future<void> addDress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectMaterial(tailor: widget.id),
      ),
    );
    if (result != null && result['success'] == true) {
      await fetchBooking(); // Refresh the list after adding
    }
  }

  // Show Checkout Confirmation Dialog
  void showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, primaryColor.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Order Placed!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Your order has been successfully placed. Please wait for the tailor's confirmation.\n\nThe tailor will review your order and provide the service charges and the expected completion date.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Navigate back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkOut() async {
    if (dressData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please add at least one dress to proceed."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('tbl_booking').update({
        'status': 1,
      }).eq('id', bookingId);
      await supabase.from('tbl_dress').update({
        'dress_status': 1,
      }).eq('booking_id', bookingId);
      showCheckoutDialog(); // Show confirmation dialog
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error during checkout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to proceed to checkout."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.booking) {
      fetchfromBooking();
    } else {
      fetchBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMaterialCost = calculateTotalCost();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Book Tailor"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: addDress,
              icon: Icon(Icons.checkroom, color: Colors.white),
              label: const Text(
                "Select Cloth",
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dress List
              dressData.isEmpty
                  ? Center(
                      child: Text(
                        "No dresses booked yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dressData.length,
                      itemBuilder: (context, index) {
                        final dress = dressData[index];
                        final measurements =
                            dress['tbl_measurement'] as List<dynamic>;
                        final material = dress['tbl_material'];
                        final colors = (material != null &&
                                material['material_colors'] != null)
                            ? (material['material_colors'] as List)
                                .map((c) => c as Map<String, dynamic>)
                                .toList()
                            : [];
                        String category =
                            dress['tbl_category']['category_name'];
                        String remark = dress['dress_remark'] ?? "No remarks";
                        double fabricLength =
                            calculateFabricLength(measurements);
                        double materialCost = material != null
                            ? (material['material_amount'] != null
                                ? double.tryParse(
                                        material['material_amount'].toString()) ??
                                    0.0
                                : 0.0)
                            : 0.0;

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dress Category, Remark, and Actions
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            remark,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: primaryColor),
                                          onPressed: () => editDress(dress),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: accentColor),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    "Confirm Delete"),
                                                content: const Text(
                                                    "Are you sure you want to delete this dress?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text("Cancel",
                                                        style: TextStyle(
                                                            color:
                                                                accentColor)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await deleteDress(
                                                          dress['dress_id']);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Delete",
                                                        style: TextStyle(
                                                            color:
                                                                accentColor)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Material Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: material != null &&
                                              material['material_photo'] != null
                                          ? Image.network(
                                              material['material_photo'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image,
                                                    size: 40,
                                                    color: Colors.grey),
                                              ),
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image,
                                                  size: 40, color: Colors.grey),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            material != null
                                                ? material['tbl_clothtype']
                                                        ['clothtype_name'] ??
                                                    "Custom Material"
                                                : "Custom Material",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                          if (material == null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              "User-provided material",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                          if (materialCost > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              "Total Cost: ₹${materialCost.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: accentColor,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            "Fabric Length: ${fabricLength.toStringAsFixed(1)} meters",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          if (colors.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: colors.map((color) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: _hexToColor(
                                                            color['hex']),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 0.5),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      color['name'],
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Measurements Section
                                Text(
                                  "Measurements",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: measurements.length,
                                  itemBuilder: (context, mIndex) {
                                    final measurement = measurements[mIndex];
                                    String measurementName =
                                        measurement['tbl_attribute']
                                            ['attribute_name'];
                                    double measurementValue =
                                        measurement['measurement_value']
                                            .toDouble();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            measurementName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            "$measurementValue cm",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              // Total Cost, Remark, and Checkout Button at Bottom
              if (dressData.isNotEmpty) ...[
                if (totalMaterialCost > 0) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Material Cost",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "₹${totalMaterialCost.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Note: This is only the material cost; service cost will be added later.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            checkOut();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : const Text(
                            "Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}