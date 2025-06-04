import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/login/login_state.dart';
import 'signup_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    await Future.delayed(Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      emit(LoginSuccess());
    } else {
      emit(LoginFailure('Email hoặc mật khẩu không được để trống'));
    }
  }
}

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final _db = FirebaseFirestore.instance;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signup(String email, String password, bool acceptedTerms) async {
    emit(SignupLoading());
    await Future.delayed(Duration(milliseconds: 500));
    if (!_isValidEmail(email)) {
      emit(SignupFailure('Email không hợp lệ.'));
      return;
    }
    if (!_isValidPassword(password)) {
      emit(SignupFailure('Mật khẩu phải tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.'));
      return;
    }
    if (!acceptedTerms) {
      emit(SignupFailure('Bạn phải đồng ý với điều khoản sử dụng.'));
      return;
    }
    // Kiểm tra trùng email
    final snap = await _db.collection('users').where('email', isEqualTo: email).get();
    if (snap.docs.isNotEmpty) {
      emit(SignupFailure('Email đã tồn tại.'));
      return;
    }
    await _db.collection('users').add({
      'email': email,
      'password': password,
    });
    emit(SignupSuccess());
  }
}
