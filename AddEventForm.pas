unit AddEventForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls;

type
  TEventAdder =
    class(TForm)
      DateTimePicker1: TDateTimePicker;
      Label1: TLabel;
      BitBtn1: TBitBtn;
      BitBtn2: TBitBtn;
      procedure FormShow(Sender: TObject);
    public
      StartTime: TDateTime;
    end;

var
  EventAdder: TEventAdder;

implementation

{$R *.DFM}

  procedure TEventAdder.FormShow(Sender: TObject);
    begin
      DateTimePicker1.Time := StartTime;
    end;

end.
