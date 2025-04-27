import 'dart:async';
import 'dart:convert';
import 'package:medicare_app/screens/appointment.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class MongoDBService {
  static const String MONGO_URL = "mongodb+srv://medicare:healthcareapp@cluster0.8t4xx.mongodb.net/Healthcarebot?retryWrites=true&w=majority&appName=Cluster0";
  static const String DATABASE_NAME = "Healthcarebot";
  static const String COLLECTION_NAME = "doctors";

  static Db? _db;
  static DbCollection? _collection;

  static const String baseUrl = 'http://192.168.157.28:2000/api';
  static const String socketUrl = 'http://192.168.157.28:2000';

  static IO.Socket? socket;
  static String? currentUserId;
  static String? currentUserName;
  static String? currentUserType;
  
  // Listeners for real-time updates
  static final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _appointmentController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Access streams
  static Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  static Stream<Map<String, dynamic>> get appointmentStream => _appointmentController.stream;
  static Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  
  // Initialize socket connection
  static Future<void> initializeSocket(String userId, String userName, String userType) async {
    currentUserId = userId;
    currentUserName = userName;
    currentUserType = userType;
    
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    
    socket!.onConnect((_) {
      print('Socket connected: ${socket!.id}');
      socket!.emit('join', userId);
      socket!.emit('user:online', {
        'userId': userId,
        'userType': userType,
      });
    });
    
    // Listen for private messages
    socket!.on('private-message', (data) {
      print('Received private message: $data');
      _messageController.add(data);
    });
    
    // Listen for appointment updates
    socket!.on('appointment:updated', (data) {
      print('Appointment updated: $data');
      _appointmentController.add(data);
    });
    
    // Listen for new notes
    socket!.on('appointment:note-added', (data) {
      print('Note added to appointment: $data');
      _appointmentController.add(data);
    });
    
    // Listen for doctor status changes
    socket!.on('doctor:status-changed', (data) {
      print('Doctor status changed: $data');
      _notificationController.add({
        'type': 'doctor_status',
        'data': data
      });
    });
    
    socket!.onDisconnect((_) => print('Socket disconnected'));
    socket!.onError((err) => print('Socket error: $err'));
  }
  
  static void disconnectSocket() {
    if (socket != null && socket!.connected) {
      socket!.emit('user:offline', {
        'userId': currentUserId,
        'userType': currentUserType,
      });
      socket!.disconnect();
      print('Socket disconnected');
    }
  }

  
  
  // Send a private message
  static Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String receiverName,
    required String message
  }) async {
    try {
      if (currentUserId == null || currentUserName == null) {
        throw Exception('User not logged in');
      }
      
      final messageData = {
        'senderId': currentUserId,
        'senderName': currentUserName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'message': message
      };
      
      // Send via socket
      socket?.emit('private-message', messageData);
      
      // Also send via HTTP to ensure delivery
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(messageData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print("Error sending message: $e");
      throw e;
    }
  }
  
  // Add this method to your MongoDBService class
static Future<List<Doctor>> searchDoctors(String query) async {
  try {
    // First try to search via the API
    try {
      print('Searching doctors from API with query: $query');
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/search?name=$query'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> doctorsJson = json.decode(response.body);
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        print('API search returned error status: ${response.statusCode}');
        // Fall back to local filtering if API fails
        throw Exception('API search error: ${response.statusCode}');
      }
    } catch (apiError) {
      print('API search failed, trying local filtering: $apiError');
      
      // If API search fails, get all doctors and filter locally
      final allDoctors = await fetchDoctors();
      
      // Create a case-insensitive search pattern
      final searchPattern = RegExp(query, caseSensitive: false);
      
      // Filter doctors whose name matches the search pattern
      return allDoctors.where((doctor) => 
        searchPattern.hasMatch(doctor.name)
      ).toList();
    }
  } catch (e) {
    print('Error searching doctors: $e');
    return [];
  }
}

  // Get conversation history
  static Future<List<Map<String, dynamic>>> getConversation(String otherUserId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$currentUserId/$otherUserId'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch conversation');
      }
    } catch (e) {
      print("Error fetching conversation: $e");
      return [];
    }
  }
  
  // Get unread message count
  static Future<int> getUnreadMessageCount() async {
    try {
      if (currentUserId == null) {
        return 0;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/messages/unread/$currentUserId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['unreadCount'];
      } else {
        return 0;
      }
    } catch (e) {
      print("Error getting unread message count: $e");
      return 0;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, {String userType = 'patient'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'uname': name, 
          'umail': email, 
          'upassword': password,
          'userType': userType
        }),
      );

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Error during register: $e");
      return {'status_code': 500, 'message': 'Server error'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login_user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'umail': email, 'upassword': password}),
      );

      print("Login response code: ${response.statusCode}");
      print("Login response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status_code'] == 200 && data['user'] != null) {
          // Store user info in shared preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', data['user']['_id']);
          prefs.setString('userName', data['user']['uname']);
          prefs.setString('userEmail', data['user']['umail']);
          prefs.setString('userType', data['user']['userType'] ?? 'patient');
          
          // Initialize socket connection
          initializeSocket(
            data['user']['_id'], 
            data['user']['uname'],
            data['user']['userType'] ?? 'patient'
          );
        }
        return data;
      } else {
        return {'status_code': response.statusCode, 'message': 'Login failed'};
      }
    } catch (e) {
      print("Error during login: $e");
      return {'status_code': 500, 'message': 'Server error'};
    }
  }
  
  Future<Map<String, dynamic>> logout() async {
    try {
      if (currentUserId == null) {
        return {'status_code': 400, 'message': 'Not logged in'};
      }
      
      // Disconnect socket
      disconnectSocket();
      
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'userId': currentUserId}),
      );
      
      // Clear stored user data
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('userId');
      prefs.remove('userName');
      prefs.remove('userEmail');
      prefs.remove('userType');
      
      currentUserId = null;
      currentUserName = null;
      currentUserType = null;
      
      return {'status_code': 200, 'message': 'Logout successful'};
    } catch (e) {
      print("Error during logout: $e");
      return {'status_code': 500, 'message': 'Server error'};
    }
  }

  static Future<List<Doctor>> fetchDoctors() async {
    try {
      // First try to connect to the Node.js API
      try {
        print('Fetching doctors from API: $baseUrl/doctors');
        final response = await http.get(
          Uri.parse('$baseUrl/doctors'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));
        
        print('Response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final List<dynamic> doctorsJson = json.decode(response.body);
          return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
        } else {
          print('API returned error status: ${response.statusCode}');
          // Fall back to direct MongoDB connection if API fails
          throw Exception('API error: ${response.statusCode}');
        }
      } catch (apiError) {
        print('API fetch failed, trying direct MongoDB connection: $apiError');
        // If API call fails, fall back to direct MongoDB connection
        return await getDoctorsFromMongoDB();
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      throw e;
    }
  }
  
  // Get online doctors
  static Future<List<Doctor>> fetchOnlineDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/online'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> doctorsJson = json.decode(response.body);
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching online doctors: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addDoctor({
    required String name,
    required String specialization,
    String? hospital,
    String? location,
    String? experience,
    required double rating,
    required bool available,
    required List<String> slots,
  }) async {
    try {
      print('Adding doctor: {name: $name, specialization: $specialization, hospital: $hospital, location: $location, experience: $experience, rating: $rating, available: $available, slots: $slots}');
      
      // Create default dateSlots for the next 7 days
      final Map<String, List<String>> dateSlots = {};
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        dateSlots[dateStr] = List.from(slots); // Create a copy for each date
      }
      
      final url = Uri.parse('$baseUrl/doctors');
      print('Sending to URL: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'specialization': specialization,
          'hospital': hospital,
          'location': location,
          'experience': experience,
          'rating': rating,
          'available': available,
          'slots': slots, // Keep for backward compatibility
          'dateSlots': dateSlots, // Add the new date-specific slots
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add doctor: ${response.body}');
      }
    } catch (e) {
      print('Error adding doctor: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctorAppointments(String doctorId) async {
    try {
      final url = Uri.parse('$baseUrl/appointments/doctor/$doctorId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('API returned error status: ${response.statusCode}');
        // Fall back to direct MongoDB connection if API fails
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (apiError) {
      print('API fetch failed, trying direct MongoDB connection: $apiError');
      // Fall back to direct MongoDB connection
      try {
        await connect(); // Ensure connection is established
        
        final appointmentCollection = _db!.collection('appointments');
        final List<Map<String, dynamic>> appointments = await appointmentCollection
            .find(where.eq('doctorId', doctorId))
            .toList();
        
        return appointments;
      } catch (dbError) {
        print('Error fetching doctor appointments from MongoDB: $dbError');
        return [];
      }
    }
  }

  // Add a new method to get doctors directly from MongoDB
  static Future<List<Doctor>> getDoctorsFromMongoDB() async {
    try {
      await connect(); // Ensure connection is established
      
      final List<Map<String, dynamic>> doctorsData = await _collection!.find().toList();
      return doctorsData.map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching doctors from MongoDB: $e');
      return [];
    }
  }  

  static Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final url = Uri.parse('$baseUrl/appointments/$appointmentId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      
      // Also emit via socket for real-time update
      socket?.emit('appointment:update', {
        'appointmentId': appointmentId,
        'status': status
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  // Initialize the database connection
  static Future<void> connect() async {
    if (_db == null || !_db!.isConnected) {
      try {
        _db = await Db.create(MONGO_URL);
        await _db!.open();
        _collection = _db!.collection(COLLECTION_NAME);
        print('Connected to MongoDB successfully!');
      } catch (e) {
        print('Error connecting to MongoDB: $e');
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> bookAppointment({
  required String userId,
  required String userName,
  required String doctorId,
  required String doctorName,
  required String specialization,
  required String date,   // Make sure this date is being sent
  required String time,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'userName': userName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialization': specialization,
        'date': date,     // Include date in the request
        'time': time,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to book appointment: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error booking appointment: $e');
  }
}

  // New method to update doctor's available slots after booking
  // In MongoDBService class, update the updateDoctorSlot method
static Future<void> updateDoctorSlot(String doctorId, String date, String time) async {
  try {
    print('Updating doctor slots: {doctorId: $doctorId, date: $date, time: $time}');
    
    // First try using the API
    try {
      final url = Uri.parse('$baseUrl/doctors/$doctorId/slots');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'date': date,
          'time': time,
          'action': 'remove'
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('API failed to update slot: ${response.body}');
      }
    } catch (apiError) {
      print('API update failed, trying direct MongoDB update: $apiError');
      
      // If API fails, update MongoDB directly
      await connect(); // Ensure connection
      
      // First get the current doctor data
      final doctor = await _collection!.findOne(where.eq('_id', ObjectId.parse(doctorId)));
      
      if (doctor == null) {
        throw Exception('Doctor not found');
      }
      
      // Check if dateSlots exists, if not create it
      if (doctor['dateSlots'] == null) {
        Map<String, List<String>> dateSlots = {};
        
        // If old slots exists, use them as a template
        final List<String> oldSlots = doctor['slots'] != null 
            ? List<String>.from(doctor['slots']) 
            : ["10:00 AM", "11:30 AM", "2:00 PM"];
        
        // Create slots for each day
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final d = now.add(Duration(days: i));
          final dateStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          dateSlots[dateStr] = List.from(oldSlots);
        }
        
        // Update doctor with new dateSlots structure
        await _collection!.update(
          where.eq('_id', ObjectId.parse(doctorId)),
          modify.set('dateSlots', dateSlots)
        );
        
        // Get updated doctor
        doctor['dateSlots'] = dateSlots;
      }
      
      // Now we can remove the booked time from the specific date
      if (doctor['dateSlots'][date] != null) {
        List<String> dateSlots = List<String>.from(doctor['dateSlots'][date]);
        
        // Check if the time exists in slots before removing
        if (dateSlots.contains(time)) {
          dateSlots.remove(time);
          
          // Update in MongoDB - only for the specific date
          await _collection!.update(
            where.eq('_id', ObjectId.parse(doctorId)),
            modify.set('dateSlots.$date', dateSlots)
          );
          
          print('Successfully removed time slot $time from date $date');
        } else {
          print('Time slot $time not found for date $date');
        }
      } else {
        print('No slots found for date $date');
      }
    }
  } catch (e) {
    print('Error updating doctor slot: $e');
    throw e;
  }
}
  // Add note to an appointment
  static Future<Map<String, dynamic>> addNoteToAppointment({
    required String appointmentId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/appointments/$appointmentId/notes');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'userName': userName,
          'text': text,
        }),
      );
      
      // Also emit via socket for real-time update
      socket?.emit('appointment:add-note', {
        'appointmentId': appointmentId,
        'userId': userId,
        'userName': userName,
        'text': text,
      });
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add note: ${response.body}');
      }
    } catch (e) {
      print('Error adding note to appointment: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/appointments/user/$userId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch appointments');
      }
    } catch (e) {
      print('Error fetching user appointments: $e');
      return [];
    }
  }
  
  // Close the database connection
  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      print('Disconnected from MongoDB.');
    }
  }
  
  // Fetch all doctors
  static Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      if (_db == null || !_db!.isConnected) {
        await connect();
      }
      
      final List<Map<String, dynamic>> doctors = await _collection!.find().toList();
      return doctors;
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }
  
  // Cleanup resources
  static void dispose() {
    disconnectSocket();
    _messageController.close();
    _appointmentController.close();
    _notificationController.close();
  }
}
