@Code
    PageData("Title") = "CMS Report Generator"
    'Layout = "Your Layout Page goes here"

    Dim xmlReports As New System.Xml.XmlDocument
    xmlReports.Load(Server.MapPath("~/CMSCDR_Reports.xml"))
    Dim reportnodes As System.Xml.XmlNodeList = xmlReports.SelectNodes("/reports/report[not(@disabled)]")
    Dim reportnode As System.Xml.XmlElement
    Dim parameters As System.Xml.XmlNodeList
    Dim parameter As System.Xml.XmlElement

End Code

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="stylesheet" href="content/site.css" />
    <meta name="viewport" content="width=device-width">
</head>
<body>

    <div class="header">
            <img class="position: absolute; left: 0px; top: 0px; z-index: -1;" src="~/Content/sign_in_logo.png" width="50" height="50"/>
            <h1>Cisco Meeting Server</h1>
            <h1>Report Generator</h1>
    </div>
    <div class="row">
        <div class="side">
            <h2>Reports</h2>
            <div class="navbar">
                @code For Each reportnode In reportnodes  end code
                <a href="#" onclick="showReport('@reportnode.GetAttribute("id")')">@reportnode.GetAttribute("name")</a>
                @code Next  End code
            </div>
        </div>
        <div class="main">
            <h2 class="rptfrm" id="rpt_0">Select a report</h2>
            @code For Each reportnode In reportnodes end code
            <div class="rptfrm hidden" id="rpt_@reportnode.GetAttribute("id")">
            <h2>Report Details</h2>
                <div class="row">
                    <div>
                        <div class="reportattribute">Name</div>
                        <div class="reportattribute">Description</div>
                    </div>
                    <div>
                        <div class="reportvalue">@reportnode.GetAttribute("name")</div>
                        <div class="reportvalue">@reportnode.GetAttribute("description")</div>
                    </div>
                </div>

                <h2> Report Parameters</h2>
                <form method="post" action="~/report.vbhtml" id="frm_@reportnode.GetAttribute("id")" target="_blank">
                    <input type="hidden" name="id" value="@reportnode.GetAttribute("id")"/>
                    @code
                        parameters = xmlReports.SelectNodes("/reports/report[@id=" + reportnode.GetAttribute("id") + "]/parameters/parameter")
                        For Each parameter In parameters
                    End code
                    <div class="row">
                        <div class="reportattribute"><label>@parameter.GetAttribute("name")</label></div>
                        <div class="reportvalue"><input name="@parameter.GetAttribute("p")" type="@parameter.GetAttribute("type")" /></div>
                    </div>
                    @code Next end code
                </form>
            </div>
            @code Next End code
        </div>
    </div>
    <div id="btnGo" class="footer" onclick="btnGo_onclick()">
Generate Report
    </div>

<script>
    function showReport(r) {
        //make all reports invisible:
        var x = document.getElementsByClassName("rptfrm");
        var z;
        for (z = 0; z < x.length; z++) {  // enumerate items
            x[z].className = "rptfrm hidden";
        }
        document.getElementById("rpt_" + r).className = "rptfrm";  //make designated report visible
        sessionStorage.setItem("r",r);
        console.log("set report ID to:" + r);
    }

    function btnGo_onclick() {
        var strForm = "frm_" + sessionStorage.getItem("r")
        console.log("attempting to submit form: " + strForm)
        console.log("Parameters:")
        var elements = document.getElementById(strForm).elements;
        for (z = 0; z < elements.length; z++) {
            console.log(elements[z].name + ":`" + elements[z].value + "`")
        }
        document.getElementById(strForm).submit();
    }

</script>

</body>
</html>
