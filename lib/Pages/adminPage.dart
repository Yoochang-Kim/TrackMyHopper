import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _emailController = TextEditingController(); // Controller for managing the email input field.
  Map<String, dynamic> _userData = {}; // Stores user data fetched from Firebase.

  @override
  void initState() {
    super.initState();
  }

  // Converts UTC time string to local time.
  String convertToLocalTime(String time) {
    final inputFormat = new DateFormat("EEE, dd MMM yyyy HH:mm");
    final outputFormat = new DateFormat("EEE, dd MMM yyyy hh:mm a");
    final date = inputFormat.parse(time, true).toLocal();
    return outputFormat.format(date);
  }

  // Fetches user information based on the provided email.
  Future<void> getUserInfo() async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'getUserInfo',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 5),
      ),
    );

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'email': _emailController.text,
        },
      );

      setState(() {
        _userData = Map<String, dynamic>.from(result.data);
        //print(_userData);
      });
    } catch (e) {
      //print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errors ${e.toString()}')),
      );
    }
  }

  // Updates the admin status of a user in Firebase.
  Future<void> updateAdminStatus(String uid, bool isAdmin) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'updateAdminStatus',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 5),
      ),
    );

    try {
      await callable.call(
        <String, dynamic>{
          'uidToUpdate': uid,
          'isAdmin': isAdmin,
        },
      ).then((value) =>
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value.data['result'].toString()))
        )
      );
      await getUserInfo();  // Refresh user info
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${e.toString()}')),
      );
    }
  }

  // Updates the email verification status of a user in Firebase.
  Future<void> updateEmailVerificationStatus(String uid, bool status) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'updateEmailVerificationStatus',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 5),
      ),
    );

    try {
      await callable.call(
        <String, dynamic>{
          'uidToUpdate': uid,
          'status': status,
        },
      ).then((value) =>
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value.data['result'].toString())),
          )
      );
      await getUserInfo();
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search User Page'),
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'User Email'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: getUserInfo,
              child: const Text('Get User Info'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _userData.isNotEmpty
                  ? DataTable2(
                columnSpacing: 12,  // Increase spacing between columns
                horizontalMargin: 12,
                minWidth: 1200,
                dataRowHeight: 100,
                columns: const [
                  DataColumn2(
                    label: Text('uid', style: TextStyle(fontWeight: FontWeight.bold)),  // Apply bold text
                    size: ColumnSize.S,
                  ),
                  DataColumn(
                    label: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('emailVerified', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('creationTime', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('lastSignInTime', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('lastRefreshTime', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),  // Add padding to cells
                      child: Text(_userData['uid'] ?? 'N/A'),
                    )),
                    DataCell(Checkbox(
                      value: _userData['isAdmin'] ?? false,
                      onChanged: (bool? newValue) {
                        // Call a function to update the admin status in Firebase
                        updateAdminStatus(_userData['uid'], newValue!);
                      }, // Checkbox is read-only
                    )),
                    DataCell(Checkbox(
                      value: _userData['emailVerified'] ?? false,
                      onChanged: (bool? newValue) {
                        // Call a function to update the email verification status in Firebase
                        updateEmailVerificationStatus(_userData['uid'], newValue!);
                      },
                    )),
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(convertToLocalTime(_userData['metadata']['creationTime'] ?? 'N/A')),
                    )),
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(convertToLocalTime(_userData['metadata']['lastSignInTime'] ?? 'N/A')),
                    )),
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(convertToLocalTime(_userData['metadata']['lastRefreshTime'] ?? 'N/A')),
                    )),
                  ]),
                ],
              )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
