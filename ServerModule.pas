unit ServerModule;

interface

uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication, uIdCustomHTTPServer,
  uniGUITypes;

type
  TUniServerModule = class(TUniGUIServerModule)
    procedure UniGUIServerModuleCreate(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars;

function UniServerModule: TUniServerModule;
begin
  Result := TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;

procedure TUniServerModule.UniGUIServerModuleCreate(Sender: TObject);
begin
  // Adding JCrop lib
  CustomFiles.Add('files/jquery.Jcrop.min.js');
  CustomFiles.Add('files/jquery.Jcrop.min.css');
  CustomFiles.Add('files/jquery.color.js');

{$IFDEF RELEASE}
  ExtRoot := '.\[ext]\';
  UniRoot := '.\[uni]\';
{$ENDIF}
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.
