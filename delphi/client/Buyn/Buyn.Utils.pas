unit Buyn.Utils;

interface

uses
  System.SysUtils, Data.DB;

function ValueFromError(const AContent: string): string;
function ValueFromJSON(const AContent, APropName, AKeyName, DefaultValue: string): string;
function ValueFromJSONArray(const AContent: string; APropName, AKeyName, DefaultValue: string): string;

implementation

uses
  System.JSON,
  System.Variants,
  MVCFramework.SystemJSONUtils;


// ValueFromError - retorna el mensaje de error de la clave 'message'
function ValueFromError(const AContent: string): string;
var
  JSONObject: TJSONObject;
  PostsArray: TJSONObject;
  PostsError: TJSONObject;
begin
  Result := EmptyStr;
  JSONObject := TJSONObject.ParseJSONValue(AContent) as TJSONObject;
  try
    if Assigned(JSONObject) then
    begin
      // Obtener el array de APropName
      PostsArray := JSONObject.GetValue<TJSONObject>('meta');
      PostsError := PostsArray.GetValue<TJSONObject>('error');
      if Assigned(PostsError) and (PostsError.Count > 0) then
      begin
        Result := PostsError.GetValue<string>('message');
        Result := Result;
      end;
    end;
  finally
    JSONObject.Free;
  end;
end;


// ValueFromJSON - retorna el valor de la clave AKeyName desde una cadena en formato JSON
function ValueFromJSON(const AContent, APropName, AKeyName, DefaultValue: string): string;
var
  jsv: TJsonValue;
  jso: TJsonObject;
  jsp: TJsonPair;
begin
  Result := EmptyStr;

  if APropName <> EmptyStr then
    try
      try
        jso := TJSONObject.ParseJSONValue(AContent) as TJSONObject;
        if APropName <> EmptyStr then
          jsv := jso.GetValue(APropName).FindValue(AKeyName)
        else
          jsv := jso.FindValue(AKeyName);

        if jsv <> nil then
          Result := jsv.Value
        else
          for jsp in jso do
            if (jsp.JsonString.Value = AKeyName) then
            begin
               Result := jsp.JsonValue.Value;
               Break;
            end;
      except
        Result := DefaultValue;
      end;
    finally
      if Assigned(jso) then
      begin
        FreeandNil(jso);
        jsp := nil;
        jsv := nil;
      end;
    end
  else

  Result := Result;
end;


// ValueFromJSONArray - retorna el valor de la clave AKeyName desde un nodo array
function ValueFromJSONArray(const AContent: string; APropName, AKeyName, DefaultValue: string): string;
var
  JSONObject: TJSONObject;
  PostsArray: TJSONArray;
begin
  Result := DefaultValue;
  JSONObject := TJSONObject.ParseJSONValue(AContent) as TJSONObject;
  try
    if Assigned(JSONObject) then
    begin
      // Obtener el array de APropName
      PostsArray := JSONObject.GetValue<TJSONArray>(APropName);
      if Assigned(PostsArray) and (PostsArray.Count > 0) then
      begin
        Result := PostsArray.Items[0].GetValue<string>(AKeyName);
      end;
    end;
  finally
    JSONObject.Free;
  end;
end;

var
   fmtSettings: TFormatSettings;

initialization

   fmtSettings := TFormatSettings.Create;
   fmtSettings.DateSeparator := '/';
   fmtSettings.DecimalSeparator := '.';
   fmtSettings.ThousandSeparator := ',';
   System.SysUtils.FormatSettings := fmtSettings;

end.
