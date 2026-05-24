import 'package:flutter/material.dart';

enum JalurEnum {
  tahsin(kode: 'tahsin', nama: 'Tahsin', warna: Colors.blue),
  praTahfidz(kode: 'pratahfidz', nama: 'Pra-Tahfidz', warna: Colors.orange),
  tahfidz(kode: 'tahfidz', nama: 'Tahfidz', warna: Colors.green);

  final String kode;
  final String nama;
  final Color warna;

  const JalurEnum({
    required this.kode,
    required this.nama,
    required this.warna,
  });

  static JalurEnum fromKode(String kode) {
    switch (kode.toLowerCase()) {
      case 'tahsin':
        return JalurEnum.tahsin;
      case 'pratahfidz':
        return JalurEnum.praTahfidz;
      case 'tahfidz':
        return JalurEnum.tahfidz;
      default:
        return JalurEnum.tahsin;
    }
  }
}
