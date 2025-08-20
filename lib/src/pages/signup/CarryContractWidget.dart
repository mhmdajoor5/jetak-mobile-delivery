import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../repository/user_repository.dart' as userRepo;
import 'SelectNationalityWidget.dart';

class CarryContractWidget extends StatefulWidget {
  const CarryContractWidget({super.key});

  @override
  _CarryContractWidgetState createState() =>
      _CarryContractWidgetState();
}

class _CarryContractWidgetState
    extends StateMVC<CarryContractWidget> {
  late UserController _con;
  String userName = "User"; // Default value, should be replaced with actual user name
  String approvedDate = "2024-01-01"; // Default value, should be replaced with actual date
  bool _isLoading = false;

  _CarryContractWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
  }

  @override
  void initState() {
    super.initState();
    // Get actual user data
    final user = userRepo.currentUser.value;
    if (user.name != null && user.name!.isNotEmpty) {
      userName = user.name!;
    } else if (user.firstName != null && user.firstName!.isNotEmpty) {
      userName = user.firstName!;
    }
    // You can set approvedDate based on actual data if available
  }

  Future<void> _completeContract() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update user active status to 1 (active)
      final success = await userRepo.updateUserActiveStatus(1);
      if (success) {
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete contract. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900], // Add background color
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello $userName!",
                style:  TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
               SizedBox(height: 8),

               Text(
                S.of(context).would_you_like,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
               SizedBox(height: 6),
               Text(
                S.of(context).please_follow_steps,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

               SizedBox(height: 20),

              Row(
                children: [
                   Icon(Icons.check_circle, color: Colors.green),
                   SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).send_application,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          margin:  EdgeInsets.only(top: 4),
                          padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:  Text(
                            S.of(context).approved,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                         SizedBox(height: 4),
                        Text(
                          approvedDate,
                          style:  TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

               SizedBox(height: 20),

              Row(
                children: [
                   Icon(Icons.description, color: Colors.green),
                   SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(
                          S.of(context).contract,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          S.of(context).please_fill_info,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

               SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:  EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: null,
                  // onPressed: _isLoading ? null : () async {
                  //   // Complete contract and activate user
                  //   await _completeContract();
                  // },

                  child: _isLoading 
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        S.of(context).Continue,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),

               SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side:  BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                  },
                  icon:  Icon(Icons.support_agent, color: Colors.blue),
                  label:  Text(
                    S.of(context).contact_support,
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

               SizedBox(height: 10),
               Center(
                child: Text(
                  S.of(context).we_will_get_back,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
