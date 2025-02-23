unit Chat.Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Ani,
  FMX.Controls.Presentation, FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  // El tipo de mensaje a incrustar, esto determina el ícono a mostrar
  // ctRequest  mensaje del usuario
  // ctResponse mensaje del servidor
  TMsgType = (ctResquest, ctResponse);

  TChatFrame = class(TFrame)
    Layout1: TLayout;
    IACircle: TCircle;
    UserCircle: TCircle;
    MainRect: TRectangle;
    EditRect: TRoundRect;
    BitmapListAnimation1: TBitmapListAnimation;
    txtMessage: TMemo;
  private
    FMsgType: TMsgType;
    procedure HideIcon(Obj: TCircle);
  public
    constructor Create(AOwner: TComponent; AMsgType: TMsgType; AMsgText: string; MsgAlign: TAlignLayout);
  end;

function NewFrame(AOwner: TComponent; AMsgType: TMsgType; AMsgText: string; MsgAlign: TAlignLayout): TChatFrame;

implementation

{$R *.fmx}


// GenFrameName genera un nombre aleatorio para el componente embebido
function GenFrameName(Longitud: Integer): string;
const
  CharSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var
  i: Integer;
begin
  Randomize; // Inicializar el generador de números aleatorios
  Result := '';
  for i := 1 to Longitud do
  begin
    // Seleccionar un carácter aleatorio del conjunto "Caracteres"
    Result := Result + CharSet[Random(Length(CharSet)) + 1];
  end;
end;


// NewFrame retorna el componente de mensaje que será embebido
function NewFrame(AOwner: TComponent; AMsgType: TMsgType; AMsgText: string; MsgAlign: TAlignLayout): TChatFrame;
begin
  var Scroll := TVertScrollBox(AOwner);

  Result := TChatFrame.Create(AOwner, AMsgType, AMsgText, MsgAlign);
  Result.Name := GenFrameName(12);
  Result.Parent := Scroll;
  Result.Align := TAlignLayout.Top;

  Scroll.ViewportPosition := PointF(0, Result.Position.Y + Result.Height - Scroll.Height);
  Scroll.Repaint;
end;


constructor TChatFrame.Create(AOwner: TComponent; AMsgType: TMsgType; AMsgText: string; MsgAlign: TAlignLayout);
begin
  inherited Create(AOwner);

  FMsgType := AMsgType;
  case FMsgType of
    ctResquest: HideIcon(IACircle);
    ctResponse: HideIcon(UserCircle);
  end;

  MainRect.Align := MsgAlign;
  txtMessage.Text := AMsgText;
end;


// HideIcon cambia el estatus de visibilidad a un TCircle
procedure TChatFrame.HideIcon(Obj: TCircle);
begin
  Obj.Visible := False;
end;

end.
