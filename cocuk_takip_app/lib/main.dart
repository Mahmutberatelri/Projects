import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:usage_stats/usage_stats.dart';
import 'database_helper.dart';


void main() {
  runApp(const BenimUygulamam());
}

class BenimUygulamam extends StatelessWidget {
  const BenimUygulamam({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final Random _rnd = Random();
  List<int> veriler = List.filled(24, 0);
  List<int> kategoriler = List.filled(24, 0);

  String sonucBaslik = "Analiz Bekleniyor...";
  String sonucDetay = "Verileri oluşturup yapay zekaya gönderin.";
  Color sonucRenk = Colors.grey;
  IconData sonucIkon = Icons.analytics_outlined;
  bool yukleniyor = false;

  final List<String> oyunlar = ["com.tencent.ig", "com.supercell.brawlstars", "com.roblox.client", "com.mojang.minecraftpe", "com.king.candycrush"];
  final List<String> sosyal = ["com.instagram.android", "com.zhiliaoapp.musically", "com.twitter.android", "com.snapchat.android", "com.whatsapp", "com.google.android.youtube"];
  final List<String> egitim = ["tr.gov.eba.hesap", "com.duolingo", "com.udemy.android", "com.google.android.classroom", "com.quizlet.quizletandroid"];

  Future<void> izinIste() async {

bool isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;
    if (!isPermissionGranted) {
      await UsageStats.grantUsagePermission();
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Erişim İzni Zaten Verilmiş!"), backgroundColor: Colors.green));
      }
    }
  }

  int kategoriBul(String paketIsmi) {
    paketIsmi = paketIsmi.toLowerCase();
    if (paketIsmi.contains("eba") || paketIsmi.contains("duolingo") || paketIsmi.contains("udemy") || paketIsmi.contains("quizlet") || paketIsmi.contains("classroom")) return 1;
    if (paketIsmi.contains("instagram") || paketIsmi.contains("musically") || paketIsmi.contains("twitter") || paketIsmi.contains("snapchat") || paketIsmi.contains("whatsapp") || paketIsmi.contains("youtube")) return 2;
    if (paketIsmi.contains("pubg") || paketIsmi.contains("tencent") || paketIsmi.contains("roblox") || paketIsmi.contains("supercell") || paketIsmi.contains("mojang") || paketIsmi.contains("candy")) return 0;
    return 3;
  }

void senaryoYukle(String tip) {
    setState(() {
      sonucBaslik = "Analiz Bekleniyor...";
      sonucRenk = Colors.grey;
      sonucDetay = "Veriler güncellendi. Analiz bekleniyor.";
      sonucIkon = Icons.analytics_outlined;
      veriler = List.filled(24, 0);
      kategoriler = List.filled(24, 0);


      bool gececiTipiSosyal = _rnd.nextBool(); 
   
      bool bugunCokCaliskan = _rnd.nextBool(); 

      for (int saat = 0; saat < 24; saat++) {
        String secilenPaket = "";
        int sure = 0;
        int zar = _rnd.nextInt(100);


        if (tip == "bagimli") {
          if (saat >= 5 && saat <= 9) {
             if (_rnd.nextInt(100) < 20) sure = 10 + _rnd.nextInt(20); else sure = 0;
          } else {
            sure = 30 + _rnd.nextInt(90); 
            if (zar < 75) secilenPaket = oyunlar[_rnd.nextInt(oyunlar.length)];
            else if (zar < 95) secilenPaket = sosyal[_rnd.nextInt(sosyal.length)];
            else secilenPaket = egitim[_rnd.nextInt(egitim.length)];
          }
        } 
        
   
        else if (tip == "sinsi_gececi") {
          if (saat >= 0 && saat <= 5) { 
            sure = 50 + _rnd.nextInt(70); 
            if (gececiTipiSosyal) {
              if (zar < 80) secilenPaket = sosyal[_rnd.nextInt(sosyal.length)];
              else secilenPaket = oyunlar[_rnd.nextInt(oyunlar.length)];
            } else {
              if (zar < 80) secilenPaket = oyunlar[_rnd.nextInt(oyunlar.length)];
              else secilenPaket = sosyal[_rnd.nextInt(sosyal.length)];
            }
          } else if (saat >= 6 && saat <= 14) { 
            sure = 0; 
          } else { 
            sure = 15 + _rnd.nextInt(45); 
            if (gececiTipiSosyal) secilenPaket = sosyal[_rnd.nextInt(sosyal.length)];
            else secilenPaket = oyunlar[_rnd.nextInt(oyunlar.length)];
          }
        } 
        

        else if (tip == "sosyal_kelebek") {
          if (saat >= 2 && saat <= 8) sure = 0; 
          else {
            sure = 20 + _rnd.nextInt(50); 
            if (zar < 80) secilenPaket = sosyal[_rnd.nextInt(sosyal.length)];
            else secilenPaket = oyunlar[_rnd.nextInt(oyunlar.length)];
          }
        } 
        

        else if (tip == "karisik_dengeli") {
          
          if (saat >= 23 || saat <= 15) {
             sure = 0;
          } 
       
          else if (saat >= 16 && saat <= 18) {
            sure = 20 + _rnd.nextInt(30); 
            if (zar < 50) secilenPaket = oyunlar[_rnd.nextInt(oyunlar.length)];
            else secilenPaket = sosyal[_rnd.nextInt(sosyal.length)];
          }
        
          else {
            if (bugunCokCaliskan) {
           
              sure = 50 + _rnd.nextInt(60);
            } else {
              
              sure = 25 + _rnd.nextInt(30);
            }
            secilenPaket = egitim[_rnd.nextInt(egitim.length)]; 
          }
        }

        if (sure > 0) {
          veriler[saat] = sure > 120 ? 120 : sure;
          kategoriler[saat] = kategoriBul(secilenPaket);
        }
      }
    });
  }
  Future<void> analizEt() async {
    setState(() => yukleniyor = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/analiz-et"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"veriler": veriler, "kategoriler": kategoriler}),
      );

      final data = jsonDecode(response.body);
      setState(() {
        String durum = data['durum'];
        String hamMesaj = data['mesaj'];
        List<String> satirlar = hamMesaj.split('\n');
        sonucBaslik = satirlar.isNotEmpty ? satirlar[0] : durum.toUpperCase();
        sonucDetay = hamMesaj.replaceFirst(sonucBaslik, "").trim();

        if (durum == 'bagimli') { sonucRenk = const Color(0xFFFF5252); sonucIkon = Icons.warning_amber_rounded; }
        else if (durum == 'ideal') { sonucRenk = const Color(0xFF00C853); sonucIkon = Icons.check_circle_outline; }
        else if (durum == 'sosyal_medya') { sonucRenk = const Color(0xFF448AFF); sonucIkon = Icons.notifications_paused_outlined; }
        else { sonucRenk = const Color(0xFFFFAB40); sonucIkon = Icons.dark_mode_outlined; }
      });

      await DatabaseHelper.instance.kaydet(sonucBaslik, sonucDetay);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Analiz sonucu kaydedildi!"), backgroundColor: Colors.green));
      }

    } catch (e) {
      setState(() {
        sonucBaslik = "Bağlantı Hatası";
        sonucDetay = "Python API'ye ulaşılamadı. Sunucuyu kontrol et.";
        sonucRenk = Colors.grey;
        sonucIkon = Icons.error_outline;
      });
    } finally {
      setState(() => yukleniyor = false);
    }
  }

  void _gecmisiGoster() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GecmisSayfasi()));
  }

  List<PieChartSectionData> pastaDilimleriniOlustur() {
    double oyunToplam = 0;
    double sosyalToplam = 0;
    double egitimToplam = 0;

    for(int i=0; i<24; i++) {
      if(kategoriler[i] == 0) oyunToplam += veriler[i];
      if(kategoriler[i] == 1) egitimToplam += veriler[i];
      if(kategoriler[i] == 2) sosyalToplam += veriler[i];
    }
    double genelToplam = oyunToplam + sosyalToplam + egitimToplam;
    if (genelToplam == 0) return [];

    return [
      if(oyunToplam > 0) PieChartSectionData(color: const Color(0xFFFF5252), value: oyunToplam, title: '%${(oyunToplam/genelToplam*100).toStringAsFixed(0)}', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      if(sosyalToplam > 0) PieChartSectionData(color: const Color(0xFF448AFF), value: sosyalToplam, title: '%${(sosyalToplam/genelToplam*100).toStringAsFixed(0)}', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      if(egitimToplam > 0) PieChartSectionData(color: const Color(0xFF00C853), value: egitimToplam, title: '%${(egitimToplam/genelToplam*100).toStringAsFixed(0)}', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ];
  }

  Widget _buildSenaryoButonu(String title, Color color, String tip, IconData icon) {
    return Expanded(child: InkWell(onTap: () => senaryoYukle(tip), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))), child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 5), Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)]))));
  }
  Widget _buildLegend(Color color, String text) { return Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5), Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Dijital Pedagog", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          IconButton(icon: const Icon(Icons.lock_open_rounded, color: Colors.redAccent, size: 28), onPressed: izinIste, tooltip: "Gerçek Veri İzni İste"),
          IconButton(icon: const Icon(Icons.history, color: Colors.indigo, size: 30), onPressed: _gecmisiGoster),
        ],
        backgroundColor: Colors.transparent, elevation: 0, flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)]))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(elevation: 5, shadowColor: Colors.black12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), color: Colors.white, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Text("Saatlik Aktivite (Çubuk)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)), const SizedBox(height: 20), SizedBox(height: 180, child: BarChart(BarChartData(maxY: 120, titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false), gridData: const FlGridData(show: false), barGroups: veriler.asMap().entries.map((e) { Color r = Colors.grey.shade200; if (kategoriler[e.key] == 0) r = const Color(0xFFFF5252); if (kategoriler[e.key] == 1) r = const Color(0xFF00C853); if (kategoriler[e.key] == 2) r = const Color(0xFF448AFF); return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), color: r, width: 8, borderRadius: BorderRadius.circular(4))]); }).toList())))]))),
            const SizedBox(height: 20),
            Card(
              elevation: 5, shadowColor: Colors.black12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Toplam Dağılım (Pasta)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: veriler.every((element) => element == 0)
                      ? const Center(child: Text("Veri Yok", style: TextStyle(color: Colors.grey)))
                      : PieChart(
                        PieChartData(
                          sections: pastaDilimleriniOlustur(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildLegend(const Color(0xFFFF5252), "Oyun"), const SizedBox(width: 15), _buildLegend(const Color(0xFF00C853), "Eğitim"), const SizedBox(width: 15), _buildLegend(const Color(0xFF448AFF), "Sosyal")]),
            const SizedBox(height: 25),
            Row(children: [_buildSenaryoButonu("Dengeli", Colors.green, "karisik_dengeli", Icons.balance), _buildSenaryoButonu("Gececi", Colors.orange, "sinsi_gececi", Icons.nightlight_round), _buildSenaryoButonu("Sosyal", Colors.blue, "sosyal_kelebek", Icons.chat), _buildSenaryoButonu("Bağımlı", Colors.red, "bagimli", Icons.videogame_asset)]),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: yukleniyor ? null : analizEt, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: yukleniyor ? const CircularProgressIndicator(color: Colors.white) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: Colors.white), SizedBox(width: 10), Text("YAPAY ZEKAYA SOR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))])),
            const SizedBox(height: 25),
            if(sonucBaslik != "Analiz Bekleniyor...")
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: sonucRenk.withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: sonucRenk.withOpacity(0.1), blurRadius: 15)]), child: Column(children: [Icon(sonucIkon, size: 48, color: sonucRenk), const SizedBox(height: 10), Text(sonucBaslik, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sonucRenk)), const Divider(), Text(sonucDetay, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.5))])),
          ],
        ),
      ),
    );
  }
}

class GecmisSayfasi extends StatelessWidget {
  const GecmisSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geçmiş Analizler"), backgroundColor: const Color(0xFFE0EAFC)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getirTumRaporlar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final raporlar = snapshot.data!;
          if (raporlar.isEmpty) return const Center(child: Text("Henüz kaydedilmiş rapor yok."));
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: raporlar.length,
            itemBuilder: (context, index) {
              final rapor = raporlar[index];
              final tarih = DateTime.parse(rapor['tarih']);
              final formatliTarih = DateFormat('dd.MM.yyyy HH:mm').format(tarih);
              Color renk = Colors.grey;
              if (rapor['durum'].toString().contains("BAĞIMLI")) renk = Colors.red;
              else if (rapor['durum'].toString().contains("GECE")) renk = Colors.orange;
              else if (rapor['durum'].toString().contains("İDEAL")) renk = Colors.green;
              else if (rapor['durum'].toString().contains("SOSYAL")) renk = Colors.blue;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: renk.withOpacity(0.5))),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: renk.withOpacity(0.1), child: Icon(Icons.history, color: renk)),
                  title: Text(rapor['durum'], style: TextStyle(color: renk, fontWeight: FontWeight.bold)),
                  subtitle: Text("$formatliTarih\n${rapor['detay']}", maxLines: 2, overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
        onPressed: () async {
          await DatabaseHelper.instance.temizle();
          (context as Element).markNeedsBuild();
        },
      ),
    );
  }
}