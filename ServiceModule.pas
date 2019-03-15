unit ServiceModule;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  SysTray;

type
  TBellService = class(TService)
    SysTrayIcon1: TSysTrayIcon;
    procedure SysTrayIcon1LeftDblClick(Sender: TSysTrayIcon; X, Y: Word);
    procedure SysTrayIcon1RightClick(Sender: TSysTrayIcon; X, Y: Word);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  BellService: TBellService;

implementation

{$R *.DFM}

uses MainForm;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  BellService.Controller(CtrlCode);
end;

function TBellService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TBellService.SysTrayIcon1LeftDblClick(Sender: TSysTrayIcon; X,
  Y: Word);
begin
  BellSchedule.ShowForm;
end;

procedure TBellService.SysTrayIcon1RightClick(Sender: TSysTrayIcon; X,
  Y: Word);
begin
  with BellSchedule do
    begin
      SetForegroundWindow(Handle);
      PopupMenu1.Popup(X, Y);
      PostMessage(Handle, WM_NULL, 0, 0);
    end;
end;

end.
