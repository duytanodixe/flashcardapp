import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/login/login_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final _db = FirebaseFirestore.instance;

  Future<void> _ensureSampleAccount() async {
    final snap = await _db.collection('users').where('email', isEqualTo: 'a4@gmail.com').get();
    if (snap.docs.isEmpty) {
      await _db.collection('users').add({
        'email': 'a4@gmail.com',
        'password': 'a4@gmail.com',
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Tối thiểu 8 ký tự, ít nhất 1 chữ hoa, 1 chữ thường, 1 số, 1 ký tự đặc biệt
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    await _ensureSampleAccount();
    await Future.delayed(Duration(milliseconds: 500));
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailure('Email hoặc mật khẩu không được để trống'));
      return;
    }
    final snap = await _db.collection('users').where('email', isEqualTo: email).get();
    if (snap.docs.isEmpty) {
      emit(LoginFailure('Tài khoản không tồn tại.'));
      return;
    }
    final user = snap.docs.first.data();
    if (user['password'] != password) {
      emit(LoginFailure('Sai mật khẩu.'));
      return;
    }
    emit(LoginSuccess());
  }
}
