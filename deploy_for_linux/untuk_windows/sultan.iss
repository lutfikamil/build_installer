[Setup]
AppName=Sultan-lm
AppVersion=1.0
DefaultDirName={pf}\Sultan-lm
DefaultGroupName=Sultan-lm
OutputDir=.
OutputBaseFilename=Installer_Sultan-lm
Compression=lzma
SolidCompression=yes

[Tasks]
Name: "install_mariadb"; Description: "Unduh dan Install MariaDB. Apabila anda akan menggunakan mysql sebagai database. Default database sqlite."; GroupDescription: "Database:"

[Files]
Source: "bin/*"; DestDir: "{app}"; Flags: recursesubdirs
Source: "bin/icon.ico"; DestDir: "{app}"

[Icons]
Name: "{group}\Sultan-lm"; Filename: "{app}\Sultan.exe"
Name: "{group}\Uninstall_Sultan-lm"; Filename: "{uninstallexe}"
Name: "{commondesktop}\Sultan-lm"; Filename: "{app}\Sultan.exe"; IconFilename: "{app}\icon.ico"


[Run]
Filename: "{app}\Sultan.exe"; Description: "Jalankan Sultan-lm V.1.0"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
const
  URL_MariaDB = 'https://downloads.mariadb.org/interstitial/mariadb-10.11.5-winx64.msi';

function DownloadFile(URL, TargetFile: String): Boolean;
var
  WinHttpReq: Variant;
  FileStream: TFileStream;
  ResponseBody: AnsiString;
  i: Integer;
begin
  Result := False;
  try
    WinHttpReq := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    WinHttpReq.Open('GET', URL, False);
    WinHttpReq.Send;

    if WinHttpReq.Status <> 200 then
    begin
      MsgBox('Gagal mengunduh MariaDB. Cek koneksi internet.', mbError, MB_OK);
      Exit;
    end;

    ResponseBody := WinHttpReq.ResponseBody; // Konversi ke string

    FileStream := TFileStream.Create(TargetFile, fmCreate);
    try
      for i := 1 to Length(ResponseBody) do
        FileStream.WriteBuffer(ResponseBody[i], 1);
    finally
      FileStream.Free;
    end;

    Result := True;
  except
    MsgBox('Gagal mengunduh MariaDB.', mbError, MB_OK);
  end;
end;
