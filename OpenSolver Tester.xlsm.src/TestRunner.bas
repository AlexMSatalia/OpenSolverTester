Attribute VB_Name = "TestRunner"
Option Explicit

Enum TestResult
    Pass = 1
    Fail = 0
    NA = -1
    WhitelistPass = 11
    WhitelistFail = 10
    WhitelistNA = 9
End Enum

Function MarkWhitelist(Result As TestResult) As TestResult
    Select Case Result
    Case Pass: MarkWhitelist = WhitelistPass
    Case Fail: MarkWhitelist = WhitelistFail
    Case NA:   MarkWhitelist = WhitelistNA
    End Select
End Function

Sub LaunchForm()
   TestSelector.Show
End Sub

' Test Runner for testing sheet.
' All tests should have the testing column as Column A on the sheet. These cells control the
' parameters for testing each sheet.
'
' Model Type determines which solvers are tested on the problem - linear solvers are only tested on
' linear problems, while non-linear solvers are tested on all problems.
'
' Parameters specified in the testing column for Normal test:
'     - CorrectResult, takes value TRUE if solver output on sheet is as expected.
'     - ExpectedResult, specifies the OpenSolver code that should be returned.

Sub RunAllTests(Optional Clear As Boolean = False)
    Application.Calculation = xlCalculationManual
    
    Dim ListCount As Integer
    
    ' Get linear solvers
    Dim SolversPresent As Collection
    Set SolversPresent = New Collection
    With TestSelector.lstLinearSolvers
        For ListCount = 0 To .ListCount - 1
            If .Selected(ListCount) Then
                SolversPresent.Add .List(ListCount), CStr(.List(ListCount))
            End If
        Next ListCount
    End With

    ' Get non-linear solvers
    With TestSelector.lstNonLinearSolvers
        For ListCount = 0 To .ListCount - 1
            If .Selected(ListCount) Then
                SolversPresent.Add .List(ListCount), CStr(.List(ListCount))
            End If
        Next ListCount
    End With
    
    ' Set up results sheet
    Dim Solver As Variant, ProblemType As String, Result As Variant
    Dim RowBase As Integer, j As Integer
    RowBase = 2
    j = 0
    If Clear Then
        Sheets("Results").Cells.ClearContents
    End If
    Sheets("Results").Cells(1, 3).Value = "Tests marked with * are expected to fail. Look at the test whitelist module for info on why they should fail"
    SetResultCell 1, j, "Test"
    
    For Each Solver In OpenSolver.GetAvailableSolvers
        j = j + 1
        SetResultCell 1, j, Solver
    Next Solver
    
    Dim SheetName As String, listIndex As Integer
    With TestSelector.lstTests
        For listIndex = 0 To .ListCount - 1
            ' Add test to results sheet
            SheetName = .List(listIndex)
            j = 0
            SetResultCell RowBase + listIndex, j, "=HYPERLINK(""[OpenSolver Tester.xlsm]'" & SheetName & "'!A1"", """ & SheetName & """)"
            
            ' Exit if not selected
            If .Selected(listIndex) = False Then
                GoTo NextSheet
            End If
            
            Sheets(SheetName).Activate
            
            ' Read problem type and test the appropriate solvers for each test
            ProblemType = Sheets(.List(listIndex)).Cells(4, 1)
            For Each Solver In OpenSolver.GetAvailableSolvers
                j = j + 1
                If TestKeyExists(SolversPresent, CStr(Solver)) Then
                    SetResultCell RowBase + listIndex, j, FormatResult(ApiTest(SheetName, CStr(Solver)), CStr(Solver), Sheets(SheetName))
                End If
                DoEvents
            Next Solver
        
NextSheet:
        Next listIndex
    End With
    Application.Calculation = xlCalculationAutomatic
    Sheets("Results").Activate
End Sub

Function RunTest(sheet As Worksheet, Solver As String, Optional SolveRelaxation As Boolean = False) As TestResult
    If sheet.Range("A4") = "Non-linear" And SolverType(Solver) = OpenSolver_SolverType.Linear Then
        RunTest = NormalTest.NonLinearityTest(sheet)
    Else
        RunTest = NormalTest.NormalTest(sheet, SolveRelaxation)
    End If
End Function

Sub SetResultCell(i As Integer, j As Integer, Result As Variant)
    Sheets("Results").Cells(1 + i, 1 + j).Value = Result
End Sub

Function FormatResult(Result As TestResult, Solver As String, sheet As Worksheet)
    If TestShouldFail(sheet.Name, Solver) Then
        Result = MarkWhitelist(Result)
    End If
    
    Select Case Result
    Case Pass:            FormatResult = "PASS"
    Case WhitelistPass:   FormatResult = "PASS*"
    Case Fail:            FormatResult = "FAIL"
    Case WhitelistFail:   FormatResult = "FAIL*"
    Case NA, WhitelistNA: FormatResult = "NA"
    Case Else:            FormatResult = Result
    End Select
End Function

