program buynlarge_client;

uses
  Spring.Container,
  Spring.Services,
  System.StartUpCopy,
  FMX.Forms,
  Main.Form in 'Main\Main.Form.pas' {MainForm},
  CRUD.Module in 'Crud\CRUD.Module.pas' {CrudDM: TDataModule},
  CRUD.Service.Intf in 'Crud\CRUD.Service.Intf.pas',
  CRUD.Service.Impl in 'Crud\CRUD.Service.Impl.pas',
  WebConfig in 'WebConfig.pas',
  Buyn.Exceptions in 'Buyn\Buyn.Exceptions.pas',
  Buyn.Utils in 'Buyn\Buyn.Utils.pas',
  Buyn.Attributes in 'Buyn\Buyn.Attributes.pas',
  Context.Modules in 'Context\Context.Modules.pas',
  Context.Services in 'Context\Context.Services.pas',
  Product.Service in 'Product\Product.Service.pas',
  Product.Module in 'Product\Product.Module.pas' {ProductDM: TDataModule},
  Chat.Frame in 'ChatFrame\Chat.Frame.pas' {ChatFrame: TFrame};

{$R *.res}

begin
  Context.Services.RegisterTypes(GlobalContainer);
  Context.Modules.RegisterTypes(GlobalContainer);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
