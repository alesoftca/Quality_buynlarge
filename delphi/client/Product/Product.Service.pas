unit Product.Service;

interface

uses
  SysUtils,
  System.JSON,
  MVCFramework.Commons,
  MVCFramework.DataSet.Utils,
  MVCFramework.SystemJSONUtils,
  MVCFramework.Serializer.Commons,
  MVCFramework.RESTClient,
  MVCFramework.RESTClient.Intf,
  FireDAC.Comp.Client,
  Spring.Collections,
  Buyn.Attributes,
  CRUD.Service.Intf,
  CRUD.Service.Impl;

type

  IProductService = interface(ICRUDService)
  ['{39215853-FF62-4AE8-88E2-CFDD6E5EE640}']
    function Ping: Boolean;
    function SendMessage(AMessage: string): string;
    procedure Sales(ProductID: Integer);
  end;

  [ResourcePath('/products')]
  TProductService = class(TCRUDService, IProductService)
    function Ping: Boolean;
    function SendMessage(AMessage: string): string;
    procedure Sales(ProductID: Integer);
  end;

implementation


// StringDepured quita caracteres que a menudo provienen en las respeustas da AI
function StringDepured(const Cadena: string): string;
begin
  // Eliminar saltos de l�nea (\n)
  Result := StringReplace(Cadena, #13, '', [rfReplaceAll]); // Eliminar retorno de carro (CR)
  Result := StringReplace(Result, #10, '', [rfReplaceAll]); // Eliminar salto de l�nea (LF)

  // Eliminar comillas dobles (")
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
end;


// SendMessage env�a un mensaje al servidor para que sea gestionado por la integraci�n OpenAI
function TProductService.SendMessage(AMessage: string): string;
var
  lJSON: TJSONObject;
begin
  Result := EmptyStr;
  try
    lJSON := TJSONObject.Create;
    lJSON.AddPair('prompt', AMessage);
    var Response := RESTClient.Post('/openai', TSystemJSON.JSONValueToString(lJSON, False));

    if Response.StatusCode = HTTP_STATUS.OK then
      Result := StringDepured(response.Content)
    else
      Result := Response.StatusText;
  finally
    if Assigned(lJSON) then
      FreeAndNil(lJSON);
  end;
end;


// Sales m�todo sencillo para aumentar en una unidad el stock de un producto
procedure TProductService.Sales(ProductID: Integer);
begin
  var Body := Format('{"ProductoID": %d,"Cantidad": %d}', [ProductID, 1]);
  var Response := RESTClient.Post('/sales', Body);
end;


// Ping invoca al servidor remoto para constatar la conexi�n
function TProductService.Ping: Boolean;
begin
  var Response := RESTClient.Post('/sales', EmptyStr);

  Result := Response.StatusCode = HTTP_STATUS.OK;
end;


end.
