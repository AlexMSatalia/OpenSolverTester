VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SensitivityNames"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Function Test(Solver As String) As TestResult
    Me.Activate
    OpenSolver.ResetModel
    OpenSolver.SetDecisionVariables Union(Me.Range("D14:H16"), Me.Range("J21"))
    OpenSolver.SetObjectiveFunctionCell Me.Range("D20")
    OpenSolver.AddConstraint Me.Range("I14:I16"), RelationLE, Me.Range("J14:J16")
    OpenSolver.AddConstraint Me.Range("D17:H17"), RelationEQ, Me.Range("D18:H18")
    OpenSolver.SetChosenSolver Solver
    
    OpenSolver.SetDualsNewSheet True
    OpenSolver.SetUpdateSensitivity True
    OpenSolver.SetMaxIterations 2000
    
    Test = RunTest(Me, Solver)
    Test = TestSensitivity(Test, Solver)
    
    If Test <> Pass Then Exit Function
    
    OpenSolver.SetNonNegativity False
    OpenSolver.AddConstraint Me.Range("D14:H16"), RelationGE, RHSFormula:="0"
    
    Test = RunTest(Me, Solver)
    Test = TestSensitivity(Test, Solver)
End Function

Private Function TestSensitivity(Test As TestResult, Solver As String) As TestResult
    If SolverHasSensitivityAnalysis(Solver) Then
        Dim SensitivitySheet As Worksheet
        On Error GoTo ErrorHandler
        Set SensitivitySheet = Sheets(Me.Name & " Sensitivity")
        On Error GoTo 0
        
        ' VARIABLES
        ' Check names
        If SensitivitySheet.Range("C7").Value <> "KWR AUCK" Or _
           SensitivitySheet.Range("C8").Value <> "KWR SYD" Or _
           SensitivitySheet.Range("C9").Value <> "KWR MEL" Or _
           SensitivitySheet.Range("C10").Value <> "KWR BRI" Or _
           SensitivitySheet.Range("C11").Value <> "KWR ADEL" Or _
           SensitivitySheet.Range("C12").Value <> "BYR AUCK" Or _
           SensitivitySheet.Range("C13").Value <> "BYR SYD" Or _
           SensitivitySheet.Range("C14").Value <> "BYR MEL" Or _
           SensitivitySheet.Range("C15").Value <> "BYR BRI" Or _
           SensitivitySheet.Range("C16").Value <> "BYR ADEL" Or _
           SensitivitySheet.Range("C17").Value <> "ALB AUCK" Or _
           SensitivitySheet.Range("C18").Value <> "ALB SYD" Or _
           SensitivitySheet.Range("C19").Value <> "ALB MEL" Or _
           SensitivitySheet.Range("C20").Value <> "ALB BRI" Or _
           SensitivitySheet.Range("C21").Value <> "ALB ADEL" Or _
           SensitivitySheet.Range("C22").Value <> "SPARE" Then
            Test = Fail
        End If
        ' Check increases
        If Not OpenSolver.IsZero(SensitivitySheet.Range("G7").Value - 35) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G8").Value - 10) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G13").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G14").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G15").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G18").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G21").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("G22").Value - 0) Then
            Test = Fail
        End If
        ' Check decreases
        If Not OpenSolver.IsZero(SensitivitySheet.Range("H8").Value - 10) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H9").Value - 15) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H10").Value - 10) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H11").Value - 25) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H12").Value - 35) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H13").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H16").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H17").Value - 55) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H18").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H19").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H20").Value - 5) Or _
           Not OpenSolver.IsZero(SensitivitySheet.Range("H22").Value - 0) Then
            Test = Fail
        End If
        
        ' CONSTRAINTS
        ' Check names
        If SensitivitySheet.Range("C26").Value <> "KWR Total" Or _
           SensitivitySheet.Range("C27").Value <> "BYR Total" Or _
           SensitivitySheet.Range("C28").Value <> "ALB Total" Or _
           SensitivitySheet.Range("C29").Value <> "Total AUCK" Or _
           SensitivitySheet.Range("C30").Value <> "Total SYD" Or _
           SensitivitySheet.Range("C31").Value <> "Total MEL" Or _
           SensitivitySheet.Range("C32").Value <> "Total BRI" Or _
           SensitivitySheet.Range("C33").Value <> "Total ADEL" Then
            Test = Fail
        End If
        ' Check shadow prices
        If SensitivitySheet.Range("E26").Value <> 0 Or _
           SensitivitySheet.Range("E27").Value <> -10 Or _
           SensitivitySheet.Range("E28").Value <> -20 Or _
           SensitivitySheet.Range("E29").Value <> 10 Or _
           SensitivitySheet.Range("E30").Value <> 30 Or _
           SensitivitySheet.Range("E31").Value <> 25 Or _
           SensitivitySheet.Range("E32").Value <> 30 Or _
           SensitivitySheet.Range("E33").Value <> 35 Then
            Test = Fail
        End If
        ' Check increases
        If SensitivitySheet.Range("G27").Value <> 100 Or _
           SensitivitySheet.Range("G28").Value <> 100 Or _
           SensitivitySheet.Range("G29").Value <> 0 Or _
           SensitivitySheet.Range("G30").Value <> 0 Or _
           SensitivitySheet.Range("G31").Value <> 0 Or _
           SensitivitySheet.Range("G32").Value <> 0 Or _
           SensitivitySheet.Range("G33").Value <> 0 Then
            Test = Fail
        End If
        ' Check decreases
        If SensitivitySheet.Range("H26").Value <> 0 Or _
           SensitivitySheet.Range("H27").Value <> 0 Or _
           SensitivitySheet.Range("H28").Value <> 0 Or _
           SensitivitySheet.Range("H29").Value <> 100 Or _
           SensitivitySheet.Range("H30").Value <> 100 Or _
           SensitivitySheet.Range("H31").Value <> 100 Or _
           SensitivitySheet.Range("H32").Value <> 100 Or _
           SensitivitySheet.Range("H33").Value <> 100 Then
            Test = Fail
        End If
    
        Application.DisplayAlerts = False
        SensitivitySheet.Delete
        Application.DisplayAlerts = True
    End If
    TestSensitivity = Test
    Exit Function
    
ErrorHandler:
    TestSensitivity = Fail
End Function



