unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses, Math,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniButton, uniGUIBaseClasses,
  uniPanel, uniHTMLFrame, System.NetEncoding, uniImage, PNGImage, JPEG,
  uniMultiItem, uniComboBox;

type
  TMainForm = class(TUniForm)
    htmlCamFrame: TUniHTMLFrame;
    btnCapture: TUniButton;
    btnStop: TUniButton;
    imgPreview: TUniImage;
    btnCaptureWithWatermark: TUniButton;
    btnCrop: TUniButton;
    btnCaptureWithSelection: TUniButton;
    cmbWebcam: TUniComboBox;
    procedure UniFormShow(Sender: TObject);
    procedure btnStartCam1Click(Sender: TObject);
    procedure btnStartCam2Click(Sender: TObject);
    procedure btnCaptureClick(Sender: TObject);
    procedure htmlCamFrameAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure btnStopClick(Sender: TObject);
    procedure btnCaptureWithWatermarkClick(Sender: TObject);
    procedure imgPreviewAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure btnCropClick(Sender: TObject);
    procedure btnCaptureWithSelectionClick(Sender: TObject);
    procedure UniFormCreate(Sender: TObject);
    procedure cmbWebcamChange(Sender: TObject);
  private
    FLastCapturedFile: string;
    { Private declarations }
  public
    { Public declarations }
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, ServerModule;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.btnStartCam1Click(Sender: TObject);
begin
  UniSession.AddJS('getCameras().then(() => startCameraByIndex(0));');
end;

procedure TMainForm.btnStartCam2Click(Sender: TObject);
begin
  UniSession.AddJS('getCameras().then(() => startCameraByIndex(1));');
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  UniSession.AddJS('stopCamera();');
end;

procedure TMainForm.cmbWebcamChange(Sender: TObject);
var
  camIndex: Integer;
begin
  if cmbWebcam.ItemIndex >= 0 then
  begin
    camIndex := Integer(cmbWebcam.Items.Objects[cmbWebcam.ItemIndex]);
    UniSession.AddJS('startCameraByIndex(' + IntToStr(camIndex) + ');');
  end;
end;

procedure TMainForm.btnCaptureClick(Sender: TObject);
begin
  UniSession.AddJS('captureSnapshot();');
end;

procedure TMainForm.btnCaptureWithWatermarkClick(Sender: TObject);
begin
  UniSession.AddJS('captureSnapshotWithWatermark();');
end;

procedure TMainForm.btnCaptureWithSelectionClick(Sender: TObject);
begin
  UniSession.AddJS('captureSnapshotWithSelection();');
end;

procedure TMainForm.btnCropClick(Sender: TObject);
begin
  UniSession.AddJS(
    'let img = document.querySelector("#' + imgPreview.JSId + ' img");' +
    'if (img && img.dataset.crop) {' +
    '  let c = JSON.parse(img.dataset.crop);' +
    '  ajaxRequest(' + imgPreview.JSName + ', "getCroppedImg", [' +
    '    "cx=" + c.x, "cy=" + c.y, "cw=" + c.w, "ch=" + c.h, ' +
    '    "dw=" + c.dw, "dh=" + c.dh' +
    '  ]);' +
    '} else { alert("Crop area not defined yet."); }'
  );
end;

procedure TMainForm.imgPreviewAjaxEvent(Sender: TComponent; EventName: string; Params: TUniStrings);
var
  CX, CY, CW, CH: Integer;
  Bmp, Cropped: TBitmap;
  Png: TPngImage;
  ImgW, ImgH: Integer;
  ScaleX, ScaleY: Double;
begin
  if EventName = 'getCroppedImg' then
  begin
    CX := StrToIntDef(Params.Values['cx'], 0);
    CY := StrToIntDef(Params.Values['cy'], 0);
    CW := StrToIntDef(Params.Values['cw'], 0);
    CH := StrToIntDef(Params.Values['ch'], 0);

    if FileExists(FLastCapturedFile) then
    begin
      Png := TPngImage.Create;
      Bmp := TBitmap.Create;
      Cropped := TBitmap.Create;
      try
        Png.LoadFromFile(FLastCapturedFile);
        Bmp.Assign(Png);

        ImgW := StrToIntDef(Params.Values['dw'], 0);
        ImgH := StrToIntDef(Params.Values['dh'], 0);

        if (ImgW > 0) and (ImgH > 0) then
        begin
          ScaleX := Bmp.Width / ImgW;
          ScaleY := Bmp.Height / ImgH;

          CX := Round(CX * ScaleX);
          CY := Round(CY * ScaleY);
          CW := Round(CW * ScaleX);
          CH := Round(CH * ScaleY);
        end;

        CX := EnsureRange(CX, 0, Bmp.Width - 1);
        CY := EnsureRange(CY, 0, Bmp.Height - 1);
        CW := EnsureRange(CW, 1, Bmp.Width - CX);
        CH := EnsureRange(CH, 1, Bmp.Height - CY);

        Cropped.SetSize(CW, CH);
        Cropped.Canvas.CopyRect(Rect(0, 0, CW, CH), Bmp.Canvas, Rect(CX, CY, CX + CW, CY + CH));

        Png.Assign(Cropped);
        Png.SaveToFile(FLastCapturedFile);

        imgPreview.Url := 'files/images/' + ExtractFileName(FLastCapturedFile) + '?t=' + IntToStr(GetTickCount);
      finally
        Png.Free;
        Bmp.Free;
        Cropped.Free;
      end;
    end;
  end;
end;

procedure TMainForm.htmlCamFrameAjaxEvent(Sender: TComponent; EventName: string; Params: TUniStrings);
var
  Base64, FileName, PathImageFolder: string;
  Ext: string;
  Stream: TBytesStream;
  AddCropJS: Boolean;
  rawList: string;
  listParts: TStrings;
  i: Integer;
  parts: TStrings;
  labelText: string;
  camIndex: Integer;
begin
  if EventName = 'cam_list' then
  begin
    cmbWebcam.Items.Clear;
    cmbWebcam.Text := '';

    rawList := Params.Values['list'];

    listParts := TStringList.Create;
    parts := TStringList.Create;
    try
      listParts.Delimiter := ',';
      listParts.StrictDelimiter := True;
      listParts.DelimitedText := rawList;

      for i := 0 to listParts.Count - 1 do
      begin
        parts.Delimiter := '|';
        parts.StrictDelimiter := True;
        parts.DelimitedText := listParts[i];

        if parts.Count = 2 then
        begin
          labelText := TNetEncoding.URL.Decode(parts[0]);
          camIndex := StrToIntDef(parts[1], 0);
          cmbWebcam.Items.AddObject(labelText, TObject(camIndex));
        end;
      end;

      if cmbWebcam.Items.Count > 0 then
      begin
        cmbWebcam.ItemIndex := 0;
        cmbWebcamChange(nil);
      end;
    finally
      listParts.Free;
      parts.Free;
    end;
  end;

  AddCropJS := (EventName = 'camera_getimage_with_crop');

  if (EventName = 'camera_getimage') or AddCropJS then
  begin
    Base64 := TNetEncoding.URL.Decode(Params.Values['content']);

    if Pos('image/png', Base64) > 0 then
    begin
      Base64 := StringReplace(Base64, 'data:image/png;base64,', '', [rfReplaceAll]);
      Ext := '.png';
    end
    else if Pos('image/jpeg', Base64) > 0 then
    begin
      Base64 := StringReplace(Base64, 'data:image/jpeg;base64,', '', [rfReplaceAll]);
      Ext := '.jpg';
    end
    else
      Exit;

    Stream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(Base64));
    try
      PathImageFolder := UniServerModule.FilesFolderPath + 'images\';
      if not DirectoryExists(PathImageFolder) then
        ForceDirectories(PathImageFolder);

      FileName := PathImageFolder + FormatDateTime('yyyymmdd_hhnnss', Now) + Ext;
      Stream.SaveToFile(FileName);
    finally
      Stream.Free;
    end;

    FLastCapturedFile := FileName;
    imgPreview.Url := 'files/images/' + ExtractFileName(FileName) + '?t=' + IntToStr(GetTickCount);

    if AddCropJS then
    begin
      UniSession.AddJS(
        'setTimeout(function(){' +
        ' let img = document.querySelector("#' + imgPreview.JSId + ' img");' +
        ' if (!img) return;' +
        ' if ($(img).data("Jcrop")) { $(img).data("Jcrop").destroy(); }' +
        ' let iw = img.naturalWidth || img.width;' +
        ' let ih = img.naturalHeight || img.height;' +
        ' let selW = Math.min(240, iw);' +
        ' let selH = selW * 4 / 3;' +
        ' let x1 = (iw - selW) / 2;' +
        ' let y1 = (ih - selH) / 2;' +
        ' let x2 = x1 + selW;' +
        ' let y2 = y1 + selH;' +
        ' $(img).Jcrop({' +
//        '   aspectRatio: 3 / 4,' + // Uncomment if you want aspect ratio
        '   trueSize: [iw, ih],' +
        '   setSelect: [x1, y1, x2, y2],' +
        '   allowResize: true,' +
        '   allowSelect: false,' +
        '   onSelect: function(c) {' +
        '     img.dataset.crop = JSON.stringify({' +
        '       x: Math.round(c.x),' +
        '       y: Math.round(c.y),' +
        '       w: Math.round(c.w),' +
        '       h: Math.round(c.h),' +
        '       dw: img.width,' +
        '       dh: img.height' +
        '     });' +
        '   }' +
        ' });' +
        '}, 300);'
      );
    end;
  end;
end;

procedure TMainForm.UniFormCreate(Sender: TObject);
begin
  cmbWebcam.ClientEvents.ExtEvents.Values['afterrender'] :=
    'function(sender, eOpts){ajaxRequest(sender, "afterrender", []);}';

  imgPreview.ClientEvents.UniEvents.Values['beforeInit'] :=
    'function(sender, config) {' +
    '  sender.updatePreview = function(c) {' +
    '    if (parseInt(c.w) > 0) {' +
    '      ajaxRequest(sender, "getCroppedImg", [' +
    '        "cx=" + c.x, "cy=" + c.y, "cw=" + c.w, "ch=" + c.h' +
    '      ]);' +
    '    }' +
    '  };' +
    '}';
end;

procedure TMainForm.UniFormShow(Sender: TObject);
begin
  htmlCamFrame.HTML.Text :=
    '<video id="video" autoplay playsinline width="480" height="360" style="border:1px solid #ccc;"></video><br>' +
    '<canvas id="canvas" width="480" height="360" style="display:none;"></canvas>' +
    '<script>' +
    'window.videoDevices = [];' +
    'window.currentStream = null;' +

    'window.getCameras = async function () {' +
    '  const devices = await navigator.mediaDevices.enumerateDevices();' +
    '  window.videoDevices = devices.filter(device => device.kind === "videoinput");' +
    '};' +

    'window.startCameraByIndex = async function (index) {' +
    '  await window.getCameras();' +
    '  if (index >= window.videoDevices.length) return;' +
    '  if (window.currentStream) window.currentStream.getTracks().forEach(track => track.stop());' +

    '  const deviceId = window.videoDevices[index].deviceId;' +
    '  let constraints = { video: { deviceId: { ideal: deviceId } } };' +

    '  try {' +
    '    window.currentStream = await navigator.mediaDevices.getUserMedia(constraints);' +
    '    document.getElementById("video").srcObject = window.currentStream;' +
    '  } catch (err) {' +
    '    console.warn("Primary camera access failed:", err.name);' +
    '    try {' +
    '      window.currentStream = await navigator.mediaDevices.getUserMedia({ video: true });' +
    '      document.getElementById("video").srcObject = window.currentStream;' +
    '    } catch (fallbackErr) {' +
    '      console.error("Fallback also failed:", fallbackErr.name, fallbackErr.message);' +
    '      alert("Camera error: " + fallbackErr.name + ": " + fallbackErr.message);' +
    '    }' +
    '  }' +
    '};' +

    'window.stopCamera = function () {' +
    '  if (window.currentStream) {' +
    '    window.currentStream.getTracks().forEach(track => track.stop());' +
    '    window.currentStream = null;' +
    '    document.getElementById("video").srcObject = null;' +
    '  }' +
    '};' +

    'window.captureSnapshot = function () {' +
    '  const video = document.getElementById("video");' +
    '  const canvas = document.getElementById("canvas");' +
    '  canvas.width = video.videoWidth;' +
    '  canvas.height = video.videoHeight;' +
    '  const ctx = canvas.getContext("2d");' +
    '  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);' +
    '  const dataURL = canvas.toDataURL("image/png");' +
    '  ajaxRequest(' + htmlCamFrame.JSName + ', "camera_getimage", ["content=" + encodeURIComponent(dataURL)]);' +
    '};' +

    'window.captureSnapshotWithWatermark = function () {' +
    '  const video = document.getElementById("video");' +
    '  const canvas = document.getElementById("canvas");' +
    '  canvas.width = video.videoWidth;' +
    '  canvas.height = video.videoHeight;' +
    '  const ctx = canvas.getContext("2d");' +
    '  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);' +

    // Watermark
    '  const text = "WATERMARK";' +
    '  ctx.font = "bold 48px Arial";' +
    '  ctx.textAlign = "center";' +
    '  ctx.textBaseline = "middle";' +
    '  const x = canvas.width / 2;' +
    '  const y = canvas.height / 2;' +

    '  const metrics = ctx.measureText(text);' +
    '  const paddingX = 30;' +
    '  const paddingY = 20;' +
    '  const boxWidth = metrics.width + paddingX * 2;' +
    '  const boxHeight = 48 + paddingY * 2;' +

    '  ctx.fillStyle = "rgba(255, 255, 255, 0.5)";' +
    '  ctx.fillRect(x - boxWidth / 2, y - boxHeight / 2, boxWidth, boxHeight);' +

    '  ctx.fillStyle = "rgba(0, 0, 0, 0.6)";' +
    '  ctx.fillText(text, x, y);' +

    '  const dataURL = canvas.toDataURL("image/png");' +
    '  ajaxRequest(' + htmlCamFrame.JSName + ', "camera_getimage", ["content=" + encodeURIComponent(dataURL)]);' +
    '};' +

    'window.captureSnapshotWithSelection = function () {' +
    '  const video = document.getElementById("video");' +
    '  const canvas = document.getElementById("canvas");' +
    '  canvas.width = video.videoWidth;' +
    '  canvas.height = video.videoHeight;' +
    '  const ctx = canvas.getContext("2d");' +
    '  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);' +
    '  const dataURL = canvas.toDataURL("image/png");' +
    '  ajaxRequest(' + htmlCamFrame.JSName + ', "camera_getimage_with_crop", ["content=" + encodeURIComponent(dataURL)]);' +
    '};' +
    '</script>';

  UniSession.AddJS(
    'navigator.mediaDevices.enumerateDevices().then(function(devices) {' +
    '  var cams = devices.filter(function(d) { return d.kind === "videoinput"; });' +
    '  var names = cams.map(function(c, i) {' +
    '    return encodeURIComponent(c.label || "Camera " + (i + 1)) + "|" + i;' +
    '  });' +
    '  ajaxRequest(' + htmlCamFrame.JSName + ', "cam_list", ["list=" + names.join(",")]);' +
    '});'
  );
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
