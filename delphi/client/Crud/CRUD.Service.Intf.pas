unit CRUD.Service.Intf;

interface

uses
  System.SysUtils,
  System.Variants,
  System.JSON,
  System.Rtti,
  System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Spring.Collections,
  MVCFramework.Commons,
  MVCFramework.Serializer.Commons,
  MVCFramework.Serializer.Intf,
  MVCFramework.RESTClient,
  MVCFramework.RESTClient.Intf,
  MVCFramework.RESTClient.Commons;

type


  ICRUDService = interface(IInvokable)
  ['{0CE0DA8F-CA2E-4D55-85FC-88E6003431C7}']
    function GetAnnotedPath: string;
    procedure Delete(const Id: string);
    procedure Insert(ADataSet: TFDMemTable);
    procedure Select(ADataSet: TFDMemTable); overload;
    procedure Select(ADataSet: TFDMemTable; const AKeyValue: string); overload;
    procedure Update(ADataSet: TFDMemTable);
  end;

implementation

end.
