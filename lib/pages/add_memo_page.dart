import 'package:flutter/material.dart';
import '../database/memo_database.dart';
import '../models/memo.dart';

class AddMemoPage extends StatefulWidget {
  final Memo? memo;

  const AddMemoPage({super.key, this.memo});

  @override
  State<AddMemoPage> createState() => _AddMemoPageState();
}

class _AddMemoPageState extends State<AddMemoPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.memo != null) {
      titleController.text = widget.memo!.title;
      contentController.text = widget.memo!.content;
    }
  }

  Future<void> saveMemo() async {
    // Validasi Judul Kosong
    if (titleController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Judul tidak boleh kosong!')),
       );
       return; 
    }

    try {
      if (widget.memo != null) {
        // Update Memo
        await MemoDatabase.instance.updateMemo(
          widget.memo!.copy(
            title: titleController.text,
            content: contentController.text,
          ),
        );
      } else {
        // Buat Memo Baru
        await MemoDatabase.instance.insertMemo(
          Memo(
            title: titleController.text,
            content: contentController.text,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Kembali dengan sinyal sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: saveMemo,
            child: const Text(
              "Simpan", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Judul...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: contentController,
                style: const TextStyle(fontSize: 16, height: 1.5),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Mulai mengetik...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}