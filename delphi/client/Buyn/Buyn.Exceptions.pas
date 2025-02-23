unit Buyn.Exceptions;

interface

uses
    System.SysUtils;

type
   ENoContentException = class(Exception);
   ENotFoundException = class(Exception);
   ENotAutorizedException = class(Exception);
   EInternalErrorException = class(Exception);
   EBadRequestException = class(Exception);
   EOutMemory = class(Exception);
   EServiceException = class(Exception);
   EValidationException = class(Exception);

resourcestring


  SKeyNameError           = 'El nombre del campo clave es inválido';
  SKeyValueError          = 'El valor del campo clave es inválido';
  SResourcePathUndef      = 'No se ha especificado el recurso a acceder.';
  SUnprocessable          = 'Improcesable';



implementation


end.
