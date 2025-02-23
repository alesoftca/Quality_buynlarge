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


  SKeyNameError           = 'El nombre del campo clave es inv�lido';
  SKeyValueError          = 'El valor del campo clave es inv�lido';
  SResourcePathUndef      = 'No se ha especificado el recurso a acceder.';
  SUnprocessable          = 'Improcesable';



implementation


end.
