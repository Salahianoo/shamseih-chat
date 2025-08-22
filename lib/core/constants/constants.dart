import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.sp,
);

final kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

final kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.w),
  ),
);

final kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your email',
  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.r)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.w),
    borderRadius: BorderRadius.all(Radius.circular(32.r)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.w),
    borderRadius: BorderRadius.all(Radius.circular(32.r)),
  ),
);
