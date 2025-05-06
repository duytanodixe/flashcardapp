import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

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
    await Future.delayed(Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailure('Email hoặc mật khẩu không được để trống'));
      return;
    }
    if (!_isValidEmail(email)) {
      emit(LoginFailure('Email không đúng định dạng.'));
      return;
    }
    if (!_isValidPassword(password)) {
      emit(LoginFailure('Mật khẩu phải tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.'));
      return;
    }
    emit(LoginSuccess());
  }
}
