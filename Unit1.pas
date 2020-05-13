unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, IniFiles,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox;

type
  TForm1 = class(TForm)
    btnStart: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    tmrClose: TTimer;
    labPort: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
  private
    { Private declarations }
    strPort, inFileName: String;
    tAutoClose: Integer;
    procedure LoadIniFile;
    procedure WriteFileToPort(filePath: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.LoadIniFile;
var
  iniFile: TIniFile;
begin
  try
    iniFile := TIniFile.Create('.\setting.ini'); // 執行檔的目錄下

    // LPT1 或 \\.\USB001
    strPort := iniFile.ReadString('setting', 'port', '\\.\USB001');

    inFileName := iniFile.ReadString('setting', 'inFileName', 'test.txt');
    tAutoClose := iniFile.ReadInteger('setting', 'tAutoClose', 3);
  finally

  end;
  iniFile.DisposeOf;
end;

{
  // ESC 控制碼
  write(f, chr(27) + 'a' + chr(49)); // 最後一碼 48：文字靠左對齊 49：置中對齊
  write(f, chr(27) + '!' + chr(6)); // 英文字放大倍率
  write(f, chr(28) + '!' + chr(1)); // 中文字放大倍率
  write(f, chr(29) + 'w' + chr(1)); // 條碼寬度，最小單位 1,2,3
  write(f, chr(29) + 'h' + chr(36)); // 條碼高度
  write(f, chr(29) + 'H' + chr(3)); // 條碼值要印在哪裡？( 0：不印，1：條碼上面，2：條碼下面，3：條碼上下都印)
  write(f, chr(29) + 'f' + chr(1)); // HRI字體
  write(f, chr(28) + chr(40) + chr(76) + chr(2) + chr(0) + chr(66) + chr(49));
  // FS (L 送紙到定位點
  write(f, chr(29) + chr(86) + chr(0)); // 切紙
  closefile(f);
}

procedure TForm1.WriteFileToPort(filePath: string);
var
  f: TextFile;
  strList: TStringList;
begin
  if fileexists(filePath) then
  begin
    try
      Memo1.Lines.Add('==== 檔案內容 ====');
      strList := TStringList.Create;
      strList.LoadFromFile(filePath);
      Memo1.Lines.Add(strList.Text);
      Memo1.Lines.Add('===================');

      Assignfile(f, strPort);
      rewrite(f);
      // 傳送 EPSON 的控制碼 (ESC)
      write(f, chr(27) + '@' + chr(1)); // ESC @ => initialize
      write(f, chr(27) + '!' + chr(0)); // ESC ! => font A
      write(f, chr(27) + 'a' + chr(0)); // ESC a 0 => 文字靠左對齊
      // 寫入檔案內容
      write(f, PChar(strList.Text));
      // 結尾
      write(f, chr(10)); // Line Feeding
      closefile(f);

      Memo1.Lines.Add('列印完畢');
      strList.DisposeOf();
    except
      on e: Exception do
        Memo1.Lines.Add('Assignfile 例外發生: ' + e.ToString);
    end;
  end
  else
    Memo1.Lines.Add(filePath + ' 檔案不存在！');

  Memo1.Lines.SaveToFile('.\log.txt');
  tmrClose.Enabled := True;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    WriteFileToPort(OpenDialog1.FileName);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadIniFile;
  labPort.Text := 'Port: ' + strPort;
  tmrClose.Enabled := false;
  tmrClose.Interval := tAutoClose * 1000;
  Memo1.Lines.Add('自動關閉(s):' + tAutoClose.ToString);

  WriteFileToPort(inFileName);
end;

procedure TForm1.tmrCloseTimer(Sender: TObject);
begin
  Self.Close;
end;

end.
