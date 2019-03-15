unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Registry, Menus, Buttons, SysTray, ToolWin,
  ImgList;

type
  TCheckBoxList = array[1..7] of TCheckBox;
  TBellSchedule =
    class(TForm)
      GroupBox1: TGroupBox;
      CheckBox1: TCheckBox;
      CheckBox2: TCheckBox;
      CheckBox3: TCheckBox;
      CheckBox4: TCheckBox;
      CheckBox5: TCheckBox;
      CheckBox6: TCheckBox;
      CheckBox7: TCheckBox;
      GroupBox2: TGroupBox;
      ListBox1: TListBox;
      Timer1: TTimer;
      PopupMenu1: TPopupMenu;
      AjustarHora: TMenuItem;
      Close1: TMenuItem;
      StatusBar1: TStatusBar;
      ImageList1: TImageList;
      Panel1: TPanel;
      Panel2: TPanel;
      Panel3: TPanel;
      ToolBar1: TToolBar;
      ToolButton1: TToolButton;
      ToolButton2: TToolButton;
      ToolButton3: TToolButton;
      ToolButton4: TToolButton;
      PopupMenu2: TPopupMenu;
      Addringevent1: TMenuItem;
      PopupMenu3: TPopupMenu;
      Editringevent1: TMenuItem;
      Deleteringevent1: TMenuItem;
      procedure Button1Click(Sender: TObject);
      procedure ListBox1Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure Timer1Timer(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure CheckBox1Click(Sender: TObject);
      procedure HideFormItemClick(Sender: TObject);
      procedure ShowWindowItemClick(Sender: TObject);
      procedure Close1Click(Sender: TObject);
      procedure ToolButton1Click(Sender: TObject);
      procedure ToolButton4Click(Sender: TObject);
      procedure ListBox1DblClick(Sender: TObject);
      procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    private
      CheckBoxList: TCheckBoxList;
      FIniFile: TRegIniFile;
      RingCount: word;
      fRinging: boolean;
      FRingTime: integer;
      procedure BeginRinging;
      procedure EndRinging;
      procedure SetRinging(const Value: boolean);
      procedure RegisterAllRingEvents;
      procedure RegisterRingElapse(const Value: integer);
      procedure RegisterRingEvent(const Index: integer; const TheTime: TDateTime);
      procedure RegisterDay(const Name: string; const Value: boolean);
      procedure RetrieveDays;
      function RetrieveRingElapse: integer;
      procedure RetrieveRingEvents;
      procedure ChangeIcon(const Index: integer);
      procedure SetRingTime(const Value: integer);
    public
      procedure ShowForm;
      procedure HideForm;
      procedure CleanUpKeys;
      procedure OutPort(const Data: byte);
      property Ringing: boolean read fRinging write SetRinging;
      property RingTime: integer read FRingTime write SetRingTime;
  end;

var
  BellSchedule: TBellSchedule;

implementation

{$R *.DFM}

  uses AddEventForm, ElapseForm, WinUtils, PortAccess, ServiceModule;

  const
    TIMESECTION   = 'Time';
    DATESECTION   = 'Date';
    ELAPSESECTION = 'Ring Elapse';

  procedure TBellSchedule.OutPort(const Data: byte);
    var
      PortLPT: TPortLPT;
    begin
      PortLPT := TPortLPT.Create;
      if PortLPT.Open
        then
          begin
           PortLPT.Write(chr(Data));
           PortLPT.Close;
          end
	else MessageDlg( 'Can not open parallel port', mtWarning, [mbAbort, mbRetry], 0) ;
      PortLPT.Free;
    end;

  procedure TBellSchedule.BeginRinging;
    begin
      //OutPort($FF);
      ChangeIcon(4);
    end;

  procedure TBellSchedule.EndRinging;
    begin
      //OutPort($00);
      ChangeIcon(0);
      RingCount := 0;
    end;

  procedure TBellSchedule.ChangeIcon(const Index: integer);
    var
      Image: TIcon;
    begin
      Image := TIcon.Create;
      try
        ImageList1.GetIcon(Index, Image);
        BellService.SysTrayIcon1.Icon := Image;
      finally
        Image.free;
      end
    end;

  procedure TBellSchedule.SetRinging(const Value: boolean);
    begin
      fRinging := Value;
      if Ringing
        then BeginRinging
        else EndRinging;
    end;

  procedure TBellSchedule.Button1Click(Sender: TObject);
    var
      EventAdder: TEventAdder;
    begin
      EventAdder := TEventAdder.Create(Self);
      try
        if ListBox1.ItemIndex = -1
          then EventAdder.StartTime := Time
          else EventAdder.StartTime := StrToTime(ListBox1.Items[ListBox1.ItemIndex]);
        EventAdder.ShowModal;
        if EventAdder.ModalResult = mrOk
          then
            begin
              ListBox1.Items.Add(TimeToStr(EventAdder.DateTimePicker1.Time));
              RegisterRingEvent(ListBox1.Items.Count, EventAdder.DateTimePicker1.Time);
            end;
      finally
        EventAdder.free;
      end;
    end;

  procedure TBellSchedule.ListBox1Click(Sender: TObject);
    begin
      if ListBox1.ItemIndex <> -1
        then ToolButton3.Enabled := true
        else ToolButton3.Enabled := false;
    end;

  procedure TBellSchedule.Button2Click(Sender: TObject);
    begin
      ListBox1.Items.Delete(ListBox1.ItemIndex);
      RegisterAllRingEvents;
      ToolButton3.Enabled := false;
    end;

  procedure TBellSchedule.Timer1Timer(Sender: TObject);
    var
      Day: integer;
      Hour, Min, Sec, MSec: Word;
      anHour, aMin, aSec, aMSec: Word;
      i: integer;
      Done: boolean;
    begin
      StatusBar1.Panels[0].Text := TimeToStr(Time);
      if Ringing
        then inc(RingCount);
      if RingCount = RingTime
        then Ringing := false;
      Day := DayOfWeek(Date);
      StatusBar1.Panels[1].Text := DateToStr(Date);
      if CheckBoxList[Day].Checked
        then
          begin
            DecodeTime(Time, Hour, Min, Sec, MSec);
            i := 0;
            Done := false;
            while (i < ListBox1.Items.Count) and not Done do
              begin
                DecodeTime(StrToTime(ListBox1.Items[i]), anHour, aMin, aSec, aMSec);
	        if (anHour = Hour) and (aMin = Min) and (aSec = Sec)
                  then
                    begin
                      Ringing := true;
                      Done := true;
                    end
                  else inc(i);
              end;
          end;
    end;

  procedure TBellSchedule.RegisterRingEvent(const Index: integer; const TheTime: TDateTime);
    begin
      FIniFile.WriteString(TIMESECTION, 'Time' + IntToStr(Index), TimeToStr(TheTime));
    end;

  procedure TBellSchedule.RegisterAllRingEvents;
    var
      i: integer;
    begin
      FIniFile.EraseSection(TIMESECTION);
      for i := 0 to pred(ListBox1.Items.Count) do
        RegisterRingEvent(succ(i), StrToTime(ListBox1.Items[i]));
    end;

  procedure TBellSchedule.RetrieveRingEvents;
    var
      Str: string;
      i: integer;
    begin
      ListBox1.Items.Clear;
      i := 0;
      repeat
        inc(i);
        Str := FIniFile.ReadString(TIMESECTION, 'Time' + IntToStr(i), 'End of List');
        if Str <> 'End of List'
          then ListBox1.Items.Add(Str);
      until Str = 'End of List';
    end;

  procedure TBellSchedule.RetrieveDays;
    var
      i: integer;
    begin
      for i := 1 to 7 do
        CheckBoxList[i].Checked := FIniFile.ReadBool(DATESECTION, CheckBoxList[i].Caption, false);
    end;

  procedure TBellSchedule.CleanUpKeys;
    var
      Cleanup: TRegistry;
      key: string;
    begin
      key := FIniFile.FileName;
      FIniFile.Free;
      // make sure we don't leave junk in the registry behind.
      Cleanup := TRegistry.Create;
      try
        Cleanup.DeleteKey(key);
      finally
        Cleanup.Free;
      end;
    end;

  procedure TBellSchedule.FormCreate(Sender: TObject);
    begin
      CheckBoxList[1] := CheckBox7;
      CheckBoxList[2] := CheckBox1;
      CheckBoxList[3] := CheckBox2;
      CheckBoxList[4] := CheckBox3;
      CheckBoxList[5] := CheckBox4;
      CheckBoxList[6] := CheckBox5;
      CheckBoxList[7] := CheckBox6;
      Timer1.Interval := 1000;
      StatusBar1.Panels[0].Alignment := taCenter;
      ShortDateFormat := 'dddd, mmmm d, yyyy';
      LongTimeFormat := 'hh:mm:ss AM/PM';
      EndRinging;
      FIniFile := TRegIniFile.Create;
      FIniFile.RootKey := HKEY_LOCAL_MACHINE;
      FIniFile.OpenKey('SOFTWARE', FALSE);
      FIniFile.OpenKey('Daneloth Production', true);
      FIniFile.OpenKey('AutoBell', true);
      RetrieveRingEvents;
      RetrieveDays;
      fRingTime := RetrieveRingElapse;
      Application.HintShortPause := 250;
      RingCount := 0;
    end;

  procedure TBellSchedule.FormDestroy(Sender: TObject);
    begin
      EndRinging;
    end;

  procedure TBellSchedule.CheckBox1Click(Sender: TObject);
    begin
      with TCheckBox(Sender) do
        RegisterDay(Caption, Checked);
    end;

  procedure TBellSchedule.HideForm;
    begin
      HideWindow( Application.Handle );
      HideWindow( Handle );
      Visible := false;
    end;

  procedure TBellSchedule.ShowForm;
    begin
      ActivateWindow( Application.Handle );
      ActivateWindow( Handle );
      Visible := true;
    end;

  procedure TBellSchedule.HideFormItemClick(Sender: TObject);
    begin
      HideForm;
    end;

  procedure TBellSchedule.ShowWindowItemClick(Sender: TObject);
    begin
      ShowForm;
    end;

  procedure TBellSchedule.Close1Click(Sender: TObject);
    begin
      Application.Terminate;
    end;

  procedure TBellSchedule.RegisterDay(const Name: string; const Value: boolean);
    begin
      FIniFile.WriteBool(DATESECTION, Name, Value);
    end;

  procedure TBellSchedule.ToolButton1Click(Sender: TObject);
    begin
      Ringing := true;
    end;

  procedure TBellSchedule.ToolButton4Click(Sender: TObject);
    var
      Lapse: TLapse;
    begin
      Lapse := TLapse.Create(Self);
      try
        Lapse.SpinEdit1.Value := RingTime;
        if Lapse.ShowModal = mrOk
          then RingTime := Lapse.SpinEdit1.Value;
      finally
        Lapse.free;
      end;
    end;

  procedure TBellSchedule.RegisterRingElapse(const Value: integer);
    begin
      FIniFile.WriteInteger(ELAPSESECTION, 'Time', Value);
    end;

  function TBellSchedule.RetrieveRingElapse: integer;
    begin
      Result := FIniFile.ReadInteger(ELAPSESECTION, 'Time', 5);
    end;

  procedure TBellSchedule.SetRingTime(const Value: integer);
    begin
      if RingTime <> Value
        then
          begin
            FRingTime := Value;
            RegisterRingElapse(RingTime);
          end;
    end;

  procedure TBellSchedule.ListBox1DblClick(Sender: TObject);
    var
      EventAdder: TEventAdder;
    begin
      if ListBox1.ItemIndex <> -1
        then
          begin
            EventAdder := TEventAdder.Create(Self);
            try
              EventAdder.StartTime := StrToTime(ListBox1.Items[ListBox1.ItemIndex]);
              EventAdder.ShowModal;
              if EventAdder.ModalResult = mrOk
                then
                  begin
                    ListBox1.Items[ListBox1.ItemIndex] := TimeToStr(EventAdder.DateTimePicker1.Time);
                    RegisterAllRingEvents;
                  end;
            finally
              EventAdder.free;
            end;
          end;
    end;

  procedure TBellSchedule.ListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    var
      P: TPoint;
      index: integer;
    begin
      if Button = mbRight
        then
          begin
            index := ListBox1.ItemAtPos(Point(X, Y), true);
            P := ListBox1.ClientToScreen(Point(X, Y));
            if Index = -1
              then PopupMenu2.PopUp(P.X, P.Y)
              else
                begin
                  ListBox1.ItemIndex := index;
                  PopupMenu3.PopUp(P.X, P.Y);
                end;
          end;
    end;

  procedure TBellSchedule.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    begin
      CanClose := false;
      HideForm;
    end;

end.

