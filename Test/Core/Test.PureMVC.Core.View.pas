﻿unit Test.PureMVC.Core.View;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  SysUtils,
  Classes,
  RTTI,
  TestFramework,
  PureMVC.Interfaces.IView,
  PureMVC.Interfaces.IMediator,
  PureMVC.Interfaces.Collections,
  PureMVC.Interfaces.IObserver,
  PureMVC.Interfaces.INotification,
  PureMVC.Patterns.Collections,
  PureMVC.Core.View;

type
  // Test methods for class TView

  TestTView = class(TTestCase)
  private
    ViewTestVars: TDictionary<string, Integer>;
  public // PureMVCHandle
    procedure ViewTestMethod(Note: INotification);
  public const
    NOTE1 = 'Notification1';
    NOTE2 = 'Notification2';
    NOTE3 = 'Notification3';
    NOTE4 = 'Notification4';
    NOTE5 = 'Notification5';
    NOTE6 = 'Notification6';
  public
    LastNotification: string;
    HandleNotificationCalls: Integer;
    OnRemoveCalls: Integer;
    OnRegisterCalls: Integer;
    procedure SetUp; override;
    procedure TearDown; override;
    function OnRegisterCalled: Boolean;
    function OnRemoveCalled: Boolean;
  published
    procedure TestGetInstance;
    procedure RegisterAndNotifyObserver;
    procedure RegisterAndRetrieveMediator;
    procedure HasMediator;
    procedure RegisterAndRemoveMediator;
    procedure OnRegisterAndOnRemove;
    procedure SuccessiveRegisterAndRemoveMediator;
    procedure RemoveMediatorAndSubsequentNotify;
    procedure RemoveOneOfTwoMediatorsAndSubsequentNotify;
    procedure MediatorReregistration;
    procedure ModifyObserverListDuringNotification;
  end;

implementation

uses
  StrUtils,
  PureMVC.Patterns.Notification,
  PureMVC.Patterns.Observer,
  PureMVC.Patterns.Mediator;

type
  TViewTestNote = class(TNotification, INotification)
  public const
    NAME = 'ViewTestNote';
  public
    constructor Create(Sender: TObject; ThreadName: string; Body: TValue);
  end;

  TViewTestMediator = class(TMediator, IMediator)
  private
    FInterests: TArray<string>;
    procedure SetDefaultInterests; overload;
    procedure SetDefaultInterests(Values: array of string); overload;
  public const
    NAME = 'ViewTestMediator';
  public
    constructor Create(View: TObject); overload;
    constructor Create(View: TObject; Interests: array of string); overload;
    constructor Create(ThreadName: string; View: TObject); overload;
    constructor Create(ThreadName: string; View: TObject;
      Interests: array of string); overload;
    function ListNotificationInterests: IList<string>; override;
    function ViewTest: TestTView;
    procedure HandleNotification(Notification: INotification); override;
    procedure OnRegister; override;
    procedure OnRemove; override;
  end;

  { TViewTestNote }

constructor TViewTestNote.Create(Sender: TObject; ThreadName: string;
  Body: TValue);
begin
  inherited Create(NAME + ThreadName, Sender, Body);
end;

{ TViewTestMediator }

procedure TViewTestMediator.SetDefaultInterests;
const
  DefaultInterests: array [0 .. 2] of string = ('ABC', 'DEF', 'GHI');
begin
  SetDefaultInterests(DefaultInterests);
end;

procedure TViewTestMediator.SetDefaultInterests(Values: array of string);
var
  idx: Integer;
begin
  inherited;
  Setlength(FInterests, Length(Values));
  for idx := Low(Values) to High(Values) do
    FInterests[idx] := Values[idx];
end;

constructor TViewTestMediator.Create(ThreadName: string; View: TObject;
  Interests: array of string);
begin
  inherited Create(NAME + ThreadName, View);
  SetDefaultInterests(Interests);
end;

constructor TViewTestMediator.Create(ThreadName: string; View: TObject);
begin
  inherited Create(NAME + ThreadName, View);
  SetDefaultInterests;
end;

constructor TViewTestMediator.Create(View: TObject; Interests: array of string);
begin
  inherited Create(NAME, View);
  SetDefaultInterests(Interests);
end;

constructor TViewTestMediator.Create(View: TObject);
begin
  inherited Create(NAME, View);
  SetDefaultInterests;
end;

procedure TViewTestMediator.HandleNotification(Notification: INotification);
begin
  inherited HandleNotification(Notification);
  ViewTest.LastNotification := Notification.Name;
  Inc(ViewTest.HandleNotificationCalls);
  // auto remove if TestTView.NOTE6 is received
  if (Notification.Name = TestTView.NOTE6) then
			Facade.RemoveMediator(MediatorName);
end;

function TViewTestMediator.ListNotificationInterests: IList<string>;
begin
  Result := TList<string>.Create;
  Result.AddRange(FInterests);
end;

procedure TViewTestMediator.OnRegister;
begin
  Inc(ViewTest.OnRegisterCalls);
end;

procedure TViewTestMediator.OnRemove;
begin
  Inc(ViewTest.OnRemoveCalls);
end;

function TViewTestMediator.ViewTest: TestTView;
begin
  Result := ViewComponent as TestTView;
end;

{ TestTView }

procedure TestTView.SetUp;
begin
  ViewTestVars := TDictionary<string, Integer>.Create;
end;

procedure TestTView.TearDown;
begin
  ViewTestVars.Free;
end;

procedure TestTView.TestGetInstance;
var
  View: IView;
begin
  View := TView.Instance;
  CheckNotNull(View, 'TView.Instance is null');
  CheckTrue(Supports(View, IView), 'Expecting instance implements IView');
end;

procedure TestTView.ViewTestMethod(Note: INotification);
var
  Name: string;
begin
  Name := IntToStr(TThread.CurrentThread.ThreadID);
  ViewTestVars.Remove(Name);
  ViewTestVars.Add(Name, Note.Body.asInteger);
end;

procedure TestTView.RegisterAndNotifyObserver;
var
  View: IView;
  Observer: IObserver;
  Name: string;
  Note: INotification;
begin
  View := TView.Instance;
  Observer := TObserver.Create('ViewTestMethod', Self);
  Name := IntToStr(TThread.CurrentThread.ThreadID);
  ViewTestVars.Remove(name);
  View.RegisterObserver(TViewTestNote.Name + name, Observer);
  // Create a ViewTestNote, setting
  // a body value, and tell the View to notify
  // Observers. Since the Observer is this class
  // and the notification method is viewTestMethod,
  // successful notification will result in our local
  // viewTestVar being set to the value we pass in
  // on the note body.
  Note := TViewTestNote.Create(Self, Name, 10);
  View.NotifyObservers(Note);

  CheckTrue(ViewTestVars.ContainsKey(Name));
  CheckEquals(10, ViewTestVars[name]);
  ViewTestVars.Remove(name);
  View.RemoveObserver(TViewTestNote.Name + Name, Self);
end;

procedure TestTView.RegisterAndRetrieveMediator;
var
  View: IView;
  Mediator: IMediator;
  ViewTestMediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  Name := IntToStr(TThread.CurrentThread.ThreadID);
  ViewTestMediator := TViewTestMediator.Create(Name, Self);
  Name := ViewTestMediator.MediatorName;
  View.RegisterMediator(ViewTestMediator);
  Mediator := View.RetrieveMediator(Name);
  CheckTrue(Mediator is TViewTestMediator);
  View.RemoveMediator(Name);
end;

procedure TestTView.HasMediator;
var
  View: IView;
  Mediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  Name := 'HasMediatorTest' + IntToStr(TThread.CurrentThread.ThreadID);
  Mediator := TMediator.Create(Name, Self);
  View.RegisterMediator(Mediator);
  CheckTrue(View.HasMediator(Name));
  View.RemoveMediator(Name);
  CheckFalse(View.HasMediator(Name));
end;

procedure TestTView.RegisterAndRemoveMediator;
var
  View: IView;
  RemovedMediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  Name := 'Testing' + IntToStr(TThread.CurrentThread.ThreadID);

  View.RegisterMediator(TMediator.Create(Name, Self));
  RemovedMediator := View.RemoveMediator(Name);

  CheckEquals(Name, RemovedMediator.MediatorName);
  CheckNull(View.RetrieveMediator(Name));
end;

procedure TestTView.OnRegisterAndOnRemove;
var
  View: IView;
  Mediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  // Create and register the test mediator
  Mediator := TViewTestMediator.Create(Self);
  Name := Mediator.MediatorName;
  View.RegisterMediator(Mediator);

  CheckTrue(OnRegisterCalled);
  View.RemoveMediator(name);
  CheckTrue(OnRemoveCalled);
end;

function TestTView.OnRegisterCalled: Boolean;
begin
  Result := OnRegisterCalls > 0;
end;

function TestTView.OnRemoveCalled: Boolean;
begin
  Result := OnRemoveCalls > 0;
end;

procedure TestTView.SuccessiveRegisterAndRemoveMediator;
var
  View: IView;
  ViewTestMediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  Name := IntToStr(TThread.CurrentThread.ThreadID);
  ViewTestMediator := TViewTestMediator.Create(Name, Self);
  Name := ViewTestMediator.MediatorName;
  View.RegisterMediator(ViewTestMediator);
  CheckTrue(View.RetrieveMediator(Name) is TViewTestMediator);

  View.RemoveMediator(Name);

  CheckNull(View.RetrieveMediator(Name));

  // test that removing the mediator again once its gone doesn't cause crash
  try
    View.RemoveMediator(Name);
  except
    Check(False,
      'Expecting View.RemoveMediator(TViewTestMediator.NAME ) doesn''t crash');
  end;

  // Create and register another instance of the test mediator,
  Name := IntToStr(TThread.CurrentThread.ThreadID);
  ViewTestMediator := TViewTestMediator.Create(Name, Self);
  Name := ViewTestMediator.MediatorName;
  View.RegisterMediator(ViewTestMediator);
  CheckTrue(View.RetrieveMediator(Name) is TViewTestMediator);
  // Remove the Mediator
  View.RemoveMediator(Name);
  // test that retrieving it now returns null
  CheckNull(View.RetrieveMediator(Name));
end;

procedure TestTView.RemoveMediatorAndSubsequentNotify;
var
  View: IView;
  ViewTestMediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  // Create and register the test mediator to be removed.
  View.RegisterMediator(TViewTestMediator.Create(Self, [NOTE1, NOTE2]));

  // Create and register the Mediator to remain
  Name := IntToStr(TThread.CurrentThread.ThreadID);
  ViewTestMediator := TViewTestMediator.Create(Name, Self);
  Name := ViewTestMediator.MediatorName;
  View.RegisterMediator(ViewTestMediator);

  // test that notifications work
  View.NotifyObservers(TNotification.Create(NOTE1));
  CheckEquals(NOTE1, LastNotification);

  View.NotifyObservers(TNotification.Create(NOTE2));
  CheckEquals(NOTE2, LastNotification);

  // Remove the Mediator
  View.RemoveMediator(TViewTestMediator.Name);

  // test that retrieving it now returns null
  CheckNull(View.RetrieveMediator(TViewTestMediator.Name));

  LastNotification := '';

  View.NotifyObservers(TNotification.Create(NOTE1));
  CheckNotEquals(NOTE1, LastNotification);

  View.NotifyObservers(TNotification.Create(NOTE2));
  CheckNotEquals(NOTE2, LastNotification);
  View.RemoveMediator(Name);
end;

procedure TestTView.RemoveOneOfTwoMediatorsAndSubsequentNotify;
var
  View: IView;
  ViewTestMediator: IMediator;
  Name: string;
begin
  View := TView.Instance;
  // Create and register that responds to notifications 1, 2
  ViewTestMediator := TViewTestMediator.Create('[1,2]', Self, [NOTE1, NOTE2]);
  View.RegisterMediator(ViewTestMediator);
  Name := ViewTestMediator.MediatorName;

  // Create and register that responds to notification 3
  View.RegisterMediator(TViewTestMediator.Create('[3]', Self, [NOTE3]));

  // test that all notifications work
  View.NotifyObservers(TNotification.Create(NOTE1));
  CheckEquals(LastNotification, NOTE1);

  View.NotifyObservers(TNotification.Create(NOTE2));
  CheckEquals(LastNotification, NOTE2);

  View.NotifyObservers(TNotification.Create(NOTE3));
  CheckEquals(LastNotification, NOTE3);

  // Remove the Mediator that responds to 1 and 2
  View.RemoveMediator(Name);

  // test that retrieving it now returns null
  CheckNull(View.RetrieveMediator('ViewTestMediator_1_2'));

  // test that notifications no longer work
  // for notifications 1 and 2, but still work for 3
  LastNotification := '';

  View.NotifyObservers(TNotification.Create(NOTE1));
  CheckNotEquals(NOTE1, LastNotification);

  View.NotifyObservers(TNotification.Create(NOTE2));
  CheckNotEquals(NOTE2, LastNotification);

  View.NotifyObservers(TNotification.Create(NOTE3));
  CheckEquals(NOTE3, LastNotification);

  // Remove the Mediator that responds to 3
  CheckNotNull(View.RemoveMediator(TViewTestMediator.Name + '[3]'));
end;

  {
    Tests registering the same mediator twice.
    A subsequent notification should only illicit
    one response. Also, since reregistration
    was causing 2 observers to be created, ensure
    that after removal of the mediator there will
    be no further response.

    Added for the fix deployed in version 2.0.4
  }

procedure TestTView.MediatorReregistration;
var
  View: IView;
  Name: string;
begin
  View := TView.Instance;
    // Create and register that responds to notification 5
  View.RegisterMediator(TViewTestMediator.Create('[5]', Self, [NOTE5]));
    // try to register another instance of that mediator (uses the same MediatorName).
  View.RegisterMediator(TViewTestMediator.Create('[5]', Self, [NOTE5]));

  // test that the counter is only incremented once (mediator 5's response)
  HandleNotificationCalls := 0;
  View.NotifyObservers(TNotification.Create(NOTE5) );
  CheckEquals(1, HandleNotificationCalls);

  Name := TViewTestMediator.NAME + '[5]';
    // Remove the Mediator
  View.RemoveMediator( Name );

    // test that retrieving it now returns null
    CheckNull(View.RetrieveMediator(Name ));

    // test that the counter is no longer incremented
    HandleNotificationCalls := 0;
    view.NotifyObservers(TNotification.Create(NOTE5));
    CheckEquals(0, HandleNotificationCalls);
end;

  {
    Tests the ability for the observer list to
    be modified during the process of notification,
    and all observers be properly notified. This
    happens most often when multiple Mediators
    respond to the same notification by removing
    themselves.

    Added for the fix deployed in version 2.0.4
  }

procedure TestTView.ModifyObserverListDuringNotification;
var
  View: IView;
  idx: integer;
begin
  View := TView.Instance;
    // Create and register several mediator instances that respond to notification 6
    // by removing themselves, which will cause the observer list for that notification
    // to change. versions prior to Standard Version 2.0.4 will see every other mediator
    // fails to be notified.
  for idx := 1 to 8 do
    View.RegisterMediator(TViewTestMediator.Create('/' + IntToStr(idx), Self, [NOTE6]));

    // clear the counter
    OnRemoveCalls := 0;
    // send the notification. each of the above mediators will respond by removing
    // themselves and incrementing the counter by 1. This should leave us with a
    // count of 8, since 8 mediators will respond.
    View.NotifyObservers(TNotification.Create(NOTE6));
    // verify the count is correct
    CheckEquals(8, OnRemoveCalls);

    // clear the counter
    OnRemoveCalls := 0;
    View.NotifyObservers(TNotification.Create(NOTE6));
    // verify the count is 0
    CheckEquals(0, OnRemoveCalls);
end;

initialization

// Register any test cases with the test runner
RegisterTest(TestTView.Suite);

end.
