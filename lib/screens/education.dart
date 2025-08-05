import 'package:flutter/material.dart';
import 'package:hello_world/config/app_constants.dart';
import 'package:hello_world/services/user_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  List<Map<String, dynamic>> _educationList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _penggunaId;

  @override
  void initState() {
    super.initState();
    _loadEducationData();
  }

  Future<void> _loadEducationData() async {
    try {
      // Get user data to extract pengguna_id
      final userData = await UserStorageService.getUserData();
      final accessToken = await UserStorageService.getAccessToken();

      if (userData == null || accessToken == null) {
        setState(() {
          _errorMessage = 'User data or access token not found';
          _isLoading = false;
        });
        return;
      }

      _penggunaId = userData['data']?['pengguna_id']?.toString();

      if (_penggunaId == null) {
        setState(() {
          _errorMessage = 'User ID not found in user data';
          _isLoading = false;
        });
        return;
      }

      print('Loading education data for user ID: $_penggunaId');
      final url = '${AppConstants.educationList}/$_penggunaId';
      print('url education API : $url');
      // Call education API
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Education API Response Status: ${response.statusCode}');
      print('Education API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 200) {
          setState(() {
            _educationList = List<Map<String, dynamic>>.from(
              responseData['data'] ?? [],
            );
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                responseData['msg'] ?? 'Failed to load education data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load education data (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading education data: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEducationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadEducationData();
  }

  // Add Education Record (Local only)
  void _addEducationRecord(Map<String, dynamic> educationData) {
    // Generate a unique ID for the new record
    final newId =
        _educationList.isEmpty
            ? 1
            : _educationList
                    .map((e) => e['pendidikan_id'] ?? 0)
                    .reduce((a, b) => a > b ? a : b) +
                1;

    // Add the new record to the local list
    final newEducation = {'pendidikan_id': newId, ...educationData};

    setState(() {
      _educationList.add(newEducation);
    });

    _showMessage('Education record added successfully!');
    print('Added education record: $newEducation');
  }

  // Update Education Record (Local only)
  void _updateEducationRecord(
    int educationId,
    Map<String, dynamic> educationData,
  ) {
    final index = _educationList.indexWhere(
      (education) => education['pendidikan_id'] == educationId,
    );

    if (index != -1) {
      setState(() {
        // Update the existing record while preserving the ID
        _educationList[index] = {
          'pendidikan_id': educationId,
          ...educationData,
        };
      });

      _showMessage('Education record updated successfully!');
      print(
        'Updated education record at index $index: ${_educationList[index]}',
      );
    } else {
      _showMessage('Education record not found', isError: true);
    }
  }

  // Delete Education Record (Local only)
  void _deleteEducationRecord(int educationId) {
    final index = _educationList.indexWhere(
      (education) => education['pendidikan_id'] == educationId,
    );

    if (index != -1) {
      final deletedRecord = _educationList[index];
      setState(() {
        _educationList.removeAt(index);
      });

      _showMessage('Education record deleted successfully!');
      print('Deleted education record: $deletedRecord');
    } else {
      _showMessage('Education record not found', isError: true);
    }
  }

  // Show message function
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show Add Education Dialog
  void _showAddEducationDialog() {
    _showEducationDialog(isEdit: false);
  }

  // Show Edit Education Dialog
  void _showEditEducationDialog(Map<String, dynamic> education) {
    _showEducationDialog(isEdit: true, existingData: education);
  }

  // Show Delete Confirmation
  void _showDeleteConfirmation(Map<String, dynamic> education) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Education Record'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete this education record?'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        education['pendidikan_pusatpengajian'] ??
                            'Unknown Institution',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(education['pendidikan_kursus'] ?? 'Unknown Course'),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteEducationRecord(education['pendidikan_id']);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  // Main Education Dialog (for both Add and Edit)
  void _showEducationDialog({
    bool isEdit = false,
    Map<String, dynamic>? existingData,
  }) {
    final formKey = GlobalKey<FormState>();

    // Controllers for form fields
    final institutionController = TextEditingController(
      text: existingData?['pendidikan_pusatpengajian'] ?? '',
    );
    final courseController = TextEditingController(
      text: existingData?['pendidikan_kursus'] ?? '',
    );
    final specializationController = TextEditingController(
      text: existingData?['pendidikan_pengkhususan'] ?? '',
    );
    final cgpaController = TextEditingController(
      text: existingData?['pendidikan_cgpa']?.toString() ?? '',
    );
    final startDateController = TextEditingController(
      text: existingData?['pendidikan_tarikhmula'] ?? '',
    );
    final endDateController = TextEditingController(
      text: existingData?['pendidikan_tarikhtamat'] ?? '',
    );

    int selectedLevel = existingData?['pendidikan_taraf'] ?? 1;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              isEdit ? 'Edit Education Record' : 'Add Education Record',
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Institution field
                    TextFormField(
                      controller: institutionController,
                      decoration: InputDecoration(
                        labelText: 'Institution *',
                        hintText: 'Enter institution name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter institution name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Course field
                    TextFormField(
                      controller: courseController,
                      decoration: InputDecoration(
                        labelText: 'Course *',
                        hintText: 'Enter course name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter course name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Specialization field
                    TextFormField(
                      controller: specializationController,
                      decoration: InputDecoration(
                        labelText: 'Specialization',
                        hintText: 'Enter specialization',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Education Level dropdown
                    DropdownButtonFormField<int>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'Education Level *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 1, child: Text('SPM/SPMV/MCE')),
                        DropdownMenuItem(value: 2, child: Text('Diploma')),
                        DropdownMenuItem(value: 3, child: Text('Degree')),
                        DropdownMenuItem(value: 4, child: Text('Master')),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('PhD/Doctorate'),
                        ),
                      ],
                      onChanged: (value) {
                        selectedLevel = value ?? 1;
                      },
                    ),
                    SizedBox(height: 16),

                    // CGPA field
                    TextFormField(
                      controller: cgpaController,
                      decoration: InputDecoration(
                        labelText: 'CGPA',
                        hintText: 'Enter CGPA (0.00 - 4.00)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final cgpa = double.tryParse(value);
                          if (cgpa == null || cgpa < 0 || cgpa > 4) {
                            return 'Please enter valid CGPA (0.00 - 4.00)';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Start Date field
                    TextFormField(
                      controller: startDateController,
                      decoration: InputDecoration(
                        labelText: 'Start Date *',
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          startDateController.text =
                              date.toString().split(' ')[0];
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select start date';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // End Date field
                    TextFormField(
                      controller: endDateController,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        hintText: 'YYYY-MM-DD (Leave empty if ongoing)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2050),
                        );
                        if (date != null) {
                          endDateController.text =
                              date.toString().split(' ')[0];
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Active checkbox
                    // StatefulBuilder(
                    //   builder: (context, setState) {
                    //     return CheckboxListTile(
                    //       title: Text('Active Record'),
                    //       subtitle: Text('Uncheck to mark as inactive'),
                    //       value: _isActive,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _isActive = value ?? true;
                    //         });
                    //       },
                    //       controlAffinity: ListTileControlAffinity.leading,
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Prepare data for local list
                    final educationData = {
                      'pengguna_id': _penggunaId,
                      'pendidikan_pusatpengajian': institutionController.text,
                      'pendidikan_kursus': courseController.text,
                      'pendidikan_pengkhususan':
                          specializationController.text.isEmpty
                              ? null
                              : specializationController.text,
                      'pendidikan_taraf': selectedLevel,
                      'pendidikan_cgpa':
                          cgpaController.text.isEmpty
                              ? null
                              : double.tryParse(cgpaController.text),
                      'pendidikan_tarikhmula': startDateController.text,
                      'pendidikan_tarikhtamat':
                          endDateController.text.isEmpty
                              ? null
                              : endDateController.text,
                      'aktif':
                          1, // Default to active since checkbox is disabled
                    };

                    Navigator.of(context).pop();

                    if (isEdit && existingData != null) {
                      _updateEducationRecord(
                        existingData['pendidikan_id'],
                        educationData,
                      );
                    } else {
                      _addEducationRecord(educationData);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  isEdit ? 'Update' : 'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> education) {
    // Map education level numbers to readable text
    String getEducationLevel(int? level) {
      switch (level) {
        case 1:
          return 'SPM/SPMV/MCE';
        case 2:
          return 'Diploma';
        case 3:
          return 'Degree';
        case 4:
          return 'Master';
        case 5:
          return 'PhD/Doctorate';
        default:
          return 'Unknown Level';
      }
    }

    // Format date strings
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return dateStr;
      }
    }

    // Determine status based on completion date and aktif flag
    String getStatus() {
      final isActive = education['aktif'] == 1;
      final endDate = education['pendidikan_tarikhtamat'];

      if (!isActive) return 'Inactive';
      if (endDate == null || endDate.isEmpty) return 'Ongoing';
      return 'Completed';
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    education['pendidikan_pusatpengajian'] ??
                        'Unknown Institution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.book,
              'Course',
              education['pendidikan_kursus'] ?? 'N/A',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.category,
              'Specialization',
              education['pendidikan_pengkhususan'] ?? 'N/A',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.grade,
              'Level',
              getEducationLevel(education['pendidikan_taraf']),
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Start Date',
              formatDate(education['pendidikan_tarikhmula']),
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.event_available,
              'End Date',
              formatDate(education['pendidikan_tarikhtamat']) == 'N/A'
                  ? 'Ongoing'
                  : formatDate(education['pendidikan_tarikhtamat']),
            ),
            if (education['pendidikan_cgpa'] != null) ...[
              SizedBox(height: 8),
              _buildInfoRow(
                Icons.star,
                'CGPA',
                education['pendidikan_cgpa'].toString(),
              ),
            ],
            SizedBox(height: 12),
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditEducationDialog(education),
                  icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                  label: Text('Edit', style: TextStyle(color: Colors.blue)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(education),
                  icon: Icon(Icons.delete, size: 16, color: Colors.red),
                  label: Text('Delete', style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800]))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Education History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshEducationData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEducationDialog,
        backgroundColor: Colors.blue,
        tooltip: 'Add Education Record',
        child: Icon(Icons.add, color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text('Loading education data...'),
                  ],
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshEducationData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : _educationList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Education Records',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No education history found for user ID: $_penggunaId',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshEducationData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _refreshEducationData,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: _educationList.length,
                  itemBuilder: (context, index) {
                    return _buildEducationCard(_educationList[index]);
                  },
                ),
              ),
    );
  }
}
