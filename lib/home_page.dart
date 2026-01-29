import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper _dbHelper = DBHelper();
  double _globalBalance = 0.0;
  List<Map<String, dynamic>> _activeTargets = [];
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final balance = await _dbHelper.getGlobalBalance();
    final targets = await _dbHelper.getActiveTargets();
    setState(() {
      _globalBalance = balance;
      _activeTargets = targets;
    });
  }

  Color _getStatusColor(double percent) {
    if (percent >= 1.0) return Colors.green;
    if (percent >= 0.5) return Colors.orange;
    return Colors.red;
  }

  void _showMainMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Menu NaSaving", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text("Tambah Pemasukan (Tabung)"),
                onTap: () {
                  Navigator.pop(context);
                  _showAddIncomeDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_task, color: Colors.blue),
                title: const Text("Buat Target Baru"),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTargetDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.purple),
                title: const Text("Riwayat Transaksi"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryTransactionPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.orange),
                title: const Text("Riwayat Pencapaian"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryAchievementPage()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddIncomeDialog() {
    final amountCtrl = TextEditingController();
    final sourceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Masukan Uang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sourceCtrl, decoration: const InputDecoration(labelText: "Sumber (Gaji/THR/dll)")),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Jumlah (Rp)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(amountCtrl.text.isNotEmpty && sourceCtrl.text.isNotEmpty) {
                await _dbHelper.addIncome(double.parse(amountCtrl.text), sourceCtrl.text);
                _refreshData();
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  void _showAddTargetDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Target Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Nama Barang/Tujuan")),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Harga Target (Rp)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                await _dbHelper.createTarget(titleCtrl.text, double.parse(amountCtrl.text));
                _refreshData();
                Navigator.pop(context);
              }
            },
            child: const Text("Buat Target"),
          )
        ],
      ),
    );
  }

  void _confirmComplete(int id, String title, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Beli Barang Ini?"),
        content: Text("Saldo global anda akan dikurangi Rp ${currencyFormatter.format(amount)} untuk menyelesaikan target '$title'."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              await _dbHelper.completeTarget(id, title, amount);
              _refreshData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selamat! Target Tercapai.")));
            },
            child: const Text("Ya, Selesaikan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NaSaving"), elevation: 1), // GANTI NAMA DISINI
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: _showMainMenu,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.menu_open, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Tabungan Anda", style: TextStyle(color: Colors.grey)),
                Text(
                  currencyFormatter.format(_globalBalance),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _activeTargets.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      "Anda belum membuat target",
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _activeTargets.length,
              itemBuilder: (context, index) {
                final item = _activeTargets[index];
                double targetPrice = item['target_amount'];
                
                double percent = _globalBalance / targetPrice;
                bool isAffordable = _globalBalance >= targetPrice;
                double displayPercent = percent > 1.0 ? 1.0 : percent;

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(displayPercent).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(
                                isAffordable ? "Bisa Dibeli!" : "Kurang ${(100 - (displayPercent*100)).toInt()}%",
                                style: TextStyle(color: _getStatusColor(displayPercent), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Harga: ${currencyFormatter.format(targetPrice)}"),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: displayPercent,
                          color: _getStatusColor(displayPercent),
                          backgroundColor: Colors.grey[200],
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 15),
                        
                        if (isAffordable)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text("Selesaikan / Beli"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () => _confirmComplete(item['id'], item['title'], targetPrice),
                            ),
                          )
                        else
                          Text(
                            "Kurang: ${currencyFormatter.format(targetPrice - _globalBalance)}",
                            style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTransactionPage extends StatelessWidget {
  const HistoryTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper().getTransactionHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          if (data.isEmpty) return const Center(child: Text("Belum ada transaksi"));

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final item = data[index];
              bool isIncome = item['type'] == 'IN';
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                  child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, 
                    color: isIncome ? Colors.green : Colors.red
                  ),
                ),
                title: Text(item['description']),
                subtitle: Text(item['created_at'].toString().substring(0, 16)),
                trailing: Text(
                  "${isIncome ? '+' : '-'} ${currencyFormatter.format(item['amount'])}",
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryAchievementPage extends StatelessWidget {
  const HistoryAchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Target Tercapai")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper().getCompletedTargets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          if (data.isEmpty) return const Center(child: Text("Belum ada target tercapai"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                color: Colors.green[50], // Nuansa hijau karena sukses
                child: ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.orange, size: 40),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Tercapai senilai: ${currencyFormatter.format(item['target_amount'])}"),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}