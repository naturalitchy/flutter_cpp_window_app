import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';



class FFIBridge {
  static bool initialize() {
    nativeApiLib = Platform.isMacOS || Platform.isIOS ? DynamicLibrary.process() // macos and ios
        : (DynamicLibrary.open(Platform.isWindows // windows
        ? 'api.dll'
        : 'libapi.so')); // android and linux

    final _add = nativeApiLib
        .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add');
    add = _add.asFunction<int Function(int, int)>();

    final _cap = nativeApiLib.lookup<
        NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('capitalize');
    _capitalize = _cap.asFunction<Pointer<Utf8> Function(Pointer<Utf8>)>();

    return true;
  }

  static late DynamicLibrary nativeApiLib;
  static late Function add;
  static late Function _capitalize;

  static String capitalize(String str) {
    final _str = str.toNativeUtf8();
    Pointer<Utf8> res = _capitalize(_str);
    calloc.free(_str);
    return res.toDartString();
  }

}


void main() {
  FFIBridge.initialize();
  runApp(
    MaterialApp(
      home: MainScreen(),
    )
  );
}


class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int num = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('1+2=${FFIBridge.add(1, 2)}'),
      ),
    );
  }
}

