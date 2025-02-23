inherited ProductDM: TProductDM
  OnDestroy = DataModuleDestroy
  PixelsPerInch = 120
  inherited Searches: TFDMemTable
    StoreDefs = True
    object SearchesID: TIntegerField
      FieldName = 'ID'
    end
    object SearchesNombre: TStringField
      FieldName = 'Nombre'
      Size = 100
    end
    object SearchesMarca: TStringField
      FieldName = 'Marca'
      Size = 50
    end
    object SearchesPrecio: TFloatField
      FieldName = 'Precio'
    end
  end
  object Product: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 52
    Top = 176
    object ProductID: TIntegerField
      FieldName = 'ID'
    end
    object ProductNombre: TStringField
      FieldName = 'Nombre'
      Size = 100
    end
    object ProductMarcar: TStringField
      FieldName = 'Marca'
      Size = 50
    end
    object ProductDescripcion: TMemoField
      FieldName = 'Descripcion'
      BlobType = ftMemo
    end
    object ProductPrecio: TFloatField
      FieldName = 'Precio'
    end
    object ProductStock: TIntegerField
      FieldName = 'Stock'
    end
    object ProductCategoria: TStringField
      FieldName = 'Categoria'
      Size = 50
    end
  end
  object ProductSource: TJvDataSource
    DataSet = Product
    Left = 154
    Top = 176
  end
end
