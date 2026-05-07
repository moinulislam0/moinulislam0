import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwells/app/widgets/buttons/primary_button.dart';
import 'package:jwells/features/auth/model_view/edit_profile_provider.dart';
import 'package:jwells/features/payment/presentation/view/widgets/custom_app_bar.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart'; // Import this
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color darkBackground = Color(0xff010702);
  static const Color primaryGreen = Color(0xff44EF89);
  static const Color fieldBackground = Color(0xff0A0A0A);

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(); 
  final TextEditingController _aboutController = TextEditingController();

  String? selectedGender;

  @override
  void initState() {
    super.initState();
 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<CustomAppBarProvider>();
      if (userProvider.hasUser) {
        final data = userProvider.data;
        _fullNameController.text = data?.name ?? '';
        _userNameController.text = data?.username ?? '';
        _phoneController.text = data?.phoneNumber ?? ''; 
        _addressController.text = data?.address ?? '';
        _dobController.text = data?.dateOfBirth ?? '';
        _aboutController.text = data?.about ?? ''; 
       
        
        setState(() {
        
          if (['Male', 'Female', 'Other'].contains(data?.gender)) {
            selectedGender = data?.gender;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final provider = context.read<EditProfileProvider>();

    if (_fullNameController.text.isEmpty || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Name and Gender")),
      );
      return;
    }

    bool success = await provider.editProfile(
      name: _fullNameController.text,
      about: _aboutController.text,
      address: _addressController.text,
    
      phone_number: _phoneController.text,
      gender: selectedGender!,
      date_of_birth: _dobController.text,
    );

    if (success) {

      context.read<CustomAppBarProvider>().fetchAppBar(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.successMessage ?? "Profile Updated")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errormessage ?? "Error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomAppBar(title: 'Edit Profile'),
                SizedBox(height: 24.h),

                _buildLabel('Full Name'),
                SizedBox(height: 8.h),
                _buildTextField(_fullNameController, 'Enter name', TextInputType.name),
                SizedBox(height: 16.h),
                _buildLabel('User Name'),
                SizedBox(height: 8.h),
                _buildTextField(_userNameController, 'Enter your user name', TextInputType.name),
                SizedBox(height: 16.h),

                _buildLabel('Gender'),
                SizedBox(height: 8.h),
                _buildGenderDropdown(),
                SizedBox(height: 16.h),

                _buildLabel('Phone'),
                SizedBox(height: 8.h),
                _buildTextField(_phoneController, '+32123...', TextInputType.phone),
                SizedBox(height: 16.h),

                _buildLabel('Address'),
                SizedBox(height: 8.h),
                _buildTextField(_addressController, 'Enter address', TextInputType.streetAddress),
                SizedBox(height: 16.h),

                // _buildLabel('City'),
                // SizedBox(height: 8.h),
                // _buildTextField(_cityController, 'Enter city', TextInputType.text),
                // SizedBox(height: 16.h),

                _buildLabel('Date of Birth'),
                SizedBox(height: 8.h),
                _buildDateField(),
                SizedBox(height: 16.h),

                _buildLabel('About'),
                SizedBox(height: 8.h),
                _buildTextArea(),
                
                SizedBox(height: 32.h),

                Consumer<EditProfileProvider>(
                  builder: (context, provider, child) {
                    return PrimaryButton(
                      title: provider.isloading ? 'Saving...' : 'Save Changes',
                      onTap: provider.isloading ? null : _handleSave,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
  Widget _buildLabel(String text) => Text(text, style: TextStyle(color: Colors.white, fontSize: 14.sp));

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type) {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.grey.shade900)),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.grey.shade900)),
      child: TextField(
        controller: _dobController,
        readOnly: true,
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
        onTap: () async {
          DateTime? date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
          if (date != null) {
            setState(() { _dobController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"; });
          }
        },
        decoration: InputDecoration(
          hintText: 'YYYY-MM-DD',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600, size: 20.w),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.grey.shade900)),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          hint: Text('Select', style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          dropdownColor: fieldBackground,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          items: ['Male', 'Female', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (val) => setState(() => selectedGender = val),
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.grey.shade900)),
      child: TextField(
        controller: _aboutController,
        maxLines: 4,
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: 'About you...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        ),
      ),
    );
  }
}