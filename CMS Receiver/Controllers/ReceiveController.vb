Imports System.Net
Imports System.Web.Http

Public Class ReceiveController
    Inherits ApiController

    ' GET api/<controller>
    Public Function GetValues() As IEnumerable(Of String)
        Return New String() {"value1", "value2"}
    End Function

    ' GET api/<controller>/5
    Public Function GetValue(ByVal id As Integer) As String
        Return "value"
    End Function

    ' POST api/<controller>
    Public Function PostValue()
        Dim z = Request.Content.ReadAsStringAsync.Result
        Dim sp = New DataSet1TableAdapters.QueriesTableAdapter

        Dim unused = sp.spLoadRawRecords(z)
        'Return value

        Return Ok(z)

    End Function

    ' PUT api/<controller>/5
    Public Sub PutValue(ByVal id As Integer, <FromBody()> ByVal value As String)

    End Sub

    ' DELETE api/<controller>/5
    Public Sub DeleteValue(ByVal id As Integer)

    End Sub
End Class
