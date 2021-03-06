VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SeekObj"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Function Test(Solver As String) As TestResult
    OpenSolver.ResetModel Me
    OpenSolver.SetDecisionVariables Me.Range("D2:F2"), Me
    OpenSolver.SetObjectiveFunctionCell Me.Range("G4"), Me
    OpenSolver.AddConstraint Me.Range("G6"), RelationEQ, Me.Range("I6"), sheet:=Me
    OpenSolver.AddConstraint Me.Range("G7"), RelationGE, Me.Range("I7"), sheet:=Me
    OpenSolver.AddConstraint Me.Range("G8:G9"), RelationLE, Me.Range("I8:I9"), sheet:=Me
    OpenSolver.SetChosenSolver Solver, Me
    
    OpenSolver.SetObjectiveSense TargetObjective, Me
    OpenSolver.SetObjectiveTargetValue 50, Me
    OpenSolver.SetDualsOnSheet True, Me
    OpenSolver.SetUpdateSensitivity True, Me
    
    Test = RunTest(Me, Solver)
    If SensitivityAnalysisAvailable(CreateSolver(Solver)) Then
        Dim SensitivitySheet As Worksheet
        On Error GoTo ErrorHandler
        Set SensitivitySheet = Sheets(Me.Name & " Sensitivity")
        On Error GoTo 0
        
        If SensitivitySheet.Range("E7").Value <> 0 Or _
           SensitivitySheet.Range("E8").Value <> 0 Or _
           SensitivitySheet.Range("E9").Value <> 0 Or _
           SensitivitySheet.Range("E13").Value <> 0 Or _
           SensitivitySheet.Range("E14").Value <> 0 Or _
           SensitivitySheet.Range("E15").Value <> 0 Or _
           SensitivitySheet.Range("E16").Value <> 0 Or _
           SensitivitySheet.Range("F13").Value <> 350 Or _
           SensitivitySheet.Range("F14").Value <> 100 Or _
           SensitivitySheet.Range("F15").Value <> 0 Or _
           SensitivitySheet.Range("F16").Value <> 72 Or _
           SensitivitySheet.Range("G13").Value <> 0 Or _
           SensitivitySheet.Range("G14").Value <> 0 Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H13").Value - 166.66666667) Or _
           SensitivitySheet.Range("H14").Value <> 100 Or _
           SensitivitySheet.Range("H15").Value <> 500 Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H16").Value - 72) Then
            Test = Fail
        End If
    
        Application.DisplayAlerts = False
        SensitivitySheet.Delete
        Application.DisplayAlerts = True
    End If
    Exit Function
    
ErrorHandler:
    Test = Fail
End Function


