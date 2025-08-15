import 'package:flutter/material.dart';

abstract class PwaService {
  ValueNotifier<bool> get installAvailable;
  Future<bool> promptInstall();
}
