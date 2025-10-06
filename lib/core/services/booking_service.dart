import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/booking_model.dart';

/// Service for managing plot bookings/reservations
class BookingService {
  static const String _bookingsKey = 'user_bookings';

  /// Add a new booking
  static Future<void> addBooking(BookingModel booking) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(_bookingsKey) ?? '[]';
      final List<dynamic> bookingsList = json.decode(bookingsJson);
      
      // Convert to BookingModel list
      List<BookingModel> bookings = bookingsList
          .map((json) => BookingModel.fromJson(json))
          .toList();
      
      // Add new booking
      bookings.add(booking);
      
      // Save back to SharedPreferences
      final updatedBookingsJson = json.encode(
        bookings.map((booking) => booking.toJson()).toList(),
      );
      await prefs.setString(_bookingsKey, updatedBookingsJson);
      
      print('BookingService: Added booking for plot ${booking.plotNo}');
    } catch (e) {
      print('BookingService: Error adding booking: $e');
      throw Exception('Failed to add booking: $e');
    }
  }

  /// Get all bookings
  static Future<List<BookingModel>> getBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(_bookingsKey) ?? '[]';
      final List<dynamic> bookingsList = json.decode(bookingsJson);
      
      return bookingsList
          .map((json) => BookingModel.fromJson(json))
          .toList();
    } catch (e) {
      print('BookingService: Error getting bookings: $e');
      return [];
    }
  }

  /// Get booking by ID
  static Future<BookingModel?> getBookingById(String id) async {
    try {
      final bookings = await getBookings();
      return bookings.firstWhere(
        (booking) => booking.id == id,
        orElse: () => throw Exception('Booking not found'),
      );
    } catch (e) {
      print('BookingService: Error getting booking by ID: $e');
      return null;
    }
  }

  /// Update booking status
  static Future<void> updateBookingStatus(String id, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(_bookingsKey) ?? '[]';
      final List<dynamic> bookingsList = json.decode(bookingsJson);
      
      // Find and update the booking
      for (int i = 0; i < bookingsList.length; i++) {
        if (bookingsList[i]['id'] == id) {
          bookingsList[i]['status'] = status;
          if (status == 'paid') {
            bookingsList[i]['paidAt'] = DateTime.now().toIso8601String();
          }
          break;
        }
      }
      
      // Save back to SharedPreferences
      await prefs.setString(_bookingsKey, json.encode(bookingsList));
      
      print('BookingService: Updated booking $id status to $status');
    } catch (e) {
      print('BookingService: Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }

  /// Remove expired bookings
  static Future<void> removeExpiredBookings() async {
    try {
      final bookings = await getBookings();
      final activeBookings = bookings.where((booking) => !booking.isExpired).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final updatedBookingsJson = json.encode(
        activeBookings.map((booking) => booking.toJson()).toList(),
      );
      await prefs.setString(_bookingsKey, updatedBookingsJson);
      
      print('BookingService: Removed ${bookings.length - activeBookings.length} expired bookings');
    } catch (e) {
      print('BookingService: Error removing expired bookings: $e');
    }
  }

  /// Clear all bookings
  static Future<void> clearAllBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookingsKey);
      print('BookingService: Cleared all bookings');
    } catch (e) {
      print('BookingService: Error clearing bookings: $e');
      throw Exception('Failed to clear bookings: $e');
    }
  }
}
