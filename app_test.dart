import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_session/controllers/session_controller.dart';
import 'package:story_session/main.dart' as app;
import 'package:story_session/models/booking_model.dart';
import 'package:story_session/models/filter_data.dart';
import 'package:story_session/routes/routes.dart';
import 'package:story_session/screens/editing_session/review/review_screen.dart';
import 'package:story_session/screens/order_session/make_order/voucher_screen.dart';
import 'package:story_session/screens/order_session/thank_you_screen.dart';
import 'package:story_session/widgets/pannable_photo_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  group("Flow Admin Test", () {
    testWidgets('Verifikasi menu Admin berhasil dibuka',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      final adminButton = find.byKey(const Key("btn_hidden_admin"));
      final pinTextfield = find.byKey(const Key("input_admin_pin"));
      final adminMasukButton = find.byKey(const Key("btn_admin_masuk"));
      expect(adminButton, findsOneWidget,
          reason:
              'Tombol Admin tidak ditemukan, mungkin masih di Splash Screen');

      await tester.tap(adminButton);
      await tester.pumpAndSettle();

      // 4. Masukkan PIN
      await tester.enterText(pinTextfield, "1234");
      await tester.tap(adminMasukButton);
      await tester.pumpAndSettle();

      expect(find.text('Admin Menu'), findsOneWidget);
    });

    testWidgets("Verifikasi menu admin gagal dibuka",
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      final adminButton = find.byKey(const Key("btn_hidden_admin"));
      final pinTextfield = find.byKey(const Key("input_admin_pin"));
      final adminMasukButton = find.byKey(const Key("btn_admin_masuk"));
      expect(adminButton, findsOneWidget,
          reason:
              'Tombol Admin tidak ditemukan, mungkin masih di Splash Screen');

      await tester.tap(adminButton);
      await tester.pumpAndSettle();

      await tester.enterText(pinTextfield, "0000");
      await tester.tap(adminMasukButton);
      await tester.pumpAndSettle();

      expect(find.text('PIN Salah'), findsOneWidget);
    });
  });

  group("Flow datang langsung", () {
    testWidgets('Verifikasi alur Datang Langsung', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      final datangLangsungButton = find.byKey(const Key('btn_datang_langsung'));
      expect(datangLangsungButton, findsOneWidget);

      await tester.tap(datangLangsungButton);
      await tester.pumpAndSettle();

      expect(find.text('Pilih Paket'), findsWidgets);

      final selectedServiceId =
          find.byKey(const Key("item_897b6293-b710-4ddf-9a59-91c64648417e"));
      await tester.tap(selectedServiceId);
      await tester.pumpAndSettle();

      final selanjutnyaBtn = find.byKey(const Key("btn_order_next"));
      await tester.tap(selanjutnyaBtn);
      await tester.pumpAndSettle();

      expect(find.byType(VoucherScreen), findsOneWidget,
          reason: "Gagal pindah ke VoucherScreen");
      expect(find.text("Kode Voucher"), findsOneWidget);
      final skipButtonVoucher = find.byKey(const Key("btn_skip_voucher"));
      await tester.tap(skipButtonVoucher);
      await tester.pumpAndSettle();

      expect(find.text("Cek Pembayaran"), findsWidgets);
      await tester.pump(const Duration(seconds: 4));
      final checkPayment = find.byKey(const Key("btn_check_payment"));

      const int maxAttempts = 5;
      int attempts = 0;
      bool isPaymentConfirmed = false;

      while (!isPaymentConfirmed && attempts < maxAttempts) {
        await tester.tap(checkPayment);
        await tester.pumpAndSettle();

        final cameraScreen = find.byKey(const Key("camera_screen"));

        if (cameraScreen.evaluate().isNotEmpty) {
          isPaymentConfirmed = true;
          break;
        } else {
          await Future.delayed(const Duration(seconds: 4));
          attempts++;
        }
      }

      expect(isPaymentConfirmed, isTrue,
          reason: "Payment Confirmation takes a long time");
    });
  });

  group('Flow Sudah Booking', () {
    testWidgets('Kode booking salah memunculkan error',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // 1. Masuk ke halaman form
      await tester.tap(find.byKey(const Key("btn_sudah_booking")));
      await tester.pumpAndSettle();

      final inputBookedId = find.byKey(const Key("input_booked_id"));
      await tester.enterText(inputBookedId, "9999");

      final btnSubmit = find.byKey(const Key("btn_submit_booking"));
      await tester.tap(btnSubmit);
      await tester.pumpAndSettle();

      expect(
          find.text(
              "Booking ID tidak valid atau tidak ditemukan untuk tanggal tersebut."),
          findsOneWidget,
          reason: "Snackbar error tidak muncul!");
    });

    testWidgets('Kode booking benar masuk ke halaman kamera',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key("btn_sudah_booking")));
      await tester.pumpAndSettle();

      final inputBookedId = find.byKey(const Key("input_booked_id"));
      await tester.enterText(inputBookedId, "IV55");

      final btnSubmit = find.byKey(const Key("btn_submit_booking"));
      await tester.tap(btnSubmit);

      await tester.pumpAndSettle();

      final cameraScreen = find.byKey(const Key("layar_kamera"));
      expect(cameraScreen, findsOneWidget,
          reason: "Gagal pindah ke halaman kamera!");
    });
  });
  group('Flow Ambil Foto (Bypass)', () {
    testWidgets('Test tombol jepret di halaman kamera', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      const int targetPhotos = 3;

      final sessionController = Get.isRegistered<SessionController>()
          ? Get.find<SessionController>()
          : Get.put(SessionController());

      sessionController.isTestMode.value = true;

      sessionController.setPackageSettings(
        maxPhotos: targetPhotos,
        durationSeconds: 1200,
      );

      final mockBookingData = Booking(
        id: 'dummy-uuid-1234-5678',
        bookingId: 'TEST99',
        serviceName: 'Memori Lane',
        isAiGenerate: false,
        transactionNumber: '',
        name: '',
        phoneNumber: '',
        email: '',
        photoDate: '',
        status: 1,
        paymentStatus: 1,
        galleries: [],
      );

      Get.toNamed(AppRoutes.camera, arguments: mockBookingData);
      await tester.pumpAndSettle();

      final cameraScreen = find.byKey(const Key("camera_screen"));
      expect(cameraScreen, findsOneWidget,
          reason: "Gagal memuat halaman kamera langsung");

      final btnJepret = find.byKey(const Key("btn_capture_foto"));

      for (var i = 0; i < targetPhotos; i++) {
        debugPrint('📸 --- Memulai jepretan ke-${i + 1} ---');
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(btnJepret);
        debugPrint('✅ Tombol jepret ditekan');

        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(seconds: 1));
        }

        final popupHasil = find.byKey(const Key("popup_hasil_foto"));

        expect(popupHasil, findsNothing,
            reason: "Popup masih nyangkut di jepretan ke-${i + 1}!");
        debugPrint('✅ Layar bersih, siap foto berikutnya');
      }

      final completePhotoBtn = find.byKey(const Key("btn_complete_photo"));
      expect(completePhotoBtn, findsOneWidget,
          reason: "Complete Button tidak ditemukan");
      await tester.tap(completePhotoBtn);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      debugPrint('Mencari Dialog Konfirmasi...');

      await tester.pump(const Duration(seconds: 2));

      final dialogFinder = find.byType(Dialog);
      if (dialogFinder.evaluate().isEmpty) {
        debugPrint('❌ GAGAL: Dialog tidak muncul di widget tree!');
      } else {
        debugPrint('✅ Dialog ditemukan!');
      }

      final btnYaLanjut = find.byKey(const Key("btn_ya_lanjut"));
      await tester.ensureVisible(btnYaLanjut);
      expect(btnYaLanjut, findsOneWidget,
          reason: "Tombol Ya Lanjut di popup tidak ditemukan");
      final Offset center = tester.getCenter(btnYaLanjut);
      await tester.tapAt(center);


      debugPrint('🚀 SUKSES! BERHASIL KEMBALI KE HOME!');
    });

    testWidgets('Test fitur di Layout Page dengan data dummy', (tester) async {
      final directory = await getTemporaryDirectory();
      final dummyPath = '${directory.path}/dummy_photo.jpg';
      final file = File(dummyPath);

      if (!await file.exists()) {
        final byteData = await rootBundle.load('test/fixture/dummy_photo.jpeg');
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      app.main();
      await tester.pumpAndSettle();

      final sessionController = Get.put(SessionController(), permanent: true);
      sessionController.isTestMode.value = true;

      final Map<int, FilterItem> emptyFilters = <int, FilterItem>{};

      final mockArgs = {
        'urls': <String>[dummyPath, dummyPath, dummyPath],
        'localPhotos': <String>[dummyPath, dummyPath, dummyPath],
        'booking': Booking(
          id: 'dummy-uuid-1234-5678',
          bookingId: 'TEST99',
          serviceName: 'Memori Lane',
          isAiGenerate: false,
          transactionNumber: '',
          name: '',
          phoneNumber: '',
          email: '',
          photoDate: '',
          status: 1,
          paymentStatus: 1,
          galleries: [],
        ),
        'filters': emptyFilters,
        'isSony': false,
        'isLandscape': true,
        'showEventFrames': false,
        'eventSubCategory': null,
      };

      Get.toNamed(AppRoutes.layout, arguments: mockArgs);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("layer_layout")), findsOneWidget,
          reason: "Gagal memuat halaman Layout");

      debugPrint('🎨 [Layout] Memulai pengujian fitur interaktif...');

      // 2. Cari dan klik Slot 1
      final slotSatu = find.text('1');
      expect(slotSatu, findsOneWidget,
          reason: "Slot 1 (kosong) tidak ditemukan di canvas");
      await tester.tap(slotSatu);
      await tester.pumpAndSettle();

      // 3. Verifikasi Bottom Sheet Muncul & Pilih Foto
      final bottomSheet = find.byType(BottomSheet);
      expect(bottomSheet, findsOneWidget,
          reason: "Bottom sheet pemilih foto tidak muncul");

      final fotoPilihan = find.byKey(ValueKey(dummyPath)).first;

      await tester.ensureVisible(fotoPilihan);
      await tester.tap(fotoPilihan);
      await tester.pumpAndSettle();
      debugPrint('✅ Foto berhasil dipilih dari Bottom Sheet');

      // 4. Uji Manipulasi Foto (Drag pada PannablePhotoWidget)
      final pannablePhoto = find.byType(PannablePhotoWidget);
      expect(pannablePhoto, findsOneWidget,
          reason: "Foto gagal di-render di dalam slot");

      // Geser foto sedikit untuk memastikan gesture berjalan
      await tester.drag(pannablePhoto, const Offset(30, 30));
      await tester.pumpAndSettle();
      debugPrint('✅ Foto berhasil digeser di dalam frame');

      // 5. Simpan & Lanjut ke Edit-Review
      final btnNext = find.byKey(const Key("btn_simpan_layout"));
      await tester.tap(btnNext);
      await tester.pumpAndSettle();

      // 6. Verifikasi mendarat di ReviewScreen
      expect(find.byType(ReviewScreen), findsOneWidget,
          reason: "Gagal navigasi ke halaman Review Screen");

      // Tunggu hingga tombol berubah dari 'Memuat...' menjadi 'Selesai & Simpan'
      await tester.pump(const Duration(seconds: 2));

      // 7. Klik Selesai & Simpan
      final btnSelesai = find.text('Selesai & Simpan');
      expect(btnSelesai, findsOneWidget);
      await tester.tap(btnSelesai);
      await tester.pumpAndSettle();

      debugPrint('🚀 SUKSES! Flow dari Layout hingga Review selesai!');
    });
  });

  group('End-to-End App Test (Mega Flow)', () {
    testWidgets(
        'Full E2E: Sudah Booking -> Kamera -> Layout -> Review -> Thank You',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      final sessionController = Get.put(SessionController(), permanent: true);
      sessionController.isTestMode.value = true;
      const int targetPhotos = 3;
      sessionController.setPackageSettings(
        maxPhotos: targetPhotos,
        durationSeconds: 1200,
      );

      debugPrint('🛒 [E2E] Memulai alur Datang Langsung...');
      final datangLangsungButton = find.byKey(const Key('btn_datang_langsung'));
      expect(datangLangsungButton, findsOneWidget);

      await tester.tap(datangLangsungButton);
      await tester.pumpAndSettle();

      expect(find.text('Pilih Paket'), findsWidgets);

      final selectedServiceId =
          find.byKey(const Key("item_897b6293-b710-4ddf-9a59-91c64648417e"));
      await tester.tap(selectedServiceId);
      await tester.pumpAndSettle();

      final selanjutnyaBtn = find.byKey(const Key("btn_order_next"));
      await tester.tap(selanjutnyaBtn);
      await tester.pumpAndSettle();

      expect(find.byType(VoucherScreen), findsOneWidget,
          reason: "Gagal pindah ke VoucherScreen");
      expect(find.text("Kode Voucher"), findsOneWidget);
      final skipButtonVoucher = find.byKey(const Key("btn_skip_voucher"));
      await tester.tap(skipButtonVoucher);
      await tester.pumpAndSettle();

      expect(find.text("Cek Pembayaran"), findsWidgets);
      await tester.pump(const Duration(seconds: 4));

      // Key ini membungkus keseluruhan Bottom Nav (ada tombol Kembali & Cek)
      final bottomNav = find.byKey(const Key("btn_check_payment"));

      const int maxAttempts = 5;
      int attempts = 0;
      bool isPaymentConfirmed = false;

      debugPrint('===================================================');
      debugPrint(
          '⏳ WAKTUNYA MANUAL! SILAKAN UBAH STATUS DI WEB ADMIN SEKARANG!');
      debugPrint('Kamu punya waktu sekitar 20 detik...');
      debugPrint('===================================================');

      while (!isPaymentConfirmed && attempts < maxAttempts) {
        if (bottomNav.evaluate().isEmpty) {
          debugPrint('❌ GAGAL: Bottom Nav hilang! Layar terpental mundur.');
          break;
        }

        final textCekPembayaran = find.descendant(
          of: bottomNav,
          matching: find.text('Cek Pembayaran'),
        );

        if (textCekPembayaran.evaluate().isNotEmpty) {
          await tester.ensureVisible(textCekPembayaran);
          // Robot akan mengeklik tepat di tengah-tengah teks "Cek Pembayaran"
          await tester.tap(textCekPembayaran, warnIfMissed: false);
        } else {
          debugPrint('⚠️ Teks "Cek Pembayaran" tidak ditemukan!');
        }

        // Beri waktu API merespons
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        final cameraScreen = find.byKey(const Key("camera_screen"));

        if (cameraScreen.evaluate().isNotEmpty) {
          isPaymentConfirmed = true;
          debugPrint('✅ API mendeteksi LUNAS! Lanjut ke Kamera.');
          break;
        } else {
          debugPrint('⏱️ Percobaan ${attempts + 1} gagal. Menunggu 4 detik...');
          await tester.pump(const Duration(seconds: 4));
          attempts++;
        }
      }

      expect(isPaymentConfirmed, isTrue,
          reason:
              "Payment Confirmation gagal. Waktu habis atau tombol salah klik.");
      debugPrint('📸 [E2E] 2. Memulai Sesi Kamera...');
      final btnJepret = find.byKey(const Key("btn_capture_foto"));

      for (var i = 0; i < targetPhotos; i++) {
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(btnJepret);

        for (int j = 0; j < 10; j++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byKey(const Key("popup_hasil_foto")), findsNothing);
      }

      final completePhotoBtn = find.byKey(const Key("btn_complete_photo"));
      await tester.tap(completePhotoBtn);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      final btnYaLanjut = find.byKey(const Key("btn_ya_lanjut"));
      await tester.ensureVisible(btnYaLanjut);
      await tester.tapAt(tester.getCenter(btnYaLanjut));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      debugPrint('🎨 [E2E] 3. Mendarat di Layout Page (dengan Foto Real)...');
      expect(find.byKey(const Key("layer_layout")), findsOneWidget);

      final slotSatu = find.text('1');
      expect(slotSatu, findsOneWidget);
      await tester.tap(slotSatu);
      await tester.pumpAndSettle();

      final bottomSheet = find.byType(BottomSheet);
      expect(bottomSheet, findsOneWidget);

      final gridView =
          find.descendant(of: bottomSheet, matching: find.byType(GridView));
      final fotoPilihan = find
          .descendant(of: gridView, matching: find.byType(GestureDetector))
          .first;

      await tester.ensureVisible(fotoPilihan);
      await tester.tap(fotoPilihan);
      await tester.pumpAndSettle();

      // Manipulasi Foto (Drag)
      final pannablePhoto = find.byType(PannablePhotoWidget);
      expect(pannablePhoto, findsOneWidget);
      await tester.drag(pannablePhoto, const Offset(30, 30));
      await tester.pumpAndSettle();

      // Simpan Layout
      final btnSimpanLayout = find.byKey(const Key("btn_simpan_layout"));
      await tester.tap(btnSimpanLayout);
      await tester.pumpAndSettle();

      debugPrint('👀 [E2E] 4. Mendarat di Review Screen...');
      expect(find.byType(ReviewScreen), findsOneWidget);

      // Tunggu proses preload selesai agar tombol berubah state
      await tester.pump(const Duration(seconds: 2));
      final btnSelesai = find.text('Selesai & Simpan');
      expect(btnSelesai, findsOneWidget);

      debugPrint('⏳ [E2E] Memulai proses Export Photo (ini butuh waktu)...');
      await tester.tap(btnSelesai);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 30));

      debugPrint('🎉 [E2E] 5. Navigasi ke Thank You Screen...');

      // Tunggu hingga ThankYouScreen muncul
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(ThankYouScreen), findsOneWidget);
      await tester.pumpAndSettle();

      debugPrint('📝 [E2E] Mengisi form Kontak di Thank You Screen...');

      // Cari semua TextField yang ada di layar
      final textFields = find.byType(TextField);

      if (textFields.evaluate().length >= 2) {
        await tester.ensureVisible(textFields.at(0));
        await tester.enterText(textFields.at(0), 'Bobon Sigma Boy (Isam testing)');
        await tester.pumpAndSettle();

        await tester.ensureVisible(textFields.at(1));
        await tester.enterText(textFields.at(1), '081234567890');
        await tester.pumpAndSettle();

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final btnKirim = find.text('Kirim ke WA & Selesai');
      expect(btnKirim, findsOneWidget);
      await tester.ensureVisible(btnKirim);
      await tester.tap(btnKirim);

      debugPrint('⏳ Menunggu proses kirim data ke WA...');
      await tester.pumpAndSettle(const Duration(seconds: 5));

      debugPrint('🏆 MEGA TEST E2E BERHASIL 100% KEMBALI KE HOME!');
    });
  });
}
