import 'package:flutter/material.dart';
import 'package:medicare_app/services/mongo_service.dart';

void main() {
  runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AddDoctorScreen(),
  ),
);
}

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  
  double _rating = 4.5;
  bool _isAvailable = true;
  
  final List<String> _slots = ["10:00 AM", "11:30 AM", "2:00 PM"];
  final List<bool> _selectedSlots = [true, true, true];
  
  final List<String> _commonSlots = [
    "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "11:30 AM", 
    "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"
  ];
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _hospitalController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Filter only selected slots
        final List<String> selectedSlots = [];
        for (int i = 0; i < _slots.length; i++) {
          if (_selectedSlots[i]) {
            selectedSlots.add(_slots[i]);
          }
        }
        
        // Add doctor to database
        final result = await MongoDBService.addDoctor(
          name: _nameController.text,
          specialization: _specializationController.text,
          hospital: _hospitalController.text,
          location: _locationController.text,
          experience: _experienceController.text,
          rating: _rating,
          available: _isAvailable,
          slots: selectedSlots,
        );
        
        // Show success message
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doctor added successfully"),
            backgroundColor: Colors.blue,
          ),
        );
        
        // Clear form
        _nameController.clear();
        _specializationController.clear();
        _hospitalController.clear();
        _locationController.clear();
        _experienceController.clear();
        setState(() {
          _rating = 4.5;
          _isAvailable = true;
          _selectedSlots.fillRange(0, _selectedSlots.length, true);
        });
        
      } catch (e) {
        // Show error message
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add doctor: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  void _addSlot() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Time Slot"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _commonSlots.length,
            itemBuilder: (context, index) {
              final slot = _commonSlots[index];
              final isAlreadyAdded = _slots.contains(slot);
              
              return ListTile(
                title: Text(slot),
                enabled: !isAlreadyAdded,
                onTap: isAlreadyAdded ? null : () {
                  setState(() {
                    _slots.add(slot);
                    _selectedSlots.add(true);
                  });
                  Navigator.pop(context);
                },
                trailing: isAlreadyAdded ? const Icon(Icons.check) : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Doctor"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Doctor Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter doctor's name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Specialization field
                    TextFormField(
                      controller: _specializationController,
                      decoration: const InputDecoration(
                        labelText: "Specialization",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter specialization";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Hospital field
                    TextFormField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(
                        labelText: "Hospital",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location field
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Experience field
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: "Experience (e.g., 5+ years)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Rating slider
                    Row(
                      children: [
                        const Text(
                          "Rating: ",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                      ],
                    ),
                    Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Availability toggle
                    Row(
                      children: [
                        Switch(
                          value: _isAvailable,
                          onChanged: (value) {
                            setState(() {
                              _isAvailable = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAvailable ? "Available" : "Not Available",
                          style: TextStyle(
                            color: _isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Time slots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Available Slots",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addSlot,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Slot"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_slots.length, (index) {
                        return FilterChip(
                          label: Text(_slots[index]),
                          selected: _selectedSlots[index],
                          onSelected: (selected) {
                            setState(() {
                              _selectedSlots[index] = selected;
                            });
                          },
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue,
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Add Doctor",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}