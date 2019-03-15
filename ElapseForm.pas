unit ElapseForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons;

type
  TLapse = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Lapse: TLapse;

implementation

{$R *.DFM}

end.
