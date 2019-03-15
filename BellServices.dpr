program BellServices;

uses
  SvcMgr,
  ServiceModule in 'ServiceModule.pas' {BellService: TService},
  MainForm in 'MainForm.pas' {BellSchedule},
  AddEventForm in 'AddEventForm.pas' {EventAdder},
  ElapseForm in 'ElapseForm.pas' {Lapse};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'ATTime';
  Application.CreateForm(TBellService, BellService);
  Application.CreateForm(TBellSchedule, BellSchedule);
  Application.Run;
end.
