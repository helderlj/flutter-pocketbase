import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';

import '../models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

class Auth extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  late PocketBase pb;
  late User _user;
  bool _isAuthenticated = false;
  User get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Auth() {
    init();
  }

  Future<void> init() async {
    final store = AsyncAuthStore(
      save: (String data) async =>
          await storage.write(key: 'pb_auth', value: data),
      initial: await storage.read(key: 'pb_auth'),
    );

    pb = PocketBase('http://127.0.0.1:8090', authStore: store);
    _isAuthenticated = pb.authStore.isValid;
    log('auth.dart - init() - Autenticado: $_isAuthenticated');
  }

  Future<void> login({Map? credentials}) async {
    String email = credentials?['email'];
    String password = credentials?['password'];
    try {
      final userData =
          await pb.collection('users').authWithPassword(email, password);
      _user = User.fromJson(json.decode(userData.record.toString()));
      _isAuthenticated = true;
      print('auth.dart - login() - Token: ${pb.authStore}');
      // storeAuthStore(pb.authStore.toString());
    } on ClientException catch (e) {
      //print(e.response['message']);
      //print(e.statusCode);
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    pb.authStore.clear();
    storage.delete(key: 'pb_auth');
    _isAuthenticated = false;
    log('auth.dart - logout() - Deslogando');
    notifyListeners();
  }

  // Future<String?> getAuthStore() {
  //   log('token recuperado');
  //   return storage.read(key: 'pb_auth');
  // }

  // void storeAuthStore(String authStore) {
  //   log('token armazenado');
  //   storage.write(key: 'pb_auth', value: authStore);
  // }

  attempt() async {
    // try {
    //   pb.authStore.isValid;
    //   log('Tentado validar token salvo: ${pb.authStore.isValid}');
    //   await pb.collection("users").authRefresh();
    //   _isAuthenticated = true;
    // } catch (e) {
    //   // clear the store on invalid or expired data
    //   pb.authStore.clear();
    // }

    log(pb.authStore.isValid.toString());
    if (!pb.authStore.isValid) {
      print(pb.authStore);

      _isAuthenticated = false;
      log('token salvo invalido');
      return;
    }
    notifyListeners();
    log('token salvo valido');
    _isAuthenticated = true;
  }
}
