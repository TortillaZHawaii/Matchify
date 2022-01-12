import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/features/points_of_interest/poi_entry.dart';

import 'auth_cubit.dart';
import 'unauthorized_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return state is SignedInState
            ? const PoiEntry()
            : const UnauthorizedPage();
      },
    );
  }
}
