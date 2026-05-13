import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';

class ActiveKelompokDropdown extends StatelessWidget {
  final VoidCallback? onChanged;

  const ActiveKelompokDropdown({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveKelompokCubit, ActiveKelompokState>(
      builder: (context, state) {
        // Jangan tampilkan dropdown jika tidak ada opsi atau hanya 1 opsi
        if (state.allowedKelompok.isEmpty || state.allowedKelompok.length <= 1) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: state.activeId > 0 ? state.activeId : null,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Theme.of(context).primaryColor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              items: state.allowedKelompok.map((k) {
                final int id = k['id_kelompok'] != null 
                    ? int.tryParse(k['id_kelompok'].toString()) ?? 0 
                    : (int.tryParse(k['id']?.toString() ?? '0') ?? 0);
                final String nama = k['nama_kelompok'] ?? k['kelompok'] ?? 'Cabang $id';

                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(nama),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null && newValue != state.activeId) {
                  context.read<ActiveKelompokCubit>().changeKelompok(newValue);
                  if (onChanged != null) {
                     onChanged!(); // Trigger refetch on the parent screen
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
