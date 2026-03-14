class HotelPriceBreakdown {
  final int coreRoomFee;
  final int extraFeeForCheckIn;
  final int extraFeeForCheckOut;

  const HotelPriceBreakdown({
    required this.coreRoomFee,
    required this.extraFeeForCheckIn,
    required this.extraFeeForCheckOut,
  });

  int get total => coreRoomFee + extraFeeForCheckIn + extraFeeForCheckOut;
}

/// Calculates hotel price breakdown based on actual check-in/out times.
///
/// Standard times:
///   - Check-in:  14:00
///   - Check-out: 12:00
///
/// [checkInDateTime]       Booked check-in date (time ignored, always 14:00)
/// [checkOutDateTime]      Booked check-out date (time ignored, always 12:00)
/// [actualCheckInDateTime] Actual time guest arrived (null = arrived on time at 14:00)
/// [actualCheckOutDateTime]Actual time guest left    (null = left on time at 12:00)
/// [pricePerNight]         Room price per night in smallest currency unit
/// [graceMinutes]          Tolerance window before surcharge applies (default: 15 min)
///
/// Edge cases:
///
/// 1. Early check-in surcharge:
///    - Within grace period (≤15 min early)  → no charge
///    - 15 min – 6 hours early               → 25% of pricePerNight
///    - 6 – 12 hours early                   → 50% of pricePerNight
///    - More than 12 hours early             → 100% of pricePerNight (full extra night)
///
/// 2. Late check-out surcharge:
///    - Within grace period (≤15 min late)   → no charge
///    - 15 min – 6 hours late                → 25% of pricePerNight
///    - 6 – 12 hours late                    → 50% of pricePerNight
///    - More than 12 hours late              → 100% of pricePerNight (full extra night)
///
/// 3. Early check-out (guest leaves before standard 12:00):
///    - Night count uses actual checkout date instead of booked checkout date
///    - No surcharge for leaving early (guest already pays fewer nights)
///
/// 4. Minimum 1 night:
///    - Even if date diff is 0 (same-day booking edge case), at least 1 night is charged
///
/// 5. Late check-in (guest arrives after standard 14:00):
///    - No surcharge, no discount — coreRoomFee is based on booked dates only
HotelPriceBreakdown calculateHotelPrice({
  required DateTime checkInDateTime,
  required DateTime checkOutDateTime,
  DateTime? actualCheckInDateTime,
  DateTime? actualCheckOutDateTime,
  required int pricePerNight,
  int graceMinutes = 15,
}) {
  final DateTime standardCheckIn = DateTime(
    checkInDateTime.year,
    checkInDateTime.month,
    checkInDateTime.day,
    14,
  );
  final DateTime standardCheckOut = DateTime(
    checkOutDateTime.year,
    checkOutDateTime.month,
    checkOutDateTime.day,
    12,
  );

  final DateTime actualIn = actualCheckInDateTime ?? standardCheckIn;
  final DateTime actualOut = actualCheckOutDateTime ?? standardCheckOut;

  // ----- Core room fee -----
  // Edge case 3: if guest checks out early, shrink the night count accordingly.
  // Late checkout does NOT extend night count — that is handled as a surcharge instead.
  final DateTime effectiveCheckOut = actualOut.isBefore(standardCheckOut)
      ? actualOut
      : standardCheckOut;

  final DateTime checkInDateOnly = DateTime(
    actualIn.year,
    actualIn.month,
    actualIn.day,
  );
  final DateTime checkOutDateOnly = DateTime(
    effectiveCheckOut.year,
    effectiveCheckOut.month,
    effectiveCheckOut.day,
  );

  // Edge case 4: date-only diff avoids 22h truncation (14:00 in → 12:00 out = 0 inDays).
  // Minimum 1 night enforced.
  int nights = checkOutDateOnly.difference(checkInDateOnly).inDays;
  if (nights < 1) nights = 1;
  final int coreRoomFee = nights * pricePerNight;

  // ----- Early check-in fee -----
  // Edge case 1: surcharge tiers use fractional hours (inMinutes / 60.0)
  // to avoid inHours truncation (e.g. 6h 59m should be 50%, not 25%).
  int extraFeeForCheckIn = 0;
  if (actualIn.isBefore(standardCheckIn)) {
    final Duration early = standardCheckIn.difference(actualIn);
    if (early.inMinutes > graceMinutes) {
      final double earlyHours = early.inMinutes / 60.0;
      if (earlyHours <= 6) {
        extraFeeForCheckIn = (pricePerNight * 0.25).round();
      } else if (earlyHours <= 12) {
        extraFeeForCheckIn = (pricePerNight * 0.5).round();
      } else {
        extraFeeForCheckIn = pricePerNight;
      }
    }
  }

  // ----- Late check-out fee -----
  // Edge case 2: same tier logic as early check-in.
  // Edge case 3: if actualOut is before standardCheckOut, this block is skipped entirely.
  int extraFeeForCheckOut = 0;
  if (actualOut.isAfter(standardCheckOut)) {
    final Duration late = actualOut.difference(standardCheckOut);
    if (late.inMinutes > graceMinutes) {
      final double lateHours = late.inMinutes / 60.0;
      if (lateHours <= 6) {
        extraFeeForCheckOut = (pricePerNight * 0.25).round();
      } else if (lateHours <= 12) {
        extraFeeForCheckOut = (pricePerNight * 0.5).round();
      } else {
        extraFeeForCheckOut = pricePerNight;
      }
    }
  }

  return HotelPriceBreakdown(
    coreRoomFee: coreRoomFee,
    extraFeeForCheckIn: extraFeeForCheckIn,
    extraFeeForCheckOut: extraFeeForCheckOut,
  );
}
