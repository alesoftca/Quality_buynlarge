unit Context.Services;

interface

uses
  Spring.Container;

procedure RegisterTypes(const Container: TContainer);

implementation

uses
   Spring.Services,
   Product.Service;

procedure RegisterTypes(const Container: TContainer);
begin
  Container.RegisterType<IProductService, TProductService>;

  Container.Build;
end;

end.
