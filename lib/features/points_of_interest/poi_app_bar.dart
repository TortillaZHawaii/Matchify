import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/features/auth/auth_cubit.dart';

class PoiAppBar extends AppBar {
  PoiAppBar({Key? key})
      : super(
          key: key,
          title: const Text('Matchify'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.account_circle),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    title: const Text('Logout'),
                    leading: const Icon(Icons.logout),
                    onTap: () {
                      BlocProvider.of<AuthCubit>(context).signOut();
                    },
                  ),
                  value: 'Logout',
                ),
              ],
            ),
          ],
        );
}
