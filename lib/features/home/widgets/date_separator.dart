import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: Spacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColor.lightGrey)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(
                text: _formatDate(date),
                fontSize: 12.sp,
                color: AppColor.greyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColor.lightGrey)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return AppString.today;
    } else if (messageDate == yesterday) {
      return AppString.yesterday;
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

