import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doantotnghiep/login/login_state.dart';

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
