import 'package:hms_app/models/dtos/booking_schedule_item.dart';
import 'package:hms_app/models/enums/booking_status.dart';
import 'package:hms_app/models/service.dart';

class ServiceUsage {
  final Service service;
  final int quantity;

  ServiceUsage({required this.service, required this.quantity});

  factory ServiceUsage.fromJson(Map<String, dynamic> json) {
    final quantity = (json['service_usage'] as List).isEmpty
        ? 0
        : (json['service_usage'] as List)[0]['quantity'] as int;
    return ServiceUsage(service: Service.fromJson(json), quantity: quantity);
  }
}

class BookingDetails extends BookingScheduleItem {
  // service usage
  final List<ServiceUsage> usedServices;

  BookingDetails({
    required super.id,
    required super.customerAvatar,
    required super.customerName,
    required super.checkInDateTime,
    required super.checkoutDateTime,
    super.actualCheckOutDateTime,
    super.actualCheckInDateTime,
    required super.status,
    required super.customerPhone,
    required this.usedServices,
  });

  factory BookingDetails.fromJson(
    Map<String, dynamic> booking,
    List<dynamic> services,
  ) {
    return BookingDetails(
      id: booking['id'] as int,
      customerAvatar: booking['user_profiles']['avatar_url'] as String?,
      customerName: booking['user_profiles']['full_name'] as String,
      customerPhone: booking['user_profiles']['phone'] as String,
      checkInDateTime: DateTime.parse(booking['check_in_date_time'] as String),
      checkoutDateTime: DateTime.parse(
        booking['check_out_date_time'] as String,
      ),
      actualCheckOutDateTime: booking['actual_check_out_date_time'] != null
          ? DateTime.parse(booking['actual_check_out_date_time'] as String)
          : null,
      actualCheckInDateTime: booking['actual_check_in_date_time'] != null
          ? DateTime.parse(booking['actual_check_in_date_time'] as String)
          : null,
      status: booking['status'] is String
          ? BookingStatusExtension.fromDatabaseValue(
              booking['status'] as String,
            )
          : BookingStatus.confirmed,
      usedServices: services
          .map((e) => ServiceUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
