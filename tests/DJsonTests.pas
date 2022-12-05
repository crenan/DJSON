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
unit DJsonTests;

{$IFDEF FPC}
	{$mode objfpc}{$H+}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  fpcunit, testregistry,
{$ELSE}
  TestFrameWork,
{$ENDIF}
  Classes, SysUtils;

type
  { TDJsonTests }
  TDJsonTests = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CanBuildAJsonString;
    procedure CanBuildAJsonNumber;
    procedure CanBuildAJsonBoolean;
    procedure CanBuildAJsonNull;
    procedure CanBuildASimpleJSONArray;
    procedure CanRemoveItemByElementFromJSONArray;
    procedure CanRemoveItemByIndexFromJSONArray;
    procedure CanBuildASimpleJSONObject;
    procedure CanRemoveMemberByNameFromJSONObject;
    procedure CanParseStringValueToJSON;
    procedure CannotParseInvalidEmptyString;
  end;

implementation

uses Variants, DJson;

{ TDJsonTests }

procedure TDJsonTests.SetUp;
begin
  inherited;
end;

procedure TDJsonTests.TearDown;
begin
  inherited;
end;

procedure TDJsonTests.CanBuildAJsonString;
var
  JString: IJSONValue;
begin
  // Arrange
  JString := JSONBuilder.BuildString('This is a JSON test');
  // Assert
  CheckTrue(JString.ValueType = jsString);
  CheckEquals('This is a JSON test', JString.Value);
  CheckEquals('This is a JSON test', JString.AsString);
  CheckEquals('"This is a JSON test"', JString.ToString);
end;

procedure TDJsonTests.CanBuildAJsonNumber;
var
  JNumber: IJSONValue;
begin
  // Arrange
  JNumber := JSONBuilder.BuildNumber(666);
  // Assert
  CheckTrue(JNumber.ValueType = jsNumber);
  CheckEquals(666, JNumber.Value);
  CheckEquals(666, JNumber.AsNumber);
  CheckEquals('666', JNumber.ToString);
end;

procedure TDJsonTests.CanBuildAJsonBoolean;
var
  JBool: IJSONValue;
begin
  // Arrange
  JBool := JSONBuilder.BuildBoolean(True);
  // Assert
  CheckTrue(JBool.ValueType = jsBoolean);
  CheckTrue(JBool.Value);
  CheckEquals(True, JBool.AsBoolean);
  CheckEquals('true', JBool.ToString);
end;

procedure TDJsonTests.CanBuildAJsonNull;
var
  JNull: IJSONValue;
begin
  // Arrange
  JNull := JSONBuilder.BuildNull;
  // Assert
  CheckTrue(JNull.ValueType = jsNull);
  CheckTrue(JNull.Value = Null);
  CheckEquals('null', JNull.ToString);
end;

procedure TDJsonTests.CanBuildASimpleJSONArray;
var
  JArray: IJSONArray;
begin
  // Arrange
  JArray := JSONBuilder.BuildArray.Add('Test').Add(1).Add(true).Build;
  // Assert
  CheckTrue(Assigned(JArray));
  CheckTrue(JArray.ValueType = jsArray);
  CheckEquals(3, JArray.AsArray.Count);
  CheckEquals('Test', JArray.AsArray[0].Value);
  CheckEquals(1, JArray.AsArray[1].Value);
  CheckEquals(True, JArray.AsArray[2].Value);
end;

procedure TDJsonTests.CanRemoveItemByElementFromJSONArray;
var
  JArray: IJSONArray;
begin
  // Arrange
  JArray := JSONBuilder.BuildArray.Add(1).Add(2).Add(3).Add(4).Build;
  CheckEquals(4, JArray.Count);
  JArray.Remove(JArray[2]);
  // Assert
  CheckTrue(JArray.ValueType = jsArray);
  CheckEquals(3, JArray.Count);
  CheckEquals(1, JArray[0].Value);
  CheckEquals(2, JArray[1].Value);
  CheckEquals(4, JArray[2].Value);
end;

procedure TDJsonTests.CanRemoveItemByIndexFromJSONArray;
var
  JArray: IJSONArray;
begin
  // Arrange
  JArray := JSONBuilder.BuildArray.Add(1).Add(2).Add(3).Add(4).Build;
  CheckEquals(4, JArray.Count);
  JArray.RemoveAt(1);
  // Assert
  CheckTrue(JArray.ValueType = jsArray);
  CheckEquals(3, JArray.Count);
  CheckEquals(1, JArray[0].Value);
  CheckEquals(3, JArray[1].Value);
  CheckEquals(4, JArray[2].Value);
end;

procedure TDJsonTests.CanBuildASimpleJSONObject;
var
  JObject: IJSONObject;
begin
  // Arrange
  JObject := JSONBuilder.BuildObject.Add('Text', 'test').Add('number', 1).Add('Bool', false).Build;
  // Assert
  CheckTrue(Assigned(JObject));
  CheckTrue(JObject.ValueType = jsObject);
  CheckEquals(3, JObject.Count);
  CheckEquals('Text', JObject.NameAt[0]);
  CheckEquals('test', JObject['Text'].Value);
  CheckEquals('number', JObject.NameAt[1]);
  CheckEquals(1, JObject.ValueAt[1]);
  CheckEquals('Bool', JObject.NameAt[2]);
  CheckFalse(JObject['Bool'].Value);
end;

procedure TDJsonTests.CanRemoveMemberByNameFromJSONObject;
var
  JObject: IJSONObject;
begin
  // Arrange
  JObject := JSONBuilder.BuildObject.Add('text', 'This is a test!').Add('number', 1).Add('bool', true).Add('null', JSONBuilder.BuildNull).Build;
  CheckEquals(4, JObject.Count);
  JObject.Remove('text');
  // Assert
  CheckTrue(JObject.ValueType = jsObject);
  CheckEquals(3, JObject.Count);
  CheckEquals(1, JObject.ValueAt[0]);
  CheckEquals(true, JObject.ValueAt[1]);
  CheckEquals(true, JObject.ValueAt[2] = Null);
end;

procedure TDJsonTests.CanParseStringValueToJSON;
var
  JString: IJSONValue;
begin
  // Arrange
  JString := TJSONReader.Read('"This is a JSON string value"');
  // Assert
  CheckTrue(JString.ValueType = jsString);
  CheckEquals('This is a JSON string value', JString.Value);
  CheckEquals('This is a JSON string value', JString.AsString);
  CheckEquals('"This is a JSON string value"', JString.ToString);
end;

procedure TDJsonTests.CannotParseInvalidEmptyString;
var
  InvalidJSON: IJSONValue;
begin
  InvalidJSON := TJSONReader.Read('');
  CheckNull(InvalidJSON);
end;

initialization
{$IFDEF FPC}
  RegisterTest(TDJsonTests);
{$ELSE}
  RegisterTest(TDJsonTests.Suite);
{$ENDIF}
end.
