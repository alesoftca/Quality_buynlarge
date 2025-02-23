unit Context.Modules;

interface

uses
  Spring.Container;

procedure RegisterTypes(const Container: TContainer);

implementation

uses
  Product.Module;


procedure RegisterTypes(const Container: TContainer);
begin
  Container.RegisterType<TProductDM, TProductDM>;

  Container.Build;
end;

end.
