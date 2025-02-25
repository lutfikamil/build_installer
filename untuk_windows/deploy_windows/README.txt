Cara pemakaian script, untuk mengumpulkan lib dan plugins sultan-lm.v1.0 
hasilnya: 
- lib akan tersimpan di folder libs.
- plugin akan disimpan di folder plugins beserta nama foldernya.
libs\libfile*.dll
plugins\folder_plugins\nama_plugin.dll

JANGAN LUPA script ini di jalankan seteleh windeploqt Jika belum:
1.buka procmon64 kemudian setting Filter:
Process Name ->is ->Sultan.exe ->Include
Path ->containes ->lib ->Include
Path ->containes ->plugins ->Include
Result ->is ->success ->Include (optional jika aplikasi sudah benar-benar tanpa error)

2.buka aplikasi Sultan.exe kemudian masuk ke fungsi-fungsi untuk memastikan seluruh lib sudah di panggil.

3. klik tab Event ->Count Values Occurrences ->Column=Path ->Count
Save daftar libs dan plugins sebagai csv (Logfile.csv).

3. buka Logfile.csv dengan spreadsheet atau apa saja untuk merapikan dan memisah antara path libs dan path plugins.
buat file copy_libs.txt untuk libs, dan copy_plugins.txt untuk plugins.

4. dobel klik copy.bat untuk salin libs dan plugins. copy_libs hanya salin libs, dan copy_plugins hanya salin plugins.