{
MIT License

Copyright (c) 2022 Carlos Renan Silveira

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

  Based on official grammar @ https://www.json.org
  JSON Spec @ http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf

  Author: Carlos Renan Silveira
  Version: 1.0
}
unit DJson;

interface

uses
  SysUtils, Classes;

type
  TJSONValueType = (jsObject, jsArray, jsString, jsNumber, jsBoolean, jsNull);

  IJSONBase = interface
    ['{91DB4902-9CFA-4C96-803D-51961B6C581F}']
    // General methods
    function ToString: string;
  end;

  IJSONObject = interface;
  IJSONArray = interface;

  IJSONValue = interface(IJSONBase)
    ['{99A77426-89C1-4F5C-81BA-B9D6CC0FBB78}']
    // Properties members
    function GetValue: Variant;
    procedure SetValue(aValue: Variant);
    function GetAsObject: IJSONObject;
    function GetAsArray: IJSONArray;
    function GetAsString: string;
    function GetAsNumber: Double;
    function GetAsBoolean: Boolean;
    // General methods
    function ValueType: TJSONValueType;
    // General properties
    property Value: Variant read GetValue write SetValue;
    property AsObject: IJSONObject read GetAsObject;
    property AsArray: IJSONArray read GetAsArray;
    property AsString: string read GetAsString;
    property AsNumber: Double read GetAsNumber;
    property AsBoolean: Boolean read GetAsBoolean;
  end;

  IJSONList = interface(IJSONValue)
    ['{90A254C5-D366-48BE-BFE8-3F6228615F33}']
    function GetCount: Integer;
    property Count: Integer read GetCount;
  end;

  IJSONObject = interface(IJSONList)
    ['{BA9EF676-EC39-4088-B282-C0278A7544B6}']
    function GetMember(const aName: string): IJSONValue;
    function GetMemberAt(const aIdx: Integer): IJSONValue;
    function GetValueAt(const aIdx: Integer): Variant;
    function GetNameAt(const aIdx: Integer): string;

    procedure Add(const aName: string; aValue: IJSONValue); overload;
    procedure Add(const aName: string; const aValue: string); overload;
    procedure Add(const aName: string; const aValue: Double); overload;
    procedure Add(const aName: string; const aValue: Boolean); overload;
    procedure Remove(const aName: string);

    property Member[const aName: string]: IJSONValue read GetMember; default;
    property MemberAt[const aIdx: Integer]: IJSONValue read GetMemberAt;
    property ValueAt[const aIdx: Integer]: Variant read GetValueAt;
    property NameAt[const aIdx: Integer]: string read GetNameAt;
  end;

  IJSONArray = interface(IJSONList)
    ['{E25F79E9-FD33-4D16-96E4-7A84439037FF}']
    function GetElement(const aIdx: Integer): IJSONValue;

    procedure Add(aElement: IJSONValue); overload;
    procedure Add(const aValue: string); overload;
    procedure Add(const aValue: Double); overload;
    procedure Add(const aValue: Boolean); overload;
    procedure Remove(aElement: IJSONValue);
    procedure RemoveAt(const aIdx: Integer);
    procedure Delete(const aIdx: Integer);

    property Element[const aIdx: Integer]: IJSONValue read GetElement; default;
  end;

  // JSON Reader
  TJSONReader = class
  public
    class function Read(aText: string): IJSONValue;
    class function ReadFromStream(aStream: TStream; aResetStream: Boolean = False): IJSONValue;
    class function ReadFromFile(aFileName: TFileName): IJSONValue;
  end;

  // JSON Writer
  TJSONWriter = class
  public
    class procedure WriteToStream(aJSON: IJSONValue; aStream: TStream);
    class procedure WriteToFile(aJSON: IJSONValue; aFileName: TFileName);
  end;

  // JSON Fluent Builder interfaces
  IJSONObjectBuilder = interface
    ['{E14580D4-3A8A-44D0-BB4E-C184F569AC77}']
    function Add(const aName: string; const aValue: string): IJSONObjectBuilder; overload;
    function Add(const aName: string; const aValue: Double): IJSONObjectBuilder; overload;
    function Add(const aName: string; const aValue: Boolean): IJSONObjectBuilder; overload;
    function Add(const aName: string; const aValue: Variant): IJSONObjectBuilder; overload;
    function Add(const aName: string; aValue: IJSONValue): IJSONObjectBuilder; overload;
    function Add(const aName: string; aJSONObject: IJSONObject): IJSONObjectBuilder; overload;
    function Add(const aName: string; aJSONArray: IJSONArray): IJSONObjectBuilder; overload;
    function AddNull(const aName: string): IJSONObjectBuilder;
    function Build: IJSONObject;
  end;

  IJSONArrayBuilder = interface
    ['{B9FABE5C-43E9-403E-A26A-4508F7CC8755}']
    function Add(const aValue: string): IJSONArrayBuilder; overload;
    function Add(const aValue: Double): IJSONArrayBuilder; overload;
    function Add(const aValue: Boolean): IJSONArrayBuilder; overload;
    function Add(const aValue: Variant): IJSONArrayBuilder; overload;
    function Add(aValue: IJSONValue): IJSONArrayBuilder; overload;
    function Add(aJSONObject: IJSONObject): IJSONArrayBuilder; overload;
    function Add(aJSONArray: IJSONArray): IJSONArrayBuilder; overload;
    function AddNull: IJSONArrayBuilder;
    function Build: IJSONArray;
  end;

  IJSONBuilder = interface
    ['{A4FCE899-B53E-482B-A415-F010B7EE05DE}']
    function BuildObject: IJSONObjectBuilder;
    function BuildArray: IJSONArrayBuilder;
    function BuildString(const aValue: string = ''): IJSONValue;
    function BuildNumber(const aValue: Double = 0): IJSONValue;
    function BuildBoolean(const aValue: Boolean = True): IJSONValue;
    function BuildNull: IJSONValue;
  end;

function JSONBuilder: IJSONBuilder;

implementation

uses StrUtils, Variants;

type
  // Base JSON class
  TJSONBase = class(TInterfacedObject, IJSONBase)
  public
{$IFNDEF fpc}
    function ToString: string; virtual; abstract;
{$ENDIF}
  end;

  TJSONValue = class(TJSONBase, IJSONValue)
  private
    function GetAsObject: IJSONObject;
    function GetAsArray: IJSONArray;
    function GetAsString: string;
    function GetAsNumber: Double;
    function GetAsBoolean: Boolean;
  protected
    function GetValue: Variant; virtual;
    procedure SetValue(aValue: Variant); virtual;
  public
    function ValueType: TJSONValueType; virtual; abstract;

    property Value: Variant read GetValue write SetValue;
    property AsObject: IJSONObject read GetAsObject;
    property AsArray: IJSONArray read GetAsArray;
    property AsString: string read GetAsString;
    property AsNumber: Double read GetAsNumber;
    property AsBoolean: Boolean read GetAsBoolean;
  end;

  // Inner helper types
  TJSONList = class(TJSONValue, IJSONList)
  private
    FList: TInterfaceList;
    function GetCount: Integer;
    function GetChild(const aIdx: Integer): IJSONBase;
  protected
    function GetValue: Variant; override;
    procedure SetValue(aValue: Variant); override;

    property Child[const aIdx: Integer]: IJSONBase read GetChild;
    function IndexOf(aItem: IJSONBase): Integer;
    procedure _Add(aItem: IJSONBase);
    procedure _Remove(aItem: IJSONBase);
    procedure _Delete(const aIdx: Integer);
    function GetChildrenString: string;
  public
    constructor Create;
    destructor Destroy; override;

    property Count: Integer read GetCount;
  end;

  IJSONPair = interface(IJSONBase)
    ['{6BFBE3DC-F3D5-4C39-BB1A-1548AE0D798C}']
    // Accessors
    function GetName: string;
    procedure SetName(const aName: string);
    function GetValue: IJSONValue;
    procedure SetValue(aValue: IJSONValue);
    // Properties
    property Name: string read GetName write SetName;
    property Value: IJSONValue read GetValue write SetValue;
  end;

  TJSONPair = class(TJSONBase, IJSONPair)
  private
    FName: string;
    FValue: IJSONValue;
  protected
    function GetName: string;
    procedure SetName(const aName: string);
    function GetValue: IJSONValue;
    procedure SetValue(aValue: IJSONValue);
  public
    constructor Create(const aName: string; aValue: IJSONValue);
    destructor Destroy; override;

    function ToString: string; override;
    property Name: string read GetName write SetName;
    property Value: IJSONValue read GetValue write SetValue;
  end;

  // JSON object type
  TJSONObject = class(TJSONList, IJSONObject)
  protected
    function GetMember(const aName: string): IJSONValue;
    function GetMemberAt(const aIdx: Integer): IJSONValue;
    function GetValueAt(const aIdx: Integer): Variant;
    function GetNameAt(const aIdx: Integer): string;
  public
    function ToString: string; override;
    function ValueType: TJSONValueType; override;

    procedure Add(const aName: string; aValue: IJSONValue); overload;
    procedure Add(const aName: string; const aValue: string); overload;
    procedure Add(const aName: string; const aValue: Double); overload;
    procedure Add(const aName: string; const aValue: Boolean); overload;
    procedure Remove(const aName: string);

    property Member[const aName: string]: IJSONValue read GetMember; default;
    property MemberAt[const aIdx: Integer]: IJSONValue read GetMemberAt;
    property ValueAt[const aIdx: Integer]: Variant read GetValueAt;
    property NameAt[const aIdx: Integer]: string read GetNameAt;
  end;

  // JSON array type
  TJSONArray = class(TJSONList, IJSONArray)
  protected
    function GetElement(const aIdx: Integer): IJSONValue;
  public
    function ToString: string; override;
    function ValueType: TJSONValueType; override;

    procedure Add(aElement: IJSONValue); overload;
    procedure Add(const aValue: string); overload;
    procedure Add(const aValue: Double); overload;
    procedure Add(const aValue: Boolean); overload;
    procedure Remove(aElement: IJSONValue);
    procedure RemoveAt(const aIdx: Integer);
    procedure Delete(const aIdx: Integer);

    property Element[const aIdx: Integer]: IJSONValue read GetElement; default;
  end;

  // JSON string primitive type
  TJSONString = class(TJSONValue, IJSONValue)
  private
    FValue: string;
  protected
    function GetValue: Variant; override;
    procedure SetValue(aValue: Variant); override;
  public
    function ToString: string; override;
    function ValueType: TJSONValueType; override;

    constructor Create(const aValue: string = '');
  end;

  // JSON number primitive type
  TJSONNumber = class(TJSONValue, IJSONValue)
  private
    FValue: Double;
    FFormatSettings: TFormatSettings;
  protected
    function GetValue: Variant; override;
    procedure SetValue(aValue: Variant); override;
  public
    function ToString: string; override;
    function ValueType: TJSONValueType; override;

    constructor Create(const aValue: Double = 0);
  end;

  // JSON 'true' and 'false' primitive type
  TJSONBoolean = class(TJSONValue, IJSONValue)
  private
    FValue: Boolean;
  protected
    function GetValue: Variant; override;
    procedure SetValue(aValue: Variant); override;
  public
    function ToString: string; override;
    function ValueType: TJSONValueType; override;

    constructor Create(const aValue: Boolean = True);
  end;

  // JSON 'null' primitive type
  TJSONNull = class(TJSONValue, IJSONValue)
  protected
    function GetValue: Variant; override;
    procedure SetValue(aValue: Variant); override;
  public
    function ToString: string; override;
    function ValueType: TJSONValueType; override;
  end;

  // JSON Builder classes
  TJSONObjectBuilder = class(TInterfacedObject, IJSONObjectBuilder)
  private
    FJSONObject: IJSONObject;
  public
    constructor Create;
    function Add(const aName: string; const aValue: string): IJSONObjectBuilder; overload;
    function Add(const aName: string; const aValue: Double): IJSONObjectBuilder; overload;
    function Add(const aName: string; const aValue: Boolean): IJSONObjectBuilder; overload;
    function Add(const aName: string; const aValue: Variant): IJSONObjectBuilder; overload;
    function Add(const aName: string; aValue: IJSONValue): IJSONObjectBuilder; overload;
    function Add(const aName: string; aJSONObject: IJSONObject): IJSONObjectBuilder; overload;
    function Add(const aName: string; aJSONArray: IJSONArray): IJSONObjectBuilder; overload;
    function AddNull(const aName: string): IJSONObjectBuilder;
    function Build: IJSONObject;
  end;

  TJSONArrayBuilder = class(TInterfacedObject, IJSONArrayBuilder)
  private
    FJSONArray: IJSONArray;
  public
    constructor Create;
    function Add(const aValue: string): IJSONArrayBuilder; overload;
    function Add(const aValue: Double): IJSONArrayBuilder; overload;
    function Add(const aValue: Boolean): IJSONArrayBuilder; overload;
    function Add(const aValue: Variant): IJSONArrayBuilder; overload;
    function Add(aValue: IJSONValue): IJSONArrayBuilder; overload;
    function Add(aJSONObject: IJSONObject): IJSONArrayBuilder; overload;
    function Add(aJSONArray: IJSONArray): IJSONArrayBuilder; overload;
    function AddNull: IJSONArrayBuilder;
    function Build: IJSONArray;
  end;

  TJSONBuilder = class(TInterfacedObject, IJSONBuilder)
  protected
    class function VariantToJSONValue(const aValue: Variant): IJSONValue;
  public
    function BuildObject: IJSONObjectBuilder;
    function BuildArray: IJSONArrayBuilder;
    function BuildString(const aValue: string): IJSONValue;
    function BuildNumber(const aValue: Double): IJSONValue;
    function BuildBoolean(const aValue: Boolean = True): IJSONValue;
    function BuildNull: IJSONValue;
  end;

// Unit global methods
function JSONBuilder: IJSONBuilder;
begin
  Result := TJSONBuilder.Create;
end;

{ TJSONValue }

function TJSONValue.GetAsObject: IJSONObject;
begin
  Result := nil;
  if ValueType = jsObject then
    Result := TJSONObject(Self);
end;

function TJSONValue.GetAsArray: IJSONArray;
begin
  Result := nil;
  if ValueType = jsArray then
    Result := TJSONArray(Self);
end;

function TJSONValue.GetAsString: string;
begin
  Result := '';
  if ValueType = jsString then
    Result := VarAsType(Value, varString);
end;

function TJSONValue.GetAsNumber: Double;
begin
  Result := 0;
  if ValueType = jsNumber then
    Result := VarAsType(Value, varDouble);
end;

function TJSONValue.GetAsBoolean: Boolean;
begin
  Result := false;
  if ValueType = jsBoolean then
    Result := VarAsType(Value, varBoolean);
end;

function TJSONValue.GetValue: Variant;
begin
  Result := Null;
end;

procedure TJSONValue.SetValue(aValue: Variant);
begin
end;

{ TJSONPair }

constructor TJSONPair.Create(const aName: string; aValue: IJSONValue);
begin
  FName := aName;
  FValue := aValue;
end;

destructor TJSONPair.Destroy;
begin
  inherited;
end;

function TJSONPair.GetName: string;
begin
  Result := FName;
end;

procedure TJSONPair.SetName(const aName: string);
begin
  FName := aName;
end;

function TJSONPair.GetValue: IJSONValue;
begin
  Result := FValue;
end;

procedure TJSONPair.SetValue(aValue: IJSONValue);
begin
  FValue := aValue;
end;

function TJSONPair.ToString: string;
begin
  Result := Format('"%s":%s', [FName, FValue.ToString]);
end;

{ TJSONList }

constructor TJSONList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TJSONList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TJSONList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TJSONList.GetChild(const aIdx: Integer): IJSONBase;
begin
  Result := FList[aIdx] as IJSONBase;
end;

function TJSONList.GetValue: Variant;
begin
  Result := Null;
end;

procedure TJSONList.SetValue(aValue: Variant);
begin
  // Don't need the value
end;

function TJSONList.IndexOf(aItem: IJSONBase): Integer;
begin
  Result := FList.IndexOf(aItem);
end;

procedure TJSONList._Add(aItem: IJSONBase);
begin
  FList.Add(aItem);
end;

procedure TJSONList._Remove(aItem: IJSONBase);
begin
  FList.Remove(aItem);
end;

procedure TJSONList._Delete(const aIdx: Integer);
begin
  FList.Delete(aIdx);
end;

function TJSONList.GetChildrenString: string;
var
  idx: Integer;
  childrenText: string;
begin
  childrenText := '';
  for idx := 0 to Count - 1 do
    childrenText := childrenText + Child[idx].ToString + ',';
  SetLength(childrenText, Length(childrenText) - 1); // To remove the last ','
  Result := childrenText;
end;

{ TJSONObject }

function TJSONObject.GetMember(const aName: string): IJSONValue;
var
  idx: Integer;
  pair: IJSONPair;
begin
  Result := nil;
  for idx := 0 to Count - 1 do begin
    pair := Child[idx] as IJSONPair;
    if pair.Name = aName then begin
      Result := pair.Value;
      Exit;
    end;
  end;
end;

function TJSONObject.GetMemberAt(const aIdx: Integer): IJSONValue;
begin
  Result := (Child[aIdx] as IJSONPair).Value;
end;

function TJSONObject.GetValueAt(const aIdx: Integer): Variant;
begin
  Result := (Child[aIdx] as IJSONPair).Value.Value;
end;

function TJSONObject.GetNameAt(const aIdx: Integer): string;
begin
  Result := (Child[aIdx] as IJSONPair).Name;
end;

function TJSONObject.ToString: string;
begin
  Result := Format('{%s}', [GetChildrenString]);
end;

function TJSONObject.ValueType: TJSONValueType;
begin
  Result := jsObject;
end;

procedure TJSONObject.Add(const aName: string; aValue: IJSONValue);
begin
  _Add(TJSONPair.Create(aName, aValue));
end;

procedure TJSONObject.Add(const aName, aValue: string);
begin
  Self.Add(aName, TJSONString.Create(aValue));
end;

procedure TJSONObject.Add(const aName: string; const aValue: Double);
begin
  Self.Add(aName, TJSONNumber.Create(aValue));
end;

procedure TJSONObject.Add(const aName: string; const aValue: Boolean);
begin
  Self.Add(aName, TJSONBoolean.Create(aValue));
end;

procedure TJSONObject.Remove(const aName: string);
var
  idx: Integer;
begin
  for idx := 0 to Count - 1 do begin
    if (Child[idx] as IJSONPair).Name = aName then begin
      _Delete(idx);
      Exit;
    end;
  end;
end;

{ TJSONArray }

function TJSONArray.GetElement(const aIdx: Integer): IJSONValue;
begin
  Result := Child[aIdx] as IJSONValue;
end;

function TJSONArray.ToString: string;
begin
  Result := Format('[%s]', [GetChildrenString]);
end;

function TJSONArray.ValueType: TJSONValueType;
begin
  Result := jsArray;
end;

procedure TJSONArray.Add(aElement: IJSONValue);
begin
  _Add(aElement);
end;

procedure TJSONArray.Add(const aValue: string);
begin
  Self.Add(TJSONString.Create(aValue));
end;

procedure TJSONArray.Add(const aValue: Double);
begin
  Self.Add(TJSONNumber.Create(aValue));
end;

procedure TJSONArray.Add(const aValue: Boolean);
begin
  Self.Add(TJSONBoolean.Create(aValue));
end;

procedure TJSONArray.Remove(aElement: IJSONValue);
begin
  _Remove(aElement);
end;

procedure TJSONArray.RemoveAt(const aIdx: Integer);
begin
  Self.Remove(Element[aIdx]);
end;

procedure TJSONArray.Delete(const aIdx: Integer);
begin
  _Delete(aIdx);
end;

{ TJSONString }

constructor TJSONString.Create(const aValue: string);
begin
  FValue := aValue;
end;

function TJSONString.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TJSONString.SetValue(aValue: Variant);
begin
  inherited;
  FValue := VarToStr(aValue);
end;

function TJSONString.ToString: string;
begin
  Result := Format('"%s"', [FValue]);
end;

function TJSONString.ValueType: TJSONValueType;
begin
  Result := jsString;
end;

{ TJSONNumber }

constructor TJSONNumber.Create(const aValue: Double);
begin
  Value := aValue;
{$IFNDEF FPC}
  GetLocaleFormatSettings(SysLocale.DefaultLCID, FFormatSettings);
{$ELSE}
  GetFormatSettings;
  FFormatSettings := DefaultFormatSettings;
{$ENDIF}
  FFormatSettings.DecimalSeparator := '.';
  FFormatSettings.ThousandSeparator := ',';
end;

function TJSONNumber.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TJSONNumber.SetValue(aValue: Variant);
begin
  inherited;
  FValue := VarAsType(aValue, varDouble);
end;

function TJSONNumber.ToString: string;
begin
  Result := Format('%g', [FValue], FFormatSettings);
end;

function TJSONNumber.ValueType: TJSONValueType;
begin
  Result := jsNumber;
end;

{ TJSONBoolean }

constructor TJSONBoolean.Create(const aValue: Boolean);
begin
  FValue := aValue;
end;

function TJSONBoolean.GetValue: Variant;
begin
  Result := FValue
end;

procedure TJSONBoolean.SetValue(aValue: Variant);
begin
  inherited;
  FValue := aValue;
end;

function TJSONBoolean.ToString: string;
begin
  Result := IfThen(FValue, 'true', 'false');
end;

function TJSONBoolean.ValueType: TJSONValueType;
begin
  Result := jsBoolean;
end;

{ TJSONNull }

function TJSONNull.GetValue: Variant;
begin
  Result := Null;
end;

procedure TJSONNull.SetValue(aValue: Variant);
begin
  // Don't need the value
end;

function TJSONNull.ToString: string;
begin
  Result := 'null';
end;

function TJSONNull.ValueType: TJSONValueType;
begin
  Result := jsNull;
end;

{ TJSONReader }

class function TJSONReader.Read(aText: string): IJSONValue;
var
  fs: TFormatSettings;

  function Tokenize(aSource: string): TStringList;
  var
    i, NestedLvl: Integer;
    InsideString: Boolean;
  begin
    Result := nil;
    if aSource <> '' then begin
      Result := TStringList.Create;
      i := 1;
      NestedLvl := 0;
      InsideString := False;
      while i <= Length(aSource) do begin
        if PosEx(',', aSource) < 1 then
          Break;
        if (aSource[i] = '"') and (aSource[i - 1] <> '\') then
          InsideString := not InsideString;
        if aSource[i] in ['[', '{'] then Inc(NestedLvl);
        if aSource[i] in [']', '}'] then Dec(NestedLvl);
        if (aSource[i] = ',') and (not InsideString and (NestedLvl = 0)) then begin
          Result.Add(Copy(aSource, 1, i - 1));
          Delete(aSource, 1, i);
          i := 1;
        end
        else
          Inc(i);
      end;
      if aSource <> '' then
        Result.Add(aSource);
    end;
  end;

  function ParseToken(const aToken: string): TJSONValue; forward;

  function ParseObject(const aToken: string): TJSONObject;
  var
    tokens: TStringList;
    pairs: TStringList;
    name: string;
    i: Integer;
  begin
    Result := nil;
    if (LeftStr(aToken, 1) = '{') and (RightStr(aToken, 1) = '}') then begin
      Result := TJSONObject.Create;
      tokens := Tokenize(Copy(aToken, 2, Length(aToken) - 2));
      pairs := TStringList.Create;
      pairs.NameValueSeparator := ':';
      try
        for i := 0 to tokens.Count - 1 do begin
          pairs.Text := tokens[i];
          name := pairs.Names[0];
          Result.Add(Copy(name, 2, Length(name) - 2), ParseToken(pairs.Values[name]));
        end;
      finally
        tokens.Free;
        pairs.Free;
      end;
    end;
  end;

  function ParseArray(const aToken: string): TJSONArray;
  var
    tokens: TStringList;
    i: Integer;
  begin
    Result := nil;
    if (LeftStr(aToken, 1) = '[') and (RightStr(aToken, 1) = ']') then begin
      Result := TJSONArray.Create;
      tokens := Tokenize(Copy(aToken, 2, Length(aToken) - 2));
      try
        for i := 0 to tokens.Count - 1 do
          Result.Add(ParseToken(tokens[i]));
      finally
        tokens.Free;
      end;
    end;
  end;

  function ParseToken(const aToken: string): TJSONValue;
  var
    number: Double;
  begin
    if SameText(LowerCase(aToken), 'null') then Result := TJSONNull.Create
    else if SameText(LowerCase(aToken), 'true') then Result := TJSONBoolean.Create
    else if SameText(LowerCase(aToken), 'false') then Result := TJSONBoolean.Create(false)
    else if TryStrToFloat(aToken, number, fs) then Result := TJSONNumber.Create(number)
    else if (LeftStr(aToken, 1) = '{') and (RightStr(aToken, 1) = '}') then Result := ParseObject(aToken)
    else if (LeftStr(aToken, 1) = '[') and (RightStr(aToken, 1) = ']') then Result := ParseArray(aToken)
    else if (LeftStr(aToken, 1) = '"') and (RightStr(aToken, 1) = '"') then Result := TJSONString.Create(Copy(aToken, 2, Length(aToken) - 2))
    else raise Exception.CreateFmt('Could not parse token "%s".', [aToken]);
  end;

  function Minify(const aSource: string): string;
  var
    sst: TStringStream;
    i: Integer;
    c: Char;
    InsideString: Boolean;
  begin
    sst := TStringStream.Create('');
    try
      i := 1;
      InsideString := False;
      while i <= Length(aSource) do begin
        c := aSource[i];
        if Ord(c) > 31 then begin
          if (c = '"') and (aSource[i - 1] <> '\') then
            InsideString := not InsideString;
          if (c = ' ') and not InsideString then begin
            Inc(i);
            Continue;
          end;
          sst.WriteString(c);
        end;
        Inc(i);
      end;
      Result := sst.DataString;
    finally
      sst.Free;
    end;
  end;

begin
{$IFNDEF FPC}
  GetLocaleFormatSettings(SysLocale.DefaultLCID, fs);
{$ELSE}
  GetFormatSettings;
  fs := DefaultFormatSettings;
{$ENDIF}
  fs.DecimalSeparator := '.';
  fs.ThousandSeparator := ',';

  Result := nil;
  if (Trim(aText) <> '') then
{$IFDEF FPC}
    Result := ParseToken(Minify(Trim(aText)));
{$ELSE}
    Result := ParseToken(Minify(UTF8Decode(Trim(aText))));
{$ENDIF}
end;

class function TJSONReader.ReadFromStream(aStream: TStream; aResetStream: Boolean): IJSONValue;
var
  buf: string;
begin
  Result := nil;
  if Assigned(aStream) then begin
    if aResetStream then aStream.Position := 0;
    SetLength(buf, aStream.Size - aStream.Position);
    aStream.Read(buf[1], aStream.Size - aStream.Position);
    Result := Read(buf);
  end;
end;

class function TJSONReader.ReadFromFile(aFileName: TFileName): IJSONValue;
var
  fs: TFileStream;
begin
  Result := nil;
  if not FileExists(aFileName) then Exit;
  fs := TFileStream.Create(aFileName, fmOpenRead);
  try
    Result := ReadFromStream(fs, true);
  finally
    fs.Free;
  end;
end;

{ TJSONWriter }

class procedure TJSONWriter.WriteToStream(aJSON: IJSONValue; aStream: TStream);
var
  buf: UTF8String;
begin
  if Assigned(aJSON) then begin
    buf := UTF8Encode(aJSON.ToString);
    aStream.Write(buf[1], Length(buf));
  end;
end;

class procedure TJSONWriter.WriteToFile(aJSON: IJSONValue; aFileName: TFileName);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(aFileName, fmOpenWrite or fmCreate);
  try
    WriteToStream(aJSON, fs);
  finally
    fs.Free;
  end;
end;

{ TJSONObjectBuilder }

constructor TJSONObjectBuilder.Create;
begin
  inherited;
  FJSONObject := TJSONObject.Create;
end;

function TJSONObjectBuilder.Add(const aName, aValue: string): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, aValue);
  Result := Self;
end;

function TJSONObjectBuilder.Add(const aName: string; const aValue: Double): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, aValue);
  Result := Self;
end;

function TJSONObjectBuilder.Add(const aName: string; const aValue: Boolean): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, aValue);
  Result := Self;
end;

function TJSONObjectBuilder.Add(const aName: string; const aValue: Variant): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, TJSONBuilder.VariantToJSONValue(aValue));
  Result := Self;
end;

function TJSONObjectBuilder.Add(const aName: string; aValue: IJSONValue): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, aValue);
  Result := Self;
end;

function TJSONObjectBuilder.Add(const aName: string; aJSONObject: IJSONObject): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, aJSONObject);
  Result := Self;
end;

function TJSONObjectBuilder.Add(const aName: string; aJSONArray: IJSONArray): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, aJSONArray);
  Result := Self;
end;

function TJSONObjectBuilder.AddNull(const aName: string): IJSONObjectBuilder;
begin
  FJSONObject.Add(aName, TJSONNull.Create);
  Result := Self;
end;

function TJSONObjectBuilder.Build: IJSONObject;
begin
  Result := FJSONObject;
end;

{ TJSONArrayBuilder }

constructor TJSONArrayBuilder.Create;
begin
  FJSONArray := TJSONArray.Create;
end;

function TJSONArrayBuilder.Add(const aValue: string): IJSONArrayBuilder;
begin
  FJSONArray.Add(aValue);
  Result := Self;
end;

function TJSONArrayBuilder.Add(const aValue: Double): IJSONArrayBuilder;
begin
  FJSONArray.Add(aValue);
  Result := Self;
end;

function TJSONArrayBuilder.Add(const aValue: Boolean): IJSONArrayBuilder;
begin
  FJSONArray.Add(aValue);
  Result := Self;
end;

function TJSONArrayBuilder.Add(const aValue: Variant): IJSONArrayBuilder;
begin
  FJSONArray.Add(TJSONBuilder.VariantToJSONValue(aValue));
  Result := Self;
end;

function TJSONArrayBuilder.Add(aValue: IJSONValue): IJSONArrayBuilder;
begin
  FJSONArray.Add(aValue);
  Result := Self;
end;

function TJSONArrayBuilder.Add(aJSONObject: IJSONObject): IJSONArrayBuilder;
begin
  FJSONArray.Add(aJSONObject);
  Result := Self;
end;

function TJSONArrayBuilder.Add(aJSONArray: IJSONArray): IJSONArrayBuilder;
begin
  FJSONArray.Add(aJSONArray);
  Result := Self;
end;

function TJSONArrayBuilder.AddNull: IJSONArrayBuilder;
begin
  FJSONArray.Add(TJSONNull.Create);
  Result := Self;
end;

function TJSONArrayBuilder.Build: IJSONArray;
begin
  Result := FJSONArray;
end;

{ TJSONBuilder }

class function TJSONBuilder.VariantToJSONValue(const aValue: Variant): IJSONValue;
begin
  case VarType(aValue) of
    varSmallint,
    varInteger,
    varSingle,
    varDouble,
    varCurrency,
    varShortInt,
    varByte,
    varWord,
    varLongWord,
    varInt64:
      Result := TJSONNumber.Create(aValue);
    varBoolean:
      Result := TJSONBoolean.Create(aValue);
    varString:
      Result := TJSONString.Create(aValue);
    else
      Result := TJSONNull.Create;
  end;
end;

function TJSONBuilder.BuildObject: IJSONObjectBuilder;
begin
  Result := TJSONObjectBuilder.Create;
end;

function TJSONBuilder.BuildArray: IJSONArrayBuilder;
begin
  Result := TJSONArrayBuilder.Create;
end;

function TJSONBuilder.BuildString(const aValue: string): IJSONValue;
begin
  Result := TJSONString.Create(aValue);
end;

function TJSONBuilder.BuildNumber(const aValue: Double): IJSONValue;
begin
  Result := TJSONNumber.Create(aValue);
end;

function TJSONBuilder.BuildBoolean(const aValue: Boolean): IJSONValue;
begin
  Result := TJSONBoolean.Create(aValue);
end;

function TJSONBuilder.BuildNull: IJSONValue;
begin
  Result := TJSONNull.Create;
end;

end.
