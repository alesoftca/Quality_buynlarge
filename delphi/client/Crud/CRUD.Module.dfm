object CrudDM: TCrudDM
  OnCreate = DataModuleCreate
  Height = 283
  Width = 460
  PixelsPerInch = 120
  object GUIWaitCursor: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 51
    Top = 16
  end
  object Searches: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 52
    Top = 92
  end
  object SearchesSource: TJvDataSource
    DataSet = Searches
    Left = 154
    Top = 92
  end
end
