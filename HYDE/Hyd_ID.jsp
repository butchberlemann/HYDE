<%@ page language="java"
         errorPage="../../error.jsp"
         import="org.csu.gis.*, org.csu.util.*, java.text.*, java.sql.*, org.xml.sax.*, org.w3c.dom.*"
%>
<%

 HtmlHelper HTML = new HtmlHelper(out);

 long mapHeight = JSPHelper.getRequestLong(request, "mapheight");
 long mapWidth = JSPHelper.getRequestLong(request, "mapwidth");
 double mapX = JSPHelper.getRequestDouble(request, "mapx");
 double mapY = JSPHelper.getRequestDouble(request, "mapy");
 double mapLeft = JSPHelper.getRequestDouble(request, "l");
 double mapBottom = JSPHelper.getRequestDouble(request, "b");
 double mapTop = JSPHelper.getRequestDouble(request, "t");
 double mapRight = JSPHelper.getRequestDouble(request, "r");
 String strDraw = JSPHelper.getRequestString(request, "draw");
 String strUser = JSPHelper.getRequestString(request, "User");

 String strImageUrl = "";
 String strPageName = "";
 


 //Create the mapcontrol and set up its basic parameters
 MapControl SysView = new MapControl(application.getInitParameter("AIMS_SERVER"), 5300, "SysView", "IRD SysView");

 //SysView.setVerbose(true);
 SysView.setDbConnection(application.getInitParameter("Conn_SysView"));
 SysView.setLogFolder(AIMSHelper.getSiteLogPath(application, "sysview"));

 //Pass the layers from the request
 SysView.setActiveLayers(strDraw);
 SysView.setMapHeight(mapHeight);
 SysView.setMapWidth(mapWidth);
 SysView.setMapEnvelope(mapLeft, mapBottom, mapRight, mapTop);

 /*
  ******************************************************************************
  Begin the Identify Process
  ******************************************************************************
 */
   String sLid = "";
   String sLayerId = "";
   int iLayerId = 0;

   //Process the Layers.xml file for layer properties...
   File layersFile = AIMSHelper.getSiteLayersFile(application, "sysview");
   Document LayersXmlDoc = null;
   if (layersFile.exists() && layersFile.isFile())
   {
    try
    {
      LayersXmlDoc = AIMSHelper.getXMLDocument(layersFile);
      sLayerId = AIMSHelper.getLayerNumber(LayersXmlDoc, "WHYDRANT");
      System.out.println("SysView: Layer ID = "+ sLayerId);
      //It contains no joins
      iLayerId = Integer.parseInt(sLayerId);
	    iLayerId = 66;
     }//End Try
     catch (Exception e)
     {
      //System.out.println("Error Stack in identify.jsp.\n");
      out.println("<!--" + e.toString() + "-->");
      e.printStackTrace();
     } //End Catch
   }//End If For File Test
   else
   {
    out.println("<b>Process Failed. Could not Find layers.xml.</b><br>");
    HTML.writeErrorContact("TSC", "tsc@csu.org", "668-4357");
    return;
   }

  String AxlResponse = SysView.identifyAXL(mapX, mapY, iLayerId, "POINT", "LID");
  //System.out.println("SysView axl response " + AxlResponse);
  AxlHelper axlHelp = new AxlHelper(AxlResponse);

  //First see if it has any errors
  if (axlHelp.hasErrors())
  {
   out.println("<b>Your Request Has Errors</b><br>");
   HTML.writeErrorContact("TSC", "tsc@csu.org", "668-4357");
   //out.print("<!--" + AxlResponse + "-->");
  }
  else
  {
   int iTotalRecords = axlHelp.getTotalRecords();
   //System.out.println("SysView: Total Records = "+ iTotalRecords);
   if (iTotalRecords > 0)
   {
      sLid = axlHelp.getFieldValue("LID");
      //System.out.println("SysView: AXL  = "+ AxlResponse);
      //System.out.println("SysView: sLid = "+ sLid);
      if (sLid != null)
      {
        strImageUrl = SysView.getMapIDFromAXL(iLayerId, "LINE", "LID=&apos;" + sLid + "&apos;");
        strPageName = "HydAuth.jsp?lid=" + sLid;
        //System.out.println(strPageName);
%>
      <jsp:include page="<%=strPageName%>" />
<%
      }
      else
      {
        HTML.WriteTableHeader("No Records Found");
        HTML.WriteTableEnd();
        return;
      }
   }
   else
   {
      strPageName = "HydAuth.jsp?lid=";
      %>
      <jsp:include page="<%=strPageName%>" />
		  <%
     return;
   }
  } //End Test For Errors
%>
 <script language="JavaScript1.2">
    self.defaultStatus = 'FIMS SysView...';
    parentWindow = window.opener;
    dMap = parentWindow.top.mapFrame;
    dMap.ProcessIDMap('<%=strImageUrl%>');
 </script>
</body>
</html>
