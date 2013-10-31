unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Magnetic, XPMenu, ExtCtrls, StdCtrls, MMSystem, ComObj, FFPBox, JPEG,
  Buttons, ExtDlgs;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    XPMenu1: TXPMenu;
    Timer1: TTimer;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Label2: TLabel;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    OpenPictureDialog1: TOpenPictureDialog;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);

  private
    { Private declarations }
    ZeminBMP : tBitmap;
    procedure WMEraseBkgnd(var m: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure EkranCiz;
  public
    { Public declarations }
  end;


type
 yapi = record
                             harf : Char;
                             xPos,yPos,SatirNo : integer;
                             SeciliRenk : TColor;
                             bold,italic : boolean;
                             dolu : boolean;
                            end;

var
  Form1: TForm1;
  posX,posY : Integer;
  ProgFolder : String;

  KeySounds : array[1..20] of record
                               Sound         : pointer;
                               SoundDataSize : LongInt;
                              end;

  Kagit : array[1..6000] of yapi;
  MaxHarf : integer;
  Basildi : Integer;
  sonKey  : char;
  KagitUst : Integer;
  KagitBoy : Integer;
  SatirNo  : Integer;
  SeciliRenk : tcolor;
  italicVar,boldVar : Boolean;


implementation

{$R *.DFM}

procedure TForm1.WMEraseBkgnd(var m : TWMEraseBkgnd); //flicker free
begin
  m.Result := LRESULT(False);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 try
  FreeMem(KeySounds[1].Sound, KeySounds[1].SoundDataSize);
  FreeMem(KeySounds[2].Sound, KeySounds[2].SoundDataSize);
  FreeMem(KeySounds[3].Sound, KeySounds[3].SoundDataSize);
 finally
 end;
end;


procedure TForm1.EkranCiz;
var
 i,j : integer;
 rect2 : trect;
 rgn : HRgn;
 OldStyle : TBrushStyle;
 bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
   bmp.Canvas.Brush.Color := Color;
   bmp.Width := Width;
   bmp.Height := Height;
   bmp.Canvas.Font := Font;
// canvas.copymode := cpmd;

   bmp.Canvas.brush.Color := RGB(255,255,255);
   bmp.Canvas.FillRect(rect(0,0,PaintBox1.Width,PaintBox1.Height));

   rgn := CreateRoundRectRgn(10,KagitUst,PaintBox1.Width-10,PaintBox1.Height-10,5,5);

   SelectClipRgn(bmp.Canvas.Handle,rgn);

   For i := 1 to 10 do
   begin
    for j := 1 to 10 do
    begin
     bmp.Canvas.Draw( ((i-1) * ZeminBMP.Width)  , ((j-1) * ZeminBMP.Height), ZeminBMP);
    end;
   end;


   bmp.Canvas.Font.Name := 'Courier New';
   bmp.Canvas.Font.Size := 12;

   bmp.Canvas.Brush.Style := bsClear;
   for i := 1 to MaxHarf do
   begin
    bmp.Canvas.Font.Color := Kagit[i].SeciliRenk;
    bmp.Canvas.Font.Style := [];
    if (Kagit[i].bold) and (Kagit[i].italic) then bmp.Canvas.Font.Style := [fsBold,fsItalic] else
    if Kagit[i].bold then bmp.Canvas.Font.Style := [fsBold] else
    if Kagit[i].italic then bmp.Canvas.Font.Style := [fsItalic];

    bmp.Canvas.TextOut(Kagit[i].Xpos, (KagitUst + (Kagit[i].SatirNo * 18) ) ,Kagit[i].harf); //Kagit[i].Ypos +
   end;

   bmp.Canvas.Brush.Style := OldStyle;

   bmp.Canvas.brush.Color := RGB(55,55,55);

   i := KagitUst + (SatirNo * 18);
   bmp.Canvas.FillRect(rect(posX-2,i,posX,i+17));
   bmp.Canvas.FillRect(rect(posX-2,i+15,posX+15,i+17));
   bmp.Canvas.FillRect(rect(posX+13,i,posX+15,i+17));

   PaintBox1.Canvas.Draw(0,0, bmp);
  finally
   bmp.Free;
  end;
end;


// Kaðýt Üst = KagitBoy - (SatýrNo * x)
procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
 EkranCiz;
end;







///-----------------------------------------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
var
  voice: OLEVariant;
  F            : TFileStream;
  x : longint;
  i,j : integer;
begin
 for i := 1 to 6000 do
 begin
  Kagit[i].harf := ' ';
  Kagit[i].xPos := 2000;
  Kagit[i].yPos := 2000;
  Kagit[i].SatirNo := 0;
  Kagit[i].dolu := false;
  Kagit[i].SeciliRenk := RGB(0,0,0);
  Kagit[i].bold := FALSE;
  Kagit[i].italic := FALSE;
 end;

 progFolder     := ParamStr(0);
 repeat
  if progFolder[length(progFolder)]<>'\' then delete(progFolder,length(progFolder),1);
 until (progFolder='') or (progFolder[length(progFolder)]='\');

 delete(progFolder,length(progFolder),1);

 F := TFileStream.Create(ProgFolder + '\Char_e.wav' , fmOpenRead);
 try  { case something goes wrong, make sure memory gets freed }
  KeySounds[1].Sound := AllocMem(F.Size);
  KeySounds[1].SoundDataSize := F.Size;
  x := F.Read(KeySounds[1].Sound^, KeySounds[1].SoundDataSize);
 finally
  F.Free;
 end;

 F := TFileStream.Create(ProgFolder + '\Space.wav' , fmOpenRead);
 try  { case something goes wrong, make sure memory gets freed }
  KeySounds[2].Sound := AllocMem(F.Size);
  KeySounds[2].SoundDataSize := F.Size;
  x := F.Read(KeySounds[2].Sound^, KeySounds[2].SoundDataSize);
 finally
  F.Free;
 end;

 F := TFileStream.Create(ProgFolder + '\typewriterding.wav' , fmOpenRead);
 try  { case something goes wrong, make sure memory gets freed }
  KeySounds[3].Sound := AllocMem(F.Size);
  KeySounds[3].SoundDataSize := F.Size;
  x := F.Read(KeySounds[3].Sound^, KeySounds[3].SoundDataSize);
 finally
  F.Free;
 end;

 F := TFileStream.Create(ProgFolder + '\bell.wav' , fmOpenRead);
 try  { case something goes wrong, make sure memory gets freed }
  KeySounds[4].Sound := AllocMem(F.Size);
  KeySounds[4].SoundDataSize := F.Size;
  x := F.Read(KeySounds[4].Sound^, KeySounds[4].SoundDataSize);
 finally
  F.Free;
 end;

 F := TFileStream.Create(ProgFolder + '\back.wav' , fmOpenRead);
 try  { case something goes wrong, make sure memory gets freed }
  KeySounds[5].Sound := AllocMem(F.Size);
  KeySounds[5].SoundDataSize := F.Size;
  x := F.Read(KeySounds[5].Sound^, KeySounds[5].SoundDataSize);
 finally
  F.Free;
 end;

 ZeminBmp := TBitmap.Create;
 ZeminBMP.LoadFromFile(progFolder + '\BEJ2.bmp');

 PaintBox1.Font.Name := 'Courier New';
 PaintBox1.Font.Size := 12;
 PosX := 20;
 PosY := 20;

 SeciliRenk := RGB(0,0,0);
 MaxHarf := 0;

 Basildi  := 0;
 sonKey   := chr(199);

 KagitUst := PaintBox1.Height-80;
 KagitBoy := 1100;
 SatirNo  := 1;

 ItalicVar := FALSE;
 BoldVar := FALSE;
end;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
var
 i,j,k:integer;
begin
 if (Basildi=2) and (key=sonKey) then exit;

 if pos(key,'abcçdefgðhiýjklmnoöpqrsþtuüvyxzw ABCÇDEFGÐHÝIJKLMNOÖPQRSÞTUÜVYXZW 1234567890/_*!"^$%&''()=?<>.,;:|¬¹²#¼½¾{[]}\|­+-') <> 0 then
 begin
//  PaintBox1.Canvas.TextOut(PosX,PosY,key);
  if (PosX>PaintBox1.Width-50 ) then
  begin
   PlaySound(KeySounds[4].Sound, 0, SND_MEMORY + SND_ASYNC);
  end else
  begin
   inc(maxHarf);
   Kagit[MaxHarf].harf := key;
   Kagit[MaxHarf].xPos := PosX;
   Kagit[MaxHarf].yPos := PosY;
   Kagit[MaxHarf].dolu := TRUE;
   Kagit[MaxHarf].SatirNo := SatirNo;
   Kagit[MaxHarf].SeciliRenk := SeciliRenk;
   Kagit[MaxHarf].italic := italicVar;
   Kagit[MaxHarf].bold := boldVar;

   inc(PosX, 10); //PaintBox1.Canvas.TextWidth(key) );

   if key = ' ' then PlaySound(KeySounds[2].Sound, 0, SND_MEMORY + SND_ASYNC) else
                     PlaySound(KeySounds[1].Sound, 0, SND_MEMORY + SND_ASYNC); //SND_FILENAME
  end;

  sonKey := key;



  EkranCiz;

 end else
 begin
  if ord(key)=13 then
  begin
   posX := 20;
   Inc(PosY,18); //PaintBox1.Canvas.TextHeight('AÞÐÝYp') );
   Inc(SatirNo);
   if SatirNo>66 then SatirNo := 66;

   PlaySound(KeySounds[3].Sound, 0, SND_MEMORY + SND_ASYNC);

   For i := 6 downto 1 do
   begin
    KagitUst := ( (PaintBox1.Height-80) - ((SatirNo-2)*18) ) - (18-(i*3)) ;
    EkranCiz;
   end;
    
   KagitUst := (PaintBox1.Height-80) - ((SatirNo-1)*18);
   EkranCiz;
  end;

  if ord(key)=8 then
  begin
   if PosX<=20 then
   begin
    PlaySound(KeySounds[4].Sound, 0, SND_MEMORY + SND_ASYNC);
   end else
   begin
    Dec(PosX,10);
    PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
   end;
   EkranCiz;
  end;

  if ord(key)=9 then inc(PosX, 40); //PaintBox1.Canvas.TextWidth('AAAA') );

//  caption := inttostr( ord(key) );
 end;

{

  Different modes:
  Verschiedene modi:

 SND_ASYNC : Start playing, and don't wait to return
             Sound wird im Hintergrund abgespielt.

 SND_SYNC  : Start playing, and wait for the sound to finish
             Das Programm fährt erst dann fort, wenn der
             Sound fertig abgespielt worden ist. }

// SND_LOOP:
 Basildi := 2;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Basildi <> 2 then Basildi := 1;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Basildi := 0;
// caption := inttostr( key );
 if key=112 then SpeedButton3Click(Sender);
 if key=113 then SpeedButton4Click(Sender);
 if key=114 then SpeedButton5Click(Sender);
 if key=115 then SpeedButton2Click(Sender);
 if key=116 then SpeedButton1Click(Sender);

 if Key=38 then
 begin
  Dec(SatirNo);
  if SatirNo<1 then SatirNo := 1;
  KagitUst := (PaintBox1.Height-80) - ((SatirNo-1)*18) ;
  PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
  EkranCiz;
 end;

 if Key=40 then
 begin
  Inc(SatirNo);
  if SatirNo>66 then SatirNo := 66;
  KagitUst := (PaintBox1.Height-80) - ((SatirNo-1)*18) ;
  PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
  EkranCiz;
 end;

end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 SeciliRenk := SpeedButton3.Glyph.Canvas.Pixels[2,2];
 Label1.Font.Color := SeciliRenk;
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 SeciliRenk := SpeedButton4.Glyph.Canvas.Pixels[2,2];
 Label1.Font.Color := SeciliRenk;
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 SeciliRenk := SpeedButton5.Glyph.Canvas.Pixels[2,2];
 Label1.Font.Color := SeciliRenk;
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 SeciliRenk := SpeedButton2.Glyph.Canvas.Pixels[2,2];
 Label1.Font.Color := SeciliRenk;
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 SeciliRenk := SpeedButton1.Glyph.Canvas.Pixels[2,2];
 Label1.Font.Color := SeciliRenk;
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
 italicVar := not ItalicVar;

 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
 boldVar := not boldVar;

 Label1.Font.Style := [];
 if (BoldVar) and (ItalicVar) then Label1.Font.Style := [fsBold,fsItalic] else
 if BoldVar then Label1.Font.Style := [fsBold] else
 if ItalicVar then Label1.Font.Style := [fsItalic];

 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
end;

procedure TForm1.SpeedButton10Click(Sender: TObject);
begin
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
 OpenDialog1.InitialDir := ProgFolder;
 if OpenPictureDialog1.Execute then
 begin
  ZeminBMP.free;
  ZeminBmp := TBitmap.Create;
  ZeminBMP.LoadFromFile( OpenPictureDialog1.FileName );
  EkranCiz;
 end;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
var
 i,j,k:integer;
 f : file of yapi;
begin
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
 if SaveDialog1.Execute then
 begin
  assignfile(f,SaveDialog1.FileName);
  rewrite(f);
  for i := 1 to 6000 do
  begin
   write(f,kagit[i]);
  end;
 end;
  EkranCiz;

end;

procedure TForm1.SpeedButton9Click(Sender: TObject);
var
 i,j,k:integer;
 f : file of yapi;
begin
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
 MaxHarf := 0;

 for i := 1 to 6000 do
 begin
  Kagit[i].harf := ' ';
  Kagit[i].xPos := 2000;
  Kagit[i].yPos := 2000;
  Kagit[i].SatirNo := 0;
  Kagit[i].dolu := false;
  Kagit[i].SeciliRenk := RGB(0,0,0);
  Kagit[i].bold := FALSE;
  Kagit[i].italic := FALSE;
 end;

 if OpenDialog1.Execute then
 begin
  assignfile(f,OpenDialog1.FileName);
  reset(f);
  for i := 1 to 6000 do
  begin
   read(f,kagit[i]);
  end;
 end;

 MaxHarf := 6000;
 repeat
  dec(maxHarf);
 until (kagit[maxHarf].dolu) or (maxHarf=1);
 SatirNo := Kagit[MaxHarf].SatirNo;
 posX := Kagit[MaxHarf].xPos;

 KagitUst := (PaintBox1.Height-80) - ((SatirNo-1)*18) ;
 EkranCiz;
// caption := inttostr(maxHarf);

end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
var
 i,j : integer;
begin
 PlaySound(KeySounds[5].Sound, 0, SND_MEMORY + SND_ASYNC);
 MaxHarf := 0;

 for i := 1 to 6000 do
 begin
  Kagit[i].harf := ' ';
  Kagit[i].xPos := 2000;
  Kagit[i].yPos := 2000;
  Kagit[i].SatirNo := 0;
  Kagit[i].dolu := false;
  Kagit[i].SeciliRenk := RGB(0,0,0);
  Kagit[i].bold := FALSE;
  Kagit[i].italic := FALSE;
 end;

 PaintBox1.Font.Name := 'Courier New';
 PaintBox1.Font.Size := 12;
 PosX := 20;
 PosY := 20;

 SeciliRenk := RGB(0,0,0);
 MaxHarf := 0;

 Basildi  := 0;
 sonKey   := chr(199);

 KagitUst := PaintBox1.Height-80;
 KagitBoy := 1100;
 SatirNo  := 1;

 ItalicVar := FALSE;
 BoldVar := FALSE;
 
 EkranCiz;
end;

end.

