import 'package:flutter/material.dart';
import '../models/memo.dart';
import '../database/memo_database.dart';
import 'add_memo_page.dart';

class DetailMemoPage extends StatelessWidget {
  final Memo memo;

  const DetailMemoPage({super.key, required this.memo});

  Future<void> deleteMemo(BuildContext context) async {
    await MemoDatabase.instance.deleteMemo(memo.id!);
    if (context.mounted) {
       Navigator.pop(context, true);
    }
  }

  Future<void> editMemo(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemoPage(memo: memo),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => editMemo(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
               showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Hapus?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                    TextButton(onPressed: () {Navigator.pop(ctx); deleteMemo(context);}, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memo.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                memo.content,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}