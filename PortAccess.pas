unit PortAccess;

interface

uses Windows;

  type
    TPortLPT =
      class
        private
          hPort: DWord;
        public
          constructor Create;
          destructor  Destroy;  override;
          function  Open: boolean;
          procedure Close;
          function Write(const sData: String): Boolean;
      end;

implementation

  uses Dialogs;

  function TPortLPT.Open: boolean;
    var
      Port: String;
      boolAbort: Boolean;
      sErrMsg: String;
    begin
      boolAbort := True;
      if hPort <> INVALID_HANDLE_VALUE  // close port if open already
        then Close;
      repeat
        Port := 'LPT1';
        hPort := CreateFile(PChar(Port), {GENERIC_READ or }GENERIC_WRITE, 0, nil,
                       OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, LongInt(0));
        if hPort = INVALID_HANDLE_VALUE
          then
            if MessageDlg('Error opening LPT1' + ': ' + sErrMsg,
                    mtWarning, [mbAbort, mbRetry], 0) = idAbort
              then boolAbort := True
              else boolAbort := False;
      until (hPort <> INVALID_HANDLE_VALUE) or (boolAbort = True);
      Result := (hPort <> INVALID_HANDLE_VALUE);
    end;

  function TPortLPT.Write(const sData: String): Boolean;
    var
      dwCharsWritten: DWord;
    begin
      dwCharsWritten := 0;
      Result := False; { default to error return }
      if hPort <> INVALID_HANDLE_VALUE
        then
          begin
            WriteFile(hPort, PChar(sData)^, Length(sData), dwCharsWritten, nil);
            if Longint(dwCharsWritten) = Length(sData)
              then Result := True;
          end;
    end;

  procedure TPortLPT.Close;
    begin
      if hPort <> INVALID_HANDLE_VALUE
        then CloseHandle(hPort);
      hPort := INVALID_HANDLE_VALUE;
    end;

  constructor TPortLPT.Create;
    begin
      inherited;
      hPort := INVALID_HANDLE_VALUE; { invalidate to start }
    end;

  destructor TPortLPT.Destroy;
    begin
      Close;
      inherited;
    end;

end.
