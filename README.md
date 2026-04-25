# whimsify

🌷 Whimsify — Preloved Marketplace App

Give your cute items a new home.

Whimsify adalah aplikasi mobile Flutter bertema katalog produk preloved, terinspirasi dari Carousell. Fokus pada barang-barang imut seperti koleksi Pop Mart, TCG Pokemon, fashion, trinket Nyota, Snoopy, Mofusand, dan lainnya.

Nama Aplikasi
Whimsify — dari kata whimsical (penuh fantasi). Memuliakan barang-barang lucu dengan memberikan rumah baru.cd C:\Users\User\whimsify

Fitur yang Dibuat:

🏠 Home Page

Sapaan personal dengan nama user
Tombol keranjang dengan badge counter dinamis
Banner carousel otomatis 3 slide: pesan eco-friendly, komunitas, dan promo Kartini 10%
Slider kategori ikon bulat horizontal: Woman Fashion, Man Fashion, Health & Beauty, Keychain, Trinket, Shoes, Playing Card, Sticker
Top Picks grid produk dari seller terverifikasi, responsif mengikuti ukuran layar
Tombol favorit ❤️ per produk dengan perubahan state lokal

🔍 Explore Page

Search bar full-featured (nama, brand, kategori, deskripsi, username seller)
Filter kategori horizontal dengan animasi chip
Counter hasil pencarian
Empty state saat tidak ada hasil
GridView responsif (mobile: 2 kolom, tablet: 3 kolom, desktop: 4 kolom)

📋 Detail Page

Hero animation dari home ke detail
Informasi lengkap produk: nama, brand, harga, kondisi, ukuran, kategori, deskripsi
Metode pembayaran yang diterima seller
Info seller + badge verified
Toggle chat untuk nego harga ke seller
Tombol tambah ke keranjang

🏷️ Sell Page (Form)

Foto placeholder (simulasi galeri)
Input: Nama produk, Brand, Kategori (dropdown), Kondisi (dropdown), Ukuran, Deskripsi
Input harga + chip pilihan metode pembayaran (multi-select)
Validasi form lengkap: field kosong & minimal karakter
PopScope — konfirmasi dialog jika keluar saat form belum tersimpan
Produk langsung muncul di Explore & Home setelah listing berhasil
Layout responsif menggunakan LayoutBuilder (mobile: 1 kolom, tablet: 2 kolom)

💬 Komunitas Page

Filter komunitas: Hirono, Nyota, TCG Pokemon, Trinket, Mofusand, Snoopy, Labubu, Molly
Post dengan tipe: WTS, WTB, Discussion (color-coded)
Klik post → modal bottom sheet percakapan + kolom reply
FAB untuk buat postingan baru (tipe, komunitas, judul, konten)
Timestamp relatif (x menit / jam / hari yang lalu)

👤 Profile Page

Avatar, nama, username
Info: umur, tanggal bergabung, lokasi
Statistik: produk dijual, favorit, postingan komunitas
Horizontal scroll produk yang sedang dijual user
Daftar postingan komunitas user

⚙️ Settings Page

Toggle tema: Terang / Gelap / Sistem
Switch.adaptive (mengikuti platform Android/iOS)
Toggle notifikasi chat & price alert
Info versi aplikasi & misi Whimsify
Konfirmasi dialog saat logout

🛒 Cart Page

Daftar produk di keranjang
Total harga otomatis
Tombol checkout
Empty state dengan CTA ke Explore


Struktur Halaman
lib/
├── main.dart                    # Root app + ChangeNotifierProvider + bottom navigation
├── theme/
│   └── app_theme.dart           # ThemeData light & dark, ColorScheme.fromSeed
├── models/
│   └── models.dart              # Product, CommunityPost, CartItem
├── data/
│   ├── mock_data.dart           # Data lokal hardcoded (produk & komunitas)
│   └── app_state.dart           # ChangeNotifier — state management global
├── pages/
│   ├── home_page.dart           # StatelessWidget, CustomScrollView, SliverGrid
│   ├── explore_page.dart        # StatefulWidget, search + filter + GridView
│   ├── detail_page.dart         # StatefulWidget, Hero, chat toggle, add to cart
│   ├── sell_page.dart           # StatefulWidget, Form + PopScope + LayoutBuilder
│   ├── community_page.dart      # StatefulWidget, post list + bottom sheet reply
│   ├── profile_page.dart        # StatelessWidget + Consumer, stats + product list
│   ├── settings_page.dart       # StatefulWidget, Switch.adaptive, theme toggle
│   └── cart_page.dart           # StatelessWidget + Consumer, cart list + checkout
└── widgets/
    ├── product_card.dart        # StatelessWidget + Consumer (favorit terbatas)
    ├── banner_carousel.dart     # StatefulWidget, PageView + Timer auto-slide
    └── category_slider.dart     # StatefulWidget, horizontal ListView

