unit Main.Form;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.TabControl, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, Product.Module,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Memo.Types, FMX.Memo, FMX.ListBox, FMX.Edit,
  Spring.Container,
  Spring.Container.Common,
  Spring.Services,
  CRUD.Module;

type
  TMainForm = class(TForm)
    CaptionLayout: TLayout;
    MenuLayout: TLayout;
    BodyLayout: TLayout;
    AppContainer: TTabControl;
    tabHome: TTabItem;
    tabLogin: TTabItem;
    tabCrud: TTabItem;
    HomeRec: TRectangle;
    ChatRect: TRectangle;
    CrudRec: TRectangle;
    tabChat: TTabItem;
    Rectangle1: TRectangle;
    btnHome: TSpeedButton;
    btnCrud: TSpeedButton;
    btnChat: TSpeedButton;
    EntityContainer: TTabControl;
    tabFind: TTabItem;
    tabEntity: TTabItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    fldID: TEdit;
    fldMarca: TEdit;
    fldNombre: TEdit;
    fldStock: TEdit;
    Label7: TLabel;
    fldPrecio: TEdit;
    fldDescripcion: TMemo;
    Grid1: TGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    LinkFillControlToField2: TLinkFillControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    lblProductList: TLabel;
    lblProductSelection: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    lblProductDescription: TLabel;
    Label9: TLabel;
    btnReturn: TSpeedButton;
    btnSave: TButton;
    Layout3: TLayout;
    Layout4: TLayout;
    scrollMessages: TVertScrollBox;
    RoundRect1: TRoundRect;
    edMessage: TEdit;
    ComboBox1: TComboBox;
    LinkFillControlToField1: TLinkFillControlToField;
    Button2: TButton;
    btnAdd: TButton;
    VertScrollBox1: TVertScrollBox;
    ImageControl1: TImageControl;
    lblTitle: TLabel;
    lblSubTitle: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OnHomeClick(Sender: TObject);
    procedure OnCrudClick(Sender: TObject);
    procedure OnChatClick(Sender: TObject);
    procedure OnGrid1CellDblClick(const Column: TColumn; const Row: Integer);
    procedure btnReturnClick(Sender: TObject);
    procedure OnEntitySave(Sender: TObject);
    procedure edMessageKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure OnSales(Sender: TObject);
    procedure OnAddProduct(Sender: TObject);
  private
    [Spring.Container.Common.InjectAttribute]
    FProductDM: TProductDM;
    FServerConnected: Boolean;
  public
    function GetDM: TCrudDM;
    procedure ConnectServer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses Chat.Frame;


procedure TMainForm.btnReturnClick(Sender: TObject);
begin
  GetDM.SelectAll;
  EntityContainer.ActiveTab := tabFind;
end;


procedure TMainForm.ConnectServer;
begin
  try
    FProductDM.Ping;
    FServerConnected := True;
  except
    FServerConnected := False;
  end;
end;


procedure TMainForm.edMessageKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Msg: string;
begin
  if Key = vkReturn then
  begin
    Msg := edMessage.Text.Trim;
    edMessage.Text := EmptyStr;
    if Msg = EmptyStr then
      Key := 0
    else begin
      NewFrame(scrollMessages, TMsgType.ctResquest, Msg, TAlignLayout.Right);
      Sleep(100);
      Msg := FProductDM.SendMessage(Msg);
      NewFrame(scrollMessages, TMsgType.ctResponse, Msg, TAlignLayout.Left);
    end;
  end;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  AppContainer.TabPosition := TTabPosition.None;
  AppContainer.ActiveTab := tabHome;
  EntityContainer.TabPosition := TTabPosition.None;
  EntityContainer.ActiveTab := tabFind;

  FProductDM := ServiceLocator.GetService<TProductDM>;
end;


function TMainForm.getDM: TCrudDM;
begin
  Result := FProductDM;
end;


procedure TMainForm.OnGrid1CellDblClick(const Column: TColumn; const Row: Integer);
begin
  GetDM.EditFromSearch;
  EntityContainer.ActiveTab := tabEntity;
  fldStock.Enabled := False;
end;


procedure TMainForm.OnAddProduct(Sender: TObject);
begin
  GetDM.AppendRecord;
  EntityContainer.ActiveTab := tabEntity;
  fldStock.Enabled := True;
end;


procedure TMainForm.OnChatClick(Sender: TObject);
begin
  AppContainer.ActiveTab := tabChat;
  edMessage.SetFocus;
end;


procedure TMainForm.OnCrudClick(Sender: TObject);
begin
  try
    GetDM.SelectAll;
  except
    MessageDlg('No pude conectarme al servidor localhost:8080'#13'Por favor, revise que el servicio este ejecutandose',
      TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOk],
      0, nil);
    Exit;
  end;

  AppContainer.ActiveTab := tabCrud;
end;


procedure TMainForm.OnEntitySave(Sender: TObject);
begin
  GetDM.SaveRecord;
  ShowMEssage('Registro guardado satisfactoriamente');
  btnReturn.OnClick(nil);
end;


procedure TMainForm.OnHomeClick(Sender: TObject);
begin
  AppContainer.ActiveTab := tabHome;
end;


procedure TMainForm.OnSales(Sender: TObject);
begin
  if FProductDM.CurrentStock > 0 then
  begin
    var ID := FProductDM.CurrentID;
    FProductDM.Sales;
    FProductDM.EditRecord(ID);
    ShowMessage(Format('Listo, ahora queda un stock de %d productos.', [FProductDM.CurrentStock]));
  end
  else
    ShowMessage('No hay stock disponible para la venta');
end;



end.
