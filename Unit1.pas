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
    strPort: String;
    procedure LoadIniFile;
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
    iniFile := TIniFile.Create('.\setting.ini'); // �����ɪ��ؿ��U
    // LPT1, \\.\USB001
    strPort := iniFile.ReadString('setting', 'port', '');
  finally
    iniFile.DisposeOf;;
  end;

end;

procedure TForm1.btnStartClick(Sender: TObject);
var
  f: textfile;
begin
  if OpenDialog1.Execute then
  begin
    Memo1.Lines.LoadFromFile(OpenDialog1.FileName);
    Assignfile(f, strPort);

    rewrite(f);
    write(f, chr(27) + '@' + chr(1)); // ESC a => initialize
    write(f, chr(27) + '!' + chr(0)); // ESC ! => font A
    write(f, chr(27) + 'a' + chr(0)); // ESC a 0 => ��r�a�����
    write(f, PChar(Memo1.Lines.Text));
    write(f, chr(10)); // Line Feeding
    closefile(f);
    {
      // ����X
      write(f, chr(27) + 'a' + chr(49)); // �̫�@�X 48�G��r�a����� 49�G�m�����
      write(f, chr(27) + '!' + chr(6)); // �^��r��j���v
      write(f, chr(28) + '!' + chr(1)); // ����r��j���v
      write(f, chr(29) + 'w' + chr(1)); // ���X�e�סA�̤p��� 1,2,3
      write(f, chr(29) + 'h' + chr(36)); // ���X����
      write(f, chr(29) + 'H' + chr(3)); // ���X�ȭn�L�b���̡H( 0�G���L�A1�G���X�W���A2�G���X�U���A3�G���X�W�U���L)
      write(f, chr(29) + 'f' + chr(1)); // HRI�r��
      write(f, chr(28) + chr(40) + chr(76) + chr(2) + chr(0) + chr(66) + chr(49));
      // FS (L �e�Ȩ�w���I
      write(f, chr(29) + chr(86) + chr(0)); // ����
      closefile(f);
    }
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  f: textfile;
begin
  LoadIniFile;
  labPort.Text := 'Port: ' + strPort;

  if fileexists('test.txt') then
  begin
    Memo1.Lines.LoadFromFile('test.txt');
    Assignfile(f, strPort);
    rewrite(f);
    write(f, chr(27) + '@' + chr(1)); // ESC a => initialize
    write(f, chr(27) + '!' + chr(0)); // ESC ! => font A
    write(f, chr(27) + 'a' + chr(0)); // ESC a 0 => ��r�a�����
    write(f, PChar(Memo1.Lines.Text));
    write(f, chr(10)); // Line Feeding
    closefile(f);

    tmrClose.Enabled := True;
    Memo1.Lines.Add('�C�L�����A�T�������');
  end
  else
    ShowMessage('test.txt �ɮפ��s�b�I');

end;

procedure TForm1.tmrCloseTimer(Sender: TObject);
begin
  Self.Close;
end;

end.
