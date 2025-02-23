unit Product.Module;

interface

uses
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, JvDataSource, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Comp.UI,
  CRUD.Module,
  CRUD.Service.Intf,
  Product.Service;

type
  TProductDM = class(TCrudDM)
    Product: TFDMemTable;
    SearchesID: TIntegerField;
    SearchesNombre: TStringField;
    SearchesMarca: TStringField;
    SearchesPrecio: TFloatField;
    ProductID: TIntegerField;
    ProductNombre: TStringField;
    ProductMarcar: TStringField;
    ProductDescripcion: TMemoField;
    ProductPrecio: TFloatField;
    ProductStock: TIntegerField;
    ProductCategoria: TStringField;
    ProductSource: TJvDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    [Spring.Container.Common.InjectAttribute]
    FProductService: IProductService;
  public
    function CurrentStock: Integer;
    function getEntity: TFDMemTable; override;
    function getService: ICRUDService; override;
    procedure Ping;
    procedure Sales;
    function SendMessage(AMsg: string): string;
  end;


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Spring.Services;


procedure TProductDM.DataModuleCreate(Sender: TObject);
begin
  inherited;

  FProductService := ServiceLocator.GetService<IProductService>;
end;


procedure TProductDM.DataModuleDestroy(Sender: TObject);
begin
  FProductService := nil;

  inherited;
end;


// CurrentStock retorna el stock actual del producto activo
function TProductDM.CurrentStock: Integer;
begin
  Result := 0;

  if Entity.Active and (not Entity.IsEmpty) then
    Result := Entity.FieldByName('Stock').AsInteger;
end;


// getEntity retorna el dataset maestro
function TProductDM.getEntity: TFDMemTable;
begin
  Result := Product;
end;


// getService retornsa el servicio para la comunicación remota
function TProductDM.getService: ICRUDService;
begin
  Result := FProductService;
end;


// Ping ejecuta el test de conexión al servidor remoto
procedure TProductDM.Ping;
begin
  FProductService.Ping;
end;


// Sales simula la venta de un producto
procedure TProductDM.Sales;
begin
  FProductService.Sales(CurrentID.ToInt64);
end;


// SendMessage envía un mensaje al servidor remoto a traves del servicio
function TProductDM.SendMessage(AMsg: string): string;
begin
  Result :=  FProductService.SendMessage(AMsg);
end;

end.
