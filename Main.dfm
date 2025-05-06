object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 495
  ClientWidth = 1151
  Caption = 'MainForm'
  OnShow = UniFormShow
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  OnCreate = UniFormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object htmlCamFrame: TUniHTMLFrame
    Left = 8
    Top = 8
    Width = 480
    Height = 320
    Hint = ''
    OnAjaxEvent = htmlCamFrameAjaxEvent
  end
  object btnCapture: TUniButton
    Left = 8
    Top = 368
    Width = 100
    Height = 30
    Hint = ''
    Caption = 'Capture'
    TabOrder = 1
    OnClick = btnCaptureClick
  end
  object btnStop: TUniButton
    Left = 388
    Top = 332
    Width = 100
    Height = 30
    Hint = ''
    Caption = 'Stop'
    TabOrder = 2
    OnClick = btnStopClick
  end
  object btnCaptureWithWatermark: TUniButton
    Left = 113
    Top = 368
    Width = 130
    Height = 30
    Hint = ''
    Caption = 'Capture with watermark'
    TabOrder = 4
    OnClick = btnCaptureWithWatermarkClick
  end
  object imgPreview: TUniImage
    Left = 504
    Top = 8
    Width = 640
    Height = 480
    Hint = ''
    Proportional = True
    OnAjaxEvent = imgPreviewAjaxEvent
  end
  object btnCrop: TUniButton
    Left = 388
    Top = 368
    Width = 100
    Height = 30
    Hint = ''
    Caption = 'Save selection'
    TabOrder = 5
    OnClick = btnCropClick
  end
  object btnCaptureWithSelection: TUniButton
    Left = 249
    Top = 368
    Width = 130
    Height = 30
    Hint = ''
    Caption = 'Capture with selection'
    TabOrder = 6
    OnClick = btnCaptureWithSelectionClick
  end
  object cmbWebcam: TUniComboBox
    Left = 8
    Top = 334
    Width = 371
    Height = 26
    Cursor = crHandPoint
    Hint = ''
    Style = csDropDownList
    Text = ''
    ParentFont = False
    Font.Height = -13
    TabOrder = 7
    IconItems = <>
    OnChange = cmbWebcamChange
  end
end
