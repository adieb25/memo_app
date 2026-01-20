import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; 
import '../database/memo_database.dart';
import '../models/memo.dart';
import 'add_memo_page.dart';
import 'detail_memo_page.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  List<Memo> memos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMemo();
  }

  Future<void> loadMemo() async {
    setState(() => isLoading = true);
    final data = await MemoDatabase.instance.getAllMemo();
    setState(() {
      memos = data;
      isLoading = false;
    });
  }

  // LOGIKA FITUR TAMBAHAN
  Future<void> togglePin(Memo memo) async {
    await MemoDatabase.instance.updateMemo(memo.copy(isPinned: !memo.isPinned));
    loadMemo();
  }

  Future<void> toggleLock(Memo memo) async {
    await MemoDatabase.instance.updateMemo(memo.copy(isLocked: !memo.isLocked));
    loadMemo();
  }

  Future<void> duplicateMemo(Memo memo) async {
    final newMemo = Memo(
        title: "${memo.title} (Copy)",
        content: memo.content,
        isPinned: false, 
        isLocked: false);
    await MemoDatabase.instance.insertMemo(newMemo);
    loadMemo();
  }

  Future<void> deleteMemo(int id) async {
    await MemoDatabase.instance.deleteMemo(id);
    loadMemo();
  }

  // TAMPILAN MENU BAWAH (MODAL SHEET)
  void showMemoOptions(Memo memo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               ListTile(
                 leading: const Icon(Icons.share), title: const Text('Share'), 
                 onTap: () { 
                   Navigator.pop(context); 
                   if(memo.isLocked) { 
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buka kunci dulu untuk share!"))); 
                   } else { 
                     Share.share('${memo.title}\n\n${memo.content}'); 
                   } 
                 }
               ),
               ListTile(
                 leading: Icon(memo.isPinned ? Icons.push_pin : Icons.push_pin_outlined), 
                 title: Text(memo.isPinned ? 'Lepas Pin' : 'Pasang Pin'), 
                 onTap: () { Navigator.pop(context); togglePin(memo); }
               ),
               ListTile(
                 leading: Icon(memo.isLocked ? Icons.lock_open : Icons.lock), 
                 title: Text(memo.isLocked ? 'Buka Kunci' : 'Kunci Catatan'), 
                 onTap: () { Navigator.pop(context); toggleLock(memo); }
               ),
               ListTile(
                 leading: const Icon(Icons.copy), title: const Text('Duplikat'), 
                 onTap: () { Navigator.pop(context); duplicateMemo(memo); }
               ),
               const Divider(),
               ListTile(
                 leading: const Icon(Icons.delete, color: Colors.red), 
                 title: const Text('Hapus', style: TextStyle(color: Colors.red)), 
                 onTap: () { 
                   Navigator.pop(context); 
                   // Konfirmasi Hapus
                   showDialog(context: context, builder: (c) => AlertDialog(
                     title: const Text("Hapus Memo?"),
                     actions: [
                       TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Batal")),
                       TextButton(onPressed: (){Navigator.pop(c); deleteMemo(memo.id!);}, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                     ],
                   ));
                 }
               ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Catatan Saya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
             final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMemoPage()));
             if (result == true) loadMemo();
        },
        label: const Text("Tulis Baru"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : memos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("Belum ada catatan", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    final memo = memos[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: memo.isLocked ? Colors.grey[300] : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onLongPress: () => showMemoOptions(memo), // INI TRIGGER MENU
                        onTap: () async {
                          if (memo.isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("🔒 Memo terkunci! Tekan lama untuk opsi.")),
                            );
                            return;
                          }
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailMemoPage(memo: memo)),
                          );
                          if (result == true) loadMemo();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      memo.isLocked ? "🔒 Rahasia" : memo.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: memo.isLocked ? Colors.grey[700] : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (memo.isPinned)
                                    const Icon(Icons.push_pin, color: Colors.orange, size: 20),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                memo.isLocked ? "Konten ini disembunyikan." : memo.content,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}