import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tailor_app/main.dart';

class BookingDetails extends StatefulWidget {
  final int booking;
  const BookingDetails({super.key, required this.booking});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  Map<String, dynamic>? bookingData;
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
              "id, status, amount, tbl_dress(dress_id, dress_amount, dress_remark, tbl_material(material_amount, material_photo, material_colors, tbl_clothtype(clothtype_name)), tbl_measurement(*, tbl_attribute(attribute_name)), tbl_category(category_name))")
          .eq('id', widget.booking)
          .maybeSingle()
          .limit(1);
      if (booking != null) {
        setState(() {
          bookingId = booking['id'];
          bookingData = booking;
          dressData = (booking['tbl_dress'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        });
      } else {
        print("No booking found.");
        setState(() {
          dressData = [];
          bookingData = null;
        });
      }
    } catch (e) {
      print("Error fetching booking: $e");
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  double calculateFabricLength(List<dynamic> measurements) {
    const double cmToMeters = 0.01;
    if (measurements.isEmpty) return 0.0;
    final maxMeasurement = measurements
        .map((m) => (m['measurement_value'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    double lengthMeters = maxMeasurement * cmToMeters;
    return (lengthMeters / 0.5).ceil() * 0.5; // Round to nearest 0.5 meter
  }

  double calculateDressMaterialCost(Map<String, dynamic> dress) {
    final measurements = dress['tbl_measurement'] as List<dynamic>;
    final materialCostPerMeter =
        (dress['tbl_material']['material_amount'] as num).toDouble();
    final fabricLength = calculateFabricLength(measurements);
    return materialCostPerMeter * fabricLength;
  }

  double getDressCost(Map<String, dynamic> dress) {
    // Use dress_amount if available (after acceptance), otherwise calculate material cost
    return dress['dress_amount'] != null
        ? (dress['dress_amount'] as num).toDouble()
        : calculateDressMaterialCost(dress);
  }

  double calculateTotalCost() {
    // Use booking amount if available (after acceptance), otherwise sum material costs
    if (bookingData != null && bookingData!['amount'] != null) {
      return (bookingData!['amount'] as num).toDouble();
    }
    return dressData.fold(
      0.0,
      (sum, dress) => sum + calculateDressMaterialCost(dress),
    );
  }

  void showAcceptOrderDialog() {
    List<TextEditingController> serviceChargeControllers =
        dressData.map((dress) => TextEditingController(text: '0')).toList();
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double calculateDialogTotal() {
              double total = 0.0;
              for (int i = 0; i < dressData.length; i++) {
                final dress = dressData[i];
                final materialCost = calculateDressMaterialCost(dress);
                final serviceCharge =
                    double.tryParse(serviceChargeControllers[i].text) ?? 0.0;
                total += materialCost + serviceCharge;
              }
              return total;
            }

            return AlertDialog(
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
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Accept Order",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Enter service charges for each dress and select the estimated delivery date.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...dressData.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> dress = entry.value;
                        double materialCost = calculateDressMaterialCost(dress);
                        String category =
                            dress['tbl_category']['category_name'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$category",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Material Cost: ₹${materialCost.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          serviceChargeControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Service Charge (₹)",
                                        labelStyle:
                                            TextStyle(color: primaryColor),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon: Icon(Icons.currency_rupee,
                                            color: primaryColor),
                                      ),
                                      onChanged: (value) =>
                                          setDialogState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      Text(
                        "Estimated Delivery Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate!,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: primaryColor,
                                  colorScheme:
                                      ColorScheme.light(primary: primaryColor),
                                  buttonTheme: const ButtonThemeData(
                                      textTheme: ButtonTextTheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null && picked != selectedDate) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(selectedDate!),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Icon(Icons.calendar_today, color: primaryColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "₹${calculateDialogTotal().toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style:
                                  TextStyle(color: accentColor, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await acceptOrder(
                                  serviceChargeControllers, selectedDate);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> acceptOrder(List<TextEditingController> serviceChargeControllers,
      DateTime? selectedDate) async {
    try {
      setState(() {
        isLoading = true;
      });

      double totalBookingCost = 0.0;

      for (int i = 0; i < dressData.length; i++) {
        final dress = dressData[i];
        final materialCost = calculateDressMaterialCost(dress);
        final serviceCharge =
            double.tryParse(serviceChargeControllers[i].text) ?? 0.0;
        final totalDressCost = materialCost + serviceCharge;

        await supabase.from('tbl_dress').update({
          'dress_amount': totalDressCost,
          'dress_status': 2, // Accepted
        }).eq('dress_id', dress['dress_id']);

        totalBookingCost += totalDressCost;
      }

      await supabase.from('tbl_booking').update({
        'amount': totalBookingCost,
        'status': 2, // Accepted
        'booking_fordate': selectedDate?.toIso8601String(),
      }).eq('id', bookingId);

      Navigator.pop(context); // Close dialog
      await fetchBooking(); // Refresh data

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Order accepted successfully!"),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      print("Error accepting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to accept order."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> rejectOrder() async {
    try {
      await supabase.from('tbl_booking').update({
        'status': 3, // Rejected
      }).eq('id', widget.booking);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Order rejected successfully!"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error rejecting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to reject order."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            final colors =
                                (material['material_colors'] as List?)
                                        ?.map((c) => c as Map<String, dynamic>)
                                        .toList() ??
                                    [];
                            String category =
                                dress['tbl_category']['category_name'];
                            String remark =
                                dress['dress_remark'] ?? "No remarks";
                            double fabricLength =
                                calculateFabricLength(measurements);
                            double cost = getDressCost(dress);

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
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: material['material_photo'] !=
                                                  null
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
                                                    child: const Icon(
                                                        Icons.image,
                                                        size: 40,
                                                        color: Colors.grey),
                                                  ),
                                                )
                                              : Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image,
                                                      size: 40,
                                                      color: Colors.grey),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                material['tbl_clothtype']
                                                    ['clothtype_name'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Cost: ₹${cost.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: accentColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Required Fabric Length: ${fabricLength.toStringAsFixed(1)} meters",
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
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _hexToColor(
                                                                color['hex']),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0.5),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          color['name'],
                                                          style:
                                                              const TextStyle(
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: measurements.length,
                                      itemBuilder: (context, mIndex) {
                                        final measurement =
                                            measurements[mIndex];
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
                  if (dressData.isNotEmpty) ...[
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
                              "Total Cost",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              "₹${calculateTotalCost().toStringAsFixed(2)}",
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
                    bookingData!['status'] == 0
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : showAcceptOrderDialog,
                                    label: const Text(
                                      "Accept Order",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            rejectOrder();
                                          },
                                    label: const Text(
                                      "Reject Order",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    icon: const Icon(Icons.dangerous_outlined,
                                        color: Colors.red),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
