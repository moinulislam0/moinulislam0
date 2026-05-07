import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:provider/provider.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomAppBarProvider>();
      if (!provider.hasUser) {
        provider.fetchAppBar();
      }
    });
  }


  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == "N/A") return "N/A";
    try {
      DateTime date = DateTime.parse(dateStr);
      List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
   
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: Consumer<CustomAppBarProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }

            if (provider.errorMessage != null && !provider.hasUser) {
              return Center(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xff0D1F15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Personal Info",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 40.w),
                        ],
                      ),
                      SizedBox(height: 32.h),
                  
                      // Information Fields
                      _InfoField(
                          label: "Full Name", 
                          value: provider.name ?? "N/A"
                      ),
                      _InfoField(
                          label: "User Name", 
                          value: provider.username ?? "N/A"
                      ),
                      _InfoField(
                          label: "Email for Invoice", 
                          value: provider.email ?? "N/A"
                      ),
                      _InfoField(
                          label: "Phone", 
                          value: provider.data?.phoneNumber ?? "N/A"
                      ),
                      _InfoField(
                          label: "Date of Birth", 
                        
                          value: _formatDate(provider.data?.dateOfBirth)
                      ),
                      _InfoField(
                          label: "Gender", 
                          value: provider.data?.gender ?? "N/A"
                      ),
                      _InfoField(
                          label: "About", 
                          value: provider.data?.about ?? "N/A"
                      ),
                      _InfoField(
                          label: "Address", 
                          value: provider.data?.address ?? "N/A"
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xff707D74),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}