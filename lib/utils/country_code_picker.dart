import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_text.dart';

class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class CountryCodePicker extends StatelessWidget {
  final CountryCode selectedCountry;
  final Function(CountryCode) onCountrySelected;

  const CountryCodePicker({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  static final List<CountryCode> countries = [
    const CountryCode(
        name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    const CountryCode(
        name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    const CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    const CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    const CountryCode(
        name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    const CountryCode(
        name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    const CountryCode(
        name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    const CountryCode(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    const CountryCode(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    const CountryCode(
        name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
    const CountryCode(name: 'Russia', code: 'RU', dialCode: '+7', flag: '🇷🇺'),
    const CountryCode(
        name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
    const CountryCode(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
    const CountryCode(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
    const CountryCode(
        name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
    const CountryCode(
        name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
    const CountryCode(
        name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
    const CountryCode(
        name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
    const CountryCode(
        name: 'United Arab Emirates',
        code: 'AE',
        dialCode: '+971',
        flag: '🇦🇪'),
    const CountryCode(
        name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦'),
  ];

  @override
  Widget build(BuildContext context) {
    // TextFormField with contentPadding 12.h vertical has approximate height of 48-52.h
    // This includes: 12.h (top) + ~20.h (text line) + 12.h (bottom) + border
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        height: 43.h,
        // Fixed height to match TextFormField
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.lightGrey, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              text: selectedCountry.flag,
              fontSize: 20.sp,
            ),
            SizedBox(width: 8.w),
            AppText(
              text: selectedCountry.dialCode,
              fontSize: 14.sp,
              color: AppColor.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              color: AppColor.greyColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColor.lightGrey, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Select Country',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColor.greyColor),
                  ),
                ],
              ),
            ),
            // Country List
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final isSelected = country.code == selectedCountry.code;
                  return ListTile(
                    leading: AppText(
                      text: country.flag,
                      fontSize: 24.sp,
                    ),
                    title: AppText(
                      text: country.name,
                      fontSize: 16.sp,
                      color: AppColor.darkGrey,
                    ),
                    trailing: AppText(
                      text: country.dialCode,
                      fontSize: 14.sp,
                      color: AppColor.greyColor,
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColor.lightGreen.withOpacity(0.3),
                    onTap: () {
                      onCountrySelected(country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
