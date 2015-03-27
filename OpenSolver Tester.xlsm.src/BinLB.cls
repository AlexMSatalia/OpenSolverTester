VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "BinLB"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Function Test(Solver As String) As TestResult
    Me.Activate
    OpenSolver.ResetModel
    OpenSolver.SetDecisionVariables Me.Range("D5:F5")
    OpenSolver.SetObjectiveFunctionCell Me.Range("H9")
    OpenSolver.AddConstraint Me.Range("H11:H13"), RelationGE, Me.Range("J11:J13")
    OpenSolver.AddConstraint Me.Range("D5:F5"), RelationGE, Me.Range("E7")
    OpenSolver.AddConstraint Me.Range("F5"), RelationBIN
    OpenSolver.SetChosenSolver Solver
    OpenSolver.SetMaxIterations 2000
    
    Test = RunTest(Me, Solver)
End Function
