import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/state/sync_center_cubit.dart';
import 'package:manajemen_tahsin_app/core/utils/sync_manager.dart';

void showSyncPopupDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return BlocBuilder<SyncCenterCubit, SyncCenterState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.totalAntrean == 0) ...[
                  const Icon(Icons.check_circle_outline, size: 50, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Semua data sudah tersinkronisasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Terdapat ${state.totalAntrean} data antrean luring yang menunggu dikirim.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.daftarAntrean.length,
                      itemBuilder: (context, index) {
                        final item = state.daftarAntrean[index];
                        String detail = item.endpoint;
                        try {
                          final map = json.decode(item.payloadJson);
                          if (map is Map) {
                            if (map.containsKey('nis')) detail = 'NIS: ${map['nis']}';
                            if (map.containsKey('rows')) detail = 'Massal: ${map['rows'].length} santri';
                          }
                        } catch (_) {}

                        return ListTile(
                          leading: const Icon(Icons.sync_problem, color: Colors.orange),
                          title: Text(
                            DateFormat('dd MMM HH:mm').format(item.timestamp),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(detail, style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF0F4C2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          },
                        );
                        try {
                          await OfflineSyncManager().syncQueueManual();
                        } finally {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text(
                        'Sinkronisasi Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}
