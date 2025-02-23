unit Buyn.Attributes;

interface

type

  ResourcePathAttribute = class(TCustomAttribute)
  strict private
    FValue: string;
  public
    constructor Create(const AValue: string);
    property Value: string read FValue;
  end;

implementation

{ ResourcePathAttribute }

constructor ResourcePathAttribute.Create(const AValue: string);
begin
   FValue := AValue;
end;

end.
