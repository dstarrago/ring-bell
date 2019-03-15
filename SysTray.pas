unit SysTray;
// Implements the TSysTrayIcon component, which controls an icon in
// the system tray

// Things that should've been done better:
//   Use one window handle for multiple instances.
//   Events for MouseUp messages

// Feel free to modify and use this code.
// The only thing I ask, is that you leave my name in the source file.

// Please note that I provide this code as an example, and I
// make no warranties whatsoever on the results of using this code.
// Meaning: Whatever happens because you've used this code, is your own
// responsibility.

// Also note that I have NOT tested this code very thoroughly, I just
// wrote it in response to several newsgroup messages requesting information
// on how to implement SysTray icons.

// Trondheim, Norway, January 23. 1997
// Erik Sperling Johansen


interface

uses
  Classes, Forms, SysUtils, Graphics, ShellAPI, Windows, Messages;

const
  // Callback message, change to anything above WM_USER that don't
  // conflict with Delphi-defined msgs
  PM_ICONCALLBACK = WM_USER+9901;

type

  TSysTrayIcon = class;

  TSysTrayIconEvent = procedure
    ( Sender : TSysTrayIcon;
      X, Y   : WORD
    ) of object;

  TSysTrayIcon = class (TComponent)
  protected
    FOnLeftClick,
    FOnLeftDblClick,
    FOnRightClick,
    FOnRightDblClick,
    FOnMouseMove      : TSysTrayIconEvent;
    FIcon             : TIcon;
    FHandle           : HWND;
    FVisible          : BOOLEAN;
    FIconID           : INTEGER;
    FToolTip          : STRING;
    // Message handler
    procedure WndProc (var message : TMessage);
    // Property implementation
    procedure SetVisible (value : BOOLEAN);
    procedure SetToolTip (value : STRING);
    procedure SetIcon (value : TIcon);
    // Misc. methods
    procedure IconChanged;
    procedure SetIconData (var IconData : TNotifyIconData);
  public
    // New constructor and destructor
    constructor Create (AOwner : TComponent); override;
    destructor Destroy; override;
  published
    // Misc properties
    property Icon : TIcon read FIcon write SetIcon;
    property ToolTip : STRING read FToolTip write SetToolTip;
    property Visible : BOOLEAN read FVisible write SetVisible;
    // Misc events
    property OnLeftClick : TSysTrayIconEvent read FOnLeftClick
      write FOnLeftCLick;
    property OnLeftDblClick : TSysTrayIconEvent read FOnLeftDblClick
      write FOnLeftDblClick;
    property OnRightClick : TSysTrayIconEvent read FOnRightClick
      write FOnRightCLick;
    property OnRightDblClick : TSysTrayIconEvent read FOnRightDblClick
      write FOnRightDblCLick;
    property OnMouseMove : TSysTrayIconEvent read FOnMouseMove
      write FOnMouseMove;
  end;

procedure Register;

implementation

const
  // Used to ensure that each added icon has an unique ID
  IconIndex : LONGINT = 0;

procedure Register;
begin
  RegisterComponents('Samples', [TSysTrayIcon]);
end;


constructor TSysTrayIcon.Create (AOwner : TComponent);
begin
  inherited Create (AOwner);
  // Allocate a window handle for callback messages
  FHandle := AllocateHWND(WndProc);
  // Create the icon, and set default
  FIcon := TIcon.Create;
  FIcon.Handle := Application.Icon.Handle;
  // Set the internal icon id.
  FIconID := IconIndex;
  // And increment the instance count, to allow multiple systray icons
  inc(IconIndex);
end;

destructor TSysTrayIcon.Destroy;
begin
  // Make sure the icon is removed
  Visible := FALSE;
  // Deallocate the window handle
  DeallocateHWND(FHandle);
  // And free the icon object
  FIcon.Free;
end;


procedure TSysTrayIcon.SetIconData(var IconData:TNotifyIconData);
begin
  // Set the standard size of structure field
  IconData.cbSize := SizeOf(IconData);
  // Window to receive callback messages
  IconData.Wnd := FHandle;
  // Internal ID of the icon
  IconData.uID := FIconID;
  // Message we want to receive when something happens to the icon
  IconData.uCallbackMessage := PM_ICONCALLBACK;
  // Handle to the icon.
  IconData.hIcon := FIcon.Handle;
  // The tooltip
  StrPCopy(IconData.szTip, FToolTip);
  // IconData contains a valid window handle, a valid icon handle, and a valid
  // tooltip
  IconData.uFlags := NIF_MESSAGE + NIF_TIP + NIF_ICON;
end;


procedure TSysTrayIcon.IconChanged;
var
  IconData  : TNotifyIconData;
begin
  // No need to do anything, if the icon ain't visible
  if not Visible then exit;
  // Set the IconData fields
  SetIconData(IconData);
  // And tell systray the icon's changed
  Shell_NotifyIcon(NIM_MODIFY, ADDR(IconData));
end;

procedure TSysTrayIcon.SetIcon (value : TIcon);
begin
  // Copy the passed icon.
  FIcon.Assign(value);
  // Update the icon (if visible)
  IconChanged;
end;

procedure TSysTrayIcon.SetVisible (value : BOOLEAN);
var
  IconData  : TNotifyIconData;
begin
  if value=FVisible then exit;
  // We don't want systray icons while designing the form. This check
  // could be removed, but then two icons would be visible when running
  // the app from the Delphi IDE
  if not (csDesigning in ComponentState) then begin
    // Set the icondata fields
    SetIconData(IconData);
    // Add or remove the icon
    if value
    then FVisible := Shell_NotifyIcon(NIM_ADD, ADDR(IconData))
    else FVisible := not Shell_NotifyIcon(NIM_DELETE, ADDR(IconData));
  end else FVisible := value;
end;

procedure TSysTrayIcon.SetToolTip (value : STRING);
begin
  if FToolTip=value then exit;
  // Set the new tooltip
  FToolTip := value;
  // Update the icon (if visible)
  IconChanged;
end;

procedure TSysTrayIcon.WndProc (var message : TMessage);
var
  pt       : TPoint;
begin
// Could also include ButtonUp messages
// Should use GetMessagePos, but ain't always working correctly.
  if message.msg = PM_ICONCALLBACK then begin
    // lParam contains the actual message.
    case message.lParam of
      WM_LBUTTONDOWN:
        if Assigned (FOnLeftClick) then begin
          GetCursorPos (pt);
          FOnLeftClick(Self, pt.X, pt.Y);
        end;
      WM_LBUTTONDBLCLK:
        if Assigned (FOnLeftDblClick) then begin
          GetCursorPos (pt);
          FOnLeftDblClick(Self, pt.X, pt.Y);
        end;
      WM_RBUTTONDOWN:
        if Assigned (FOnRightClick) then begin
          GetCursorPos (pt);
          FOnRightClick(Self, pt.X, pt.Y);
        end;
      WM_RBUTTONDBLCLK:
        if Assigned (FOnRightDblClick) then begin
          GetCursorPos (pt);
          FOnRightDblClick(Self, pt.X, pt.Y);
        end;
      WM_MOUSEMOVE :
        if Assigned (FOnMouseMove) then begin
          GetCursorPos (pt);
          FOnMouseMove(Self, pt.X, pt.Y);
        end;
    end;
  end;
end;

initialization
end.

