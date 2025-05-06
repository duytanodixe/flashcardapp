import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_cubit.dart' as signup;
import 'signup_state.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy & Terms of Use'),
        content: SingleChildScrollView(
          child: Text('Nội dung điều khoản sử dụng và chính sách bảo mật...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký tài khoản')),
      body: BlocProvider(
        create: (_) => signup.SignupCubit(),
        child: BlocListener<signup.SignupCubit, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đăng ký thành công!')),
              );
            } else if (state is SignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mật khẩu'),
                  obscureText: true,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Xác nhận mật khẩu'),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (val) {
                        setState(() => _acceptedTerms = val ?? false);
                      },
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: _showTermsDialog,
                        child: Text.rich(
                          TextSpan(
                            text: 'Tôi đồng ý với ',
                            children: [
                              TextSpan(
                                text: 'Privacy & Terms of Use',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                BlocBuilder<signup.SignupCubit, SignupState>(
                  builder: (context, state) {
                    if (state is SignupLoading) return Center(child: CircularProgressIndicator());
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_passwordController.text != _confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Mật khẩu và xác nhận mật khẩu không khớp!')),
                            );
                            return;
                          }
                          context.read<signup.SignupCubit>().signup(
                            _emailController.text,
                            _passwordController.text,
                            _acceptedTerms,
                          );
                        },
                        child: Text('Đăng ký'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
