unit CRUD.Service.Impl;

interface

uses
  System.SysUtils,
  System.Variants,
  System.JSON,
  System.Rtti,
  System.Generics.Collections,
  System.RegularExpressions,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Spring.Collections,
  MVCFramework.Commons,
  MVCFramework.Serializer.Commons,
  MVCFramework.Serializer.Intf,
  MVCFramework.RESTClient,
  MVCFramework.RESTClient.Intf,
  MVCFramework.RESTClient.Commons,
  CRUD.Service.Intf;

const

  payload = 'payload';
  default_keyname = 'ID'; // si usa otro nombre de clave debe anotarla tal cual como esta en el json del modelo

type

  ///
  /// TCRUDService implementa la interface ICRUDService
  ///
  TCRUDService = class(TInterfacedObject, ICRUDService)
  strict private
    FLoading: Boolean;                // indicador del estatus de cargue de datos
    FPath: string;                    // ruta url
    FPrefix: string;                  // prefijo url
    FPort: Integer;                   // puerto url
    FKeyName: string;

  strict protected
    function getKeyName: string; virtual;
    function getPath: string; virtual;
    function getRESTClient: IMVCRESTClient; virtual;
    procedure setKeyName(Value: string); virtual;
    procedure setPath(const Value: string); virtual;

  strict protected
    function GetAnnotedPath: string; overload;

  public
    property KeyName: string read getKeyName write setKeyName;
    property Path: string read getPath write setPath;
    property RESTClient: IMVCRESTClient read getRESTClient;
    property Loading: Boolean read FLoading;
    property Port: Integer read FPort;

    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure Delete(const ID: string); overload; virtual;
    procedure Insert(ADataSet: TFDMemTable); virtual;
    procedure Select(ADataSet: TFDMemTable; const AKeyValue: string); overload; virtual;
    procedure Select(ADataSet: TFDMemTable); overload; virtual;
    procedure Update(ADataSet: TFDMemTable); overload; virtual;
  end;


implementation

uses
  Spring.Reflection,
  MVCFramework.DataSet.Utils,
  MVCFramework.SystemJSONUtils,
  MVCFramework.Serializer.Defaults,
  WebConfig,
  Buyn.Attributes,
  Buyn.Exceptions,
  Buyn.Utils;

var
  FRESTClient: IMVCRESTClient;


constructor TCRUDService.Create;
begin
  inherited Create;

  FRESTClient := nil;
  FLoading := False;
  FPrefix := url_prefix;
  FPort := url_port;
end;


destructor TCRUDService.Destroy;
begin
  FRESTClient := nil;
end;


// Delete ejecuta el método DELETE con el ID dado.
procedure TCRUDService.Delete(const ID: string);
var
  lResponse: IMVCRESTResponse;
begin
  RESTClient.ClearAllParams;
  try
    lResponse := RESTClient.DataSetDelete(Path, Id);
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;

  case lResponse.StatusCode of
    HTTP_STATUS.OK, HTTP_STATUS.NoContent: Exit;
  else
    var msg := ValueFromError(lResponse.Content);
    if msg = Emptystr then
      msg := lResponse.StatusText;
    raise EInternalErrorException.Create(msg);
  end;
end;


// Insert ejecuta el método POST en el servidor con el dataset dado.
procedure TCRUDService.Insert(ADataSet: TFDMemTable);
var
  lResponse: IMVCRESTResponse;
begin
  try
    ADataSet.CheckBrowseMode;
    lResponse := RESTClient.DataSetInsert(Path, ADataSet);
  except
    on E: Exception do
    begin
      ADataSet.Edit;
      raise EMVCRESTClientException.Create(E.Message);
    end;
  end;

  case lResponse.StatusCode of
    HTTP_STATUS.OK, HTTP_STATUS.Created:
    begin
      if (ADataSet.FindField(KeyName) <> nil) then
      begin
        var ID := ValueFromJSONArray(lResponse.Content, payload, KeyName, '');
        if ID <> EmptyStr then
          Select(ADataSet, ID);
      end;
    end;
    HTTP_STATUS.NoContent: Exit;
  else
    ADataSet.Edit;
    var msg := ValueFromError(lResponse.Content);
    if msg = Emptystr then
      msg := lResponse.StatusText;
    raise EInternalErrorException.Create(msg);
  end;
end;


// Select obtiene el registro con el ID especificado.
procedure TCRUDService.Select(ADataSet: TFDMemTable; const AKeyValue: string);
var
  lResponse: IMVCRESTResponse;
begin
  try
    FLoading := True;
    var rscr := Path + '/' + AKeyValue;
    lResponse :=  RESTClient.GET(Path + '/' + AKeyValue);
  except
    on E: Exception do
    begin
      FLoading := False;
      raise EMVCRESTClientException.Create(E.Message);
    end;
  end;

  case lResponse.StatusCode of
    HTTP_STATUS.OK:
      try
        FLoading := True;
        ADataSet.DisableControls;
        ADataSet.Close;
        ADataSet.Open;
        ADataSet.LoadJSONArrayFromJSONObjectProperty(payload, lResponse.Content, ncAsIs);
        ADataSet.First;
        ADataSet.CheckBrowseMode;
      finally
        ADataSet.EnableControls;
        ADataSet.ApplyUpdates();
        ADataSet.CheckBrowseMode;
        FLoading := False;
      end;
  else
    var msg := ValueFromError(lResponse.Content);
    if msg = Emptystr then
      msg := lResponse.StatusText;
    raise EInternalErrorException.Create(msg);
  end;
end;


// Select obtiene los registros paginados que coincidan con el filtro dado.
procedure TCRUDService.Select(ADataSet: TFDMemTable);
var
  lResponse: IMVCRESTResponse;
begin
  var url := Path;

  try
    FLoading := True;
    lResponse := RESTClient.GET(Format('%s', [Path]));
  except
    on E: Exception do
    begin
      FLoading := False;
      raise EMVCRESTClientException.Create(E.Message);
    end;
  end;

  case lResponse.StatusCode of
    HTTP_STATUS.OK:
      try
        FLoading := True;
        ADataSet.DisableControls;
        ADataSet.Close;
        ADataSet.Open;
        ADataSet.LoadJSONArrayFromJSONObjectProperty(payload, lResponse.Content, ncAsIs);
        ADataSet.First;
      finally
        ADataSet.EnableControls;
        FLoading := False;
      end;

    HTTP_STATUS.NotFound: begin
      // si no encontramos ningún elemento, retornamos el dataset vacio
      ADataSet.Close;
      ADataSet.Open;
    end;
  else
    var msg := ValueFromError(lResponse.Content);
    if msg = Emptystr then
      msg := lResponse.StatusText;
    raise EInternalErrorException.Create(msg);
  end;
end;


// Update ejecuta el método PUT en el servidor remoto con el dataset dado.
procedure TCRUDService.Update(ADataSet: TFDMemTable);
var
  lResponse: IMVCRESTResponse;
begin
  try
    with ADataSet do
    begin
      CheckBrowseMode;

      if (IsEmpty) then
        Exit;

      if (FindField(KeyName) = nil)  then
        raise exception.Create(SKeyNameError);

      if (FieldByName(KeyName).AsString = EmptyStr) then
        raise exception.Create(SKeyValueError);

      lResponse := RESTClient.DataSetUpdate(Path, ADataSet.FieldByName(KeyName).AsString, ADataSet);
      ApplyUpdates(-1);
      CheckBrowseMode;
    end;
  except
    on E: Exception do
    begin
      ADataSet.Edit;
      raise EMVCRESTClientException.Create(E.Message);
    end;
  end;

  case lResponse.StatusCode of
    HTTP_STATUS.OK,
    HTTP_STATUS.NoContent: begin
      if (ADataSet.FindField(KeyName) <> nil) then
      begin
        var ID := ValueFromJSONArray(lResponse.Content, payload, KeyName, '');
        if ID <> EmptyStr then
          Select(ADataSet, ID); // retornamos el registro actualizado
      end;
    end;
  else
    // volvemos a colocar el dataset en edición para fozar un nuevo guardado o la cancelación de los cambios
    ADataSet.Edit;
    var msg := ValueFromError(lResponse.Content);
    if msg = Emptystr then
      msg := lResponse.StatusText;
    raise EInternalErrorException.Create(msg);
  end;
end;


// GetAnnotedPath retorna la ruta de acceso al recurso.
function TCRUDService.GetAnnotedPath: string;
var
  lRttiType: TRttiType;
  lAttr: TCustomAttribute;
begin
  Result := EmptyStr;
  lRttiType := TType.GetType(Self.ClassType);
  for lAttr in lRttiType.GetAttributes do
    if (lAttr is ResourcePathAttribute) then
      Exit(ResourcePathAttribute(lAttr).Value);
end;




{$REGION getters / setters}
function TCRUDService.getKeyName: string;
begin
  if FKeyName = EmptyStr then
    FKeyName := default_keyname;

  Result := FKeyName;
end;


function TCRUDService.getPath: string;
begin
  if FPath.IsEmpty then
    FPath := GetAnnotedPath;

  if FPath.IsEmpty then
    raise EServiceException.Create(SResourcePathUndef);

  Result := FPath;
end;


function TCRUDService.getRESTClient: IMVCRESTClient;
begin
  if FRESTClient = nil then
    FRESTClient := TMVCRESTClient.New.BaseURL(FPrefix, FPort);

  FRESTClient.AddHeader('content-type', 'application/json');
  Result := FRESTClient;
end;


procedure TCRUDService.setKeyName(Value: string);
begin
  FKeyName := Value;
end;


procedure TCRUDService.setPath(const Value: string);
begin
  FPath := Value;
end;
{$ENDREGION}


end.

