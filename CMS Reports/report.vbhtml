@code
    Response.ContentType = "text/html;charset=utf-8"
End Code

<html xmlns="http://www.w3.org/1999/xhtml" lang="en-us" id="doc">
<head >
    <link rel="stylesheet" href="content/site.css" />
    <meta name="viewport" content="width=device-width"/>
</head>
<body>
    @code
        ' Load reports file:
        Dim xmlReports As New System.Xml.XmlDocument
        xmlReports.Load(Server.MapPath("~/CMSCDR_Reports.xml"))

        ' set up SQL connection:
        Dim csc As ConnectionStringSettingsCollection = System.Web.Configuration.WebConfigurationManager.ConnectionStrings()
        Dim conn = New Data.SqlClient.SqlConnection
        conn.ConnectionString = csc.Item("CMS_CDRConnectionString").ConnectionString
        conn.Open()
        Dim sqlcmd As New Data.SqlClient.SqlCommand
        sqlcmd.Connection = conn

        ' set up Stored Procedure:
        Dim intID As Integer = Left(Request.Form.Get("id"), 4)
        Dim reportnode As System.Xml.XmlElement = xmlReports.SelectSingleNode("/reports/report[@id='" & intID.ToString & "']")
        PageData("Title") = reportnode.GetAttribute("name")
    End code
    <h1>@reportnode.GetAttribute("name")</h1>
    @code
        ' Assemble Stored Procedure:
        With sqlcmd
            '.CommandText = "spGetTopEndPoints"
            .CommandText = reportnode.GetAttribute("sp")
            .CommandType = Data.CommandType.StoredProcedure

            ' Add parameters of SP based on the Reports XML file, not on user input:
            .Parameters.Clear()
            Dim parameters As System.Xml.XmlNodeList = xmlReports.SelectNodes("/reports/report[@id=" & intID.ToString & "]/parameters/parameter")
            Dim parameter As System.Xml.XmlElement
            Dim strparam As String
            For Each parameter In parameters
                strparam = Left(Request.Form.Get(parameter.GetAttribute("p")), 36)  ' allows for POSTed parameter values up to 36 characters long (to accomodate GUIDs)
                .Parameters.AddWithValue(parameter.GetAttribute("p"), strparam)     ' adds attribute/value pair to stored procedure parameter
            Next
        End With

        ' Execute Stored Procedure into a dataset, datatable:
        Dim sda As New Data.SqlClient.SqlDataAdapter(sqlcmd)
        Dim ds As New Data.DataSet
        sda.Fill(ds)

        Dim dt As New System.Data.DataTable
        For Each dt In ds.Tables

    End code
    <table id="report">
        <tr>
            @code
                ' Build table based on returned dataset:
                Dim col As Data.DataColumn
                Dim row As Data.DataRow
                Dim cell As String

                ' Header row:
                For Each col In dt.Columns
            end code
            <th>@col.ColumnName</th>
            @code
                Next

                ' Data rows:
                For Each row In dt.Rows
            End code
        <tr>
            @code
                For Each col In dt.Columns
                    If col.DataType.Name = "DateTime" Then
                        ' Format for UTC:
                        cell = "<td>" & DateTime.SpecifyKind(row.Item(col.ColumnName), DateTimeKind.Utc).ToString("u") & "</td>"
                    ElseIf col.ColumnName = "Call ID" Then
                        ' Add ability to click Call ID for a detail report:
                        cell = "<td><a href=" & Chr(34) & "#" & Chr(34) & " onclick=" & Chr(34) & "CallID_onclick('" & row.Item(col.ColumnName).ToString & "')" & Chr(34) & ">" & row.Item(col.ColumnName).ToString & "</a></td>"
                    ElseIf col.ColumnName = "+Video" Then
                        ' Add a video icon to call legs that were video-enabled:
                        If row.Item(col.ColumnName) = 1 Then
                            cell = "<td style=" & Chr(34) & "text-align:center;" & Chr(34) & ">" & "<img src=" & Chr(34) & "Content/Enable-Camera_2-512.webp" & Chr(34) & " width=" & Chr(34) & "30" & Chr(34) & "height=" & Chr(34) & "30" & Chr(34) & "></td>"
                        Else
                            cell = "<td />"
                        End If
                    Else
                        cell = "<td>" & row.Item(col.ColumnName).ToString & "</td>"
                    End If
                    End code
                    @Html.Raw(cell)
                    @code
                        Next
            end code
        </tr>
        @code
            Next
        end code
    </table>
    @code
        Next
    End code

    <script>

        function CallID_onclick(callid) {
            console.log("CallID_onclick started with CallID: " + callid)

            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function () {
                if (this.readyState == 4 && this.status == 200) {
                    ///$("html").html(this.responseText);
                    ///document.write(this.response);
                    document.getElementById("doc").innerHTML = this.responseText;
                }
            };

            xhttp.open("POST", location.href.split('/').pop(), true);
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send("id=11&callid="+callid);   /// ID 11 indicates the Meeting Detail report
        }
    </script>

</body>
</html>