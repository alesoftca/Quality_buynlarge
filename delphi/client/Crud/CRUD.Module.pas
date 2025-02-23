unit CRUD.Module;

interface

uses
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, JvDataSource,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Comp.UI,
  CRUD.Service.Impl,
  CRUD.Service.Intf;

type

  TCrudDM = class(TDataModule)
    GUIWaitCursor: TFDGUIxWaitCursor;
    Searches: TFDMemTable;
    SearchesSource: TJvDataSource;
    procedure DataModuleCreate(Sender: TObject);
  strict private
    FService: ICRUDService;
    FKeyName: string;
  strict protected
    function getCurrentID: string;
    function getSearchID: string;
    function getEntity: TFDMemTable; virtual; abstract;
    function getService: ICRUDService; virtual; abstract;
  public
    property CurrentID: string read getCurrentID;
    property SearchID: string read getSearchID;
    property Entity: TFDMemTable read getEntity;
    function HasChanges: Boolean;
    property Service: ICRUDService read getService;
    procedure AppendRecord; virtual;
    procedure EditFromSearch; virtual;
    procedure EditRecord(KeyValue: string); virtual;
    procedure DeleteRecord; overload; virtual;
    procedure RefreshRecord; virtual;
    procedure SaveRecord; virtual;
    procedure SelectAll; virtual;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  System.UITypes,
  FMX.Dialogs,
  Buyn.Exceptions;

const
  IDKey = 'ID';


procedure TCrudDM.DataModuleCreate(Sender: TObject);
begin
  inherited;

  FService := getService;
end;


// HasChanges retorna true si existen cambios sin aplicar en la entidad.
function TCrudDM.HasChanges: Boolean;
begin
  Result := Assigned(Entity) and Entity.Active and (Entity.ChangeCount > 0);
end;


{$REGION 'Métodos CRUD'}
// AppendRecord prepara el dataset maestro para agregar un nuevo registro
procedure TCrudDM.AppendRecord;
begin
  if not Assigned(Entity) then
    raise Exception.Create(SUnprocessable);

  Entity.Active := True;
  Entity.CancelUpdates;
  Entity.Append;
end;


// DeleteRecord elimina el registro actual.
procedure TCrudDM.DeleteRecord;
begin
  if not Assigned(Entity) then
    raise Exception.Create(SUnprocessable);

  if CurrentID = EmptyStr then
  begin
    Entity.CancelUpdates;
    Exit;
  end;

  Service.Delete(CurrentID);
end;


// EditFromSearch carga el registro activo actualmente en el dataset de busquedas.
procedure TCrudDM.EditFromSearch;
begin
  if Searches.Active and (not Searches.IsEmpty) then
  begin
    var lID := Searches.FieldByName('ID').Value;
    EditRecord(Searches.FieldByName('ID').Value);
  end;
end;


// EditRecord carga un registro y lo prepara para la edición.
procedure TCrudDM.EditRecord(KeyValue: string);
var
  Msg: string;
begin
  if not Assigned(Entity) then
    raise Exception.Create(SUnprocessable);

  Service.Select(Entity, KeyValue);
end;


// RefreshRecord refresca el registro actual.
procedure TCrudDM.RefreshRecord;
begin
  if not Assigned(Entity) then
    raise Exception.Create(SUnprocessable);

  Entity.CancelUpdates;
  Service.Select(Entity, CurrentID);
end;


// SaveRecord aplica los cambios efectuados a un registro.
procedure TCrudDM.SaveRecord;
begin
  if (Entity.State = dsInsert) or (CurrentID = EmptyStr) then
    Service.Insert(Entity)
  else
    Service.Update(Entity);
end;

procedure TCrudDM.SelectAll;
begin
  Service.Select(Searches);

  if Entity.Active and (Entity.FieldByName('ID').AsString <> EmptyStr) then
    Searches.Locate('ID', Entity.FieldByName('ID').AsString, []);
end;
{$ENDREGION}


{$REGION 'getters/setters'}
// getCurrentID retorna el ID de la entidad actual.
function TCrudDM.getCurrentID: string;
begin
  Result := EmptyStr;

  if Assigned(Entity) and (not Entity.IsEmpty) and (Entity.FindField(IDKey) <> nil) then
    Result := Entity.FieldByName(IDKey).AsString;
end;


// getSearchID retorna el ID activo en los resultados del listado.
function TCrudDM.getSearchID: string;
begin
  Result := EmptyStr;

  if (not Searches.IsEmpty) and (Searches.FindField(IDKey) <> nil) then
    Result := Searches.FieldByName(IDKey).AsString;
end;
{$ENDREGION}


end.
