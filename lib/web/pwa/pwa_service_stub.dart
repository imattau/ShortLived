import 'package:flutter/material.dart';
import 'pwa_service_base.dart';

class PwaServiceStub implements PwaService {
  @override
  final installAvailable = ValueNotifier<bool>(false);

  @override
  Future<bool> promptInstall() async => false;
}

PwaService createPwaService() => PwaServiceStub();
