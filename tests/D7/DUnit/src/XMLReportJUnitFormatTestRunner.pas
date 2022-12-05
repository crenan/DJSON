(*
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is DUnit.
 *
 * The Initial Developers of the Original Code are Kent Beck, Erich Gamma,
 * and Juancarlo Añez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2003.
 * All rights reserved.
 *
 * Contributor(s):
 * Kent Beck <kentbeck@csi.com>
 * Erich Gamma <Erich_Gamma@oti.com>
 * Juanco Añez <juanco@users.sourceforge.net>
 * Chris Morris <chrismo@users.sourceforge.net>
 * Jeff Moore <JeffMoore@users.sourceforge.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 *
 *)

{
  Contributor : Carlos Silveira <carlos.renan.silveira@gmail.com> 
}

unit XMLReportJUnitFormatTestRunner;

interface

uses
  SysUtils, Classes, XMLIntf, XMLDoc, TestFramework;

const
   DEFAULT_FILENAME = 'TestResult.xml';

type
  TXMLReportJUnitFormat = class(TInterfacedObject, ITestListener, ITestListenerX)
  private
    FXMLReport: IXMLDocument;
    FCurrentNode: IXMLNode;
    FFileName: String;
  protected
    FStartTime: TDateTime;
    procedure WriteReport(str: String);
  public
    // IStatusListener interface implementation
    procedure Status(test: ITest; const Msg: string);
    // ITestListener interface implementation
    procedure TestingStarts;
    procedure StartTest(test: ITest);
    procedure AddSuccess(test: ITest);
    procedure AddError(error: TTestFailure);
    procedure AddFailure(Failure: TTestFailure);
    procedure EndTest(test: ITest);
    procedure TestingEnds(testResult: TTestResult);
    function  ShouldRunTest(test: ITest): Boolean;
    // ITestListenerX interface implementation
    procedure StartSuite(suite: ITest);
    procedure EndSuite(suite: ITest);
    // TXMLReportJUnitFormat implementation
    procedure Warning(test :ITest; const Msg :string);

    constructor Create(AOutputFile: String);
    destructor Destroy; override;
  end;

{
  Run the given test suite
}
function RunTest(suite: ITest; AOutputFile: String = DEFAULT_FILENAME): TTestResult; overload;
function RunRegisteredTests(AOutputFile: String = DEFAULT_FILENAME): TTestResult; overload;

implementation

const
   MAX_DEEP = 5;

function RunTest(suite: ITest; AOutputFile: String = DEFAULT_FILENAME): TTestResult;
begin
  Result := TestFramework.RunTest(suite, [TXMLReportJUnitFormat.Create(AOutputFile)]);
end;

function RunRegisteredTests(AOutputFile: String = DEFAULT_FILENAME): TTestResult;
begin
  Result := RunTest(RegisteredTests, AOutputFile);
end;

{ TXMLReportJUnitFormat }

{
  Write F in the report file or on standard output if none specified
}
procedure TXMLReportJUnitFormat.WriteReport(str: String);
begin
//  if TTextRec(FFile).Mode = fmOutput then
//    Writeln(FFile, str)
//  else
//    Writeln(str);
end;

procedure TXMLReportJUnitFormat.Status(test: ITest; const Msg: string);
begin
//  WriteReport(Format('INFO: %s: %s', [test.Name, Msg]));
end;

procedure TXMLReportJUnitFormat.TestingStarts;
begin
  FStartTime := Now;
  FXMLReport := TXMLDocument.Create(nil);
  FXMLReport.Active := True;
  FXMLReport.Version := '1.0';
  FXMLReport.Encoding := 'utf-8';
  FXMLReport.StandAlone := 'no';
//   WriteReport('<?xml version="1.0" encoding="ISO-8859-1" standalone="yes" ?>'+sLineBreak+
//                  '<TestRun>');
end;

procedure TXMLReportJUnitFormat.StartTest(test: ITest);
begin

end;

procedure TXMLReportJUnitFormat.AddSuccess(test: ITest);
begin
//  if test.tests.Count<=0 then
//  begin
//    WriteReport('<Test name="'+test.GetName+'" result="PASS">'+sLineBreak+
//                '</Test>');
//  end;
end;

procedure TXMLReportJUnitFormat.AddError(error: TTestFailure);
begin
//   WriteReport('<Test name="'+error.FailedTest.GetName+'" result="ERROR">'+sLineBreak+
//                  '<FailureType>'+error.ThrownExceptionName+'</FailureType>'+sLineBreak+
//                  '<Location>'+error.LocationInfo+'</Location>'+sLineBreak+
//                  '<Message>'+text2sgml(error.ThrownExceptionMessage)+'</Message>'+sLineBreak+
//                  '</Test>');
end;

procedure TXMLReportJUnitFormat.AddFailure(failure: TTestFailure);
begin
//   WriteReport('<Test name="'+failure.FailedTest.GetName+'" result="FAILS">'+sLineBreak+
//                  '<FailureType>'+failure.ThrownExceptionName+'</FailureType>'+sLineBreak+
//                  '<Location>'+failure.LocationInfo+'</Location>'+sLineBreak+
//                  '<Message>'+text2sgml(failure.ThrownExceptionMessage)+'</Message>'+sLineBreak+
//                  '</Test>');
end;

procedure TXMLReportJUnitFormat.EndTest(test: ITest);
begin

end;

procedure TXMLReportJUnitFormat.TestingEnds(testResult: TTestResult);
//var
//  runTime : TDateTime;
//  successRate : Integer;
begin
//  runTime := now-FStartTime;
//  successRate :=  Trunc(
//  ((testResult.runCount - testResult.failureCount - testResult.errorCount)
//  /testResult.runCount)
//  *100);
//
//  WriteReport('<Statistics>'+sLineBreak+
//  '<Stat name="Tests" result="'+intToStr(testResult.runCount)+'" />'+sLineBreak+
//  '<Stat name="Failures" result="'+intToStr(testResult.failureCount)+'" />'+sLineBreak+
//  '<Stat name="Errors" result="'+intToStr(testResult.errorCount)+'" />'+sLineBreak+
//  '<Stat name="Success Rate" result="'+intToStr(successRate)+'%" />'+sLineBreak+
//  '<Stat name="Finished At" result="'+DateTimeToStr(now)+'" />'+sLineBreak+
//  '<Stat name="Runtime" result="'+timeToStr(runTime)+'" />'+sLineBreak+
//  '</Statistics>'+sLineBreak+
//  '</TestRun>');
//
//  if TTextRec(FFile).Mode = fmOutput then
//  Close(FFile);
end;

function TXMLReportJUnitFormat.ShouldRunTest(test: ITest): boolean;
begin
  Result := test.Enabled;
end;

procedure TXMLReportJUnitFormat.StartSuite(suite: ITest);
begin
//  WriteReport('<TestSuite name="'+suite.getName+'">');
end;

procedure TXMLReportJUnitFormat.EndSuite(suite: ITest);
begin
//  WriteReport('</TestSuite>');
end;

procedure TXMLReportJUnitFormat.Warning(test :ITest; const Msg :string);
begin
//  WriteReport(Format('WARNING: %s: %s', [test.Name, Msg]));
end;

constructor TXMLReportJUnitFormat.Create(AOutputFile: String);
begin
  inherited Create;
  FFileName := AOutputFile;
  FXMLReport := TXMLDocument.Create(nil);
end;

destructor TXMLReportJUnitFormat.Destroy;
begin
  FXMLReport.Free;
  inherited;
end;

end.
