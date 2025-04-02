import 'package:flutter/material.dart';
import 'package:userapp/main.dart';

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
    // Use dress_amount if available (after tailor acceptance), otherwise calculate material cost
    return dress['dress_amount'] != null
        ? (dress['dress_amount'] as num).toDouble()
        : calculateDressMaterialCost(dress);
  }

  double calculateTotalCost() {
    // Use booking amount if available (after tailor acceptance), otherwise sum material costs
    if (bookingData != null && bookingData!['amount'] != null) {
      return (bookingData!['amount'] as num).toDouble();
    }
    return dressData.fold(
      0.0,
      (sum, dress) => sum + calculateDressMaterialCost(dress),
    );
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return "Incomplete";
      case 1:
        return "Pending";
      case 2:
        return "Accepted";
      case 3:
        return "Rejected";
      case 4:
        return "Completed";
      case 5:
        return "Delivered";
      default:
        return "Unknown";
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingData != null) ...[
                Text(
                  "Status: ${getStatusText(bookingData!['status'])}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
                        final colors = (material['material_colors'] as List?)
                                ?.map((c) => c as Map<String, dynamic>)
                                .toList() ??
                            [];
                        String category =
                            dress['tbl_category']['category_name'];
                        String remark = dress['dress_remark'] ?? "No remarks";
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: material['material_photo'] != null
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
                const SizedBox(height: 8),
                Text(
                  bookingData != null && bookingData!['status'] >= 2
                      ? "Includes material and service costs."
                      : "Note: This is only the material cost; service cost will be added later.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
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