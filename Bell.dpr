program Bell;

uses
  Forms,
  MainForm in 'MainForm.pas' {BellSchedule},
  AddEventForm in 'AddEventForm.pas' {EventAdder},
  PortAccess in 'PortAccess.pas',
  ElapseForm in 'ElapseForm.pas' {Lapse},
  SysTray in 'SysTray.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TBellSchedule, BellSchedule);
  Application.Run;
end.
