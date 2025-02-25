Cara membuat installer.
Yang di butuhkan:
1. Qt5/vscode
2. Procmon / dendency walker
3. Gimp / photoshop (Optional hanya untuk membuat icon.ico)
4. inno

Cara prose:
1. (QT) Build aplkasi dari source setelah selesai, hasil build ambil file exe, dll dari hasil kompil.
	Biasanya semua tersimpan di folder build/bin. Salin semua file-file tersebut ke dalam folder bin di sini.
2. (Procmon) Kumpulkan file.dll dan plugins yang tercecer (folder deploy_windows) setelah mengumpulkan file.dll dan plugins utama.
	bisa menggunakan procmon, depedency walker atau sejenisnya.
	Setelah terkumpul masukan ke folder bin disini. file.dll dari libs/file.dll dan nama_folder plugin plugins/folder_plugin/file.dll
3. (Gimp) Buat icon.ico kemudian masukan ke folder bin disini.
4. (inno) Buat dan Buka file.iss di (bersama README ini) kemudian eksekusi.
