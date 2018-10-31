<%@ page language="java"
         import="org.csu.util.*, org.csu.gis.JSPHelper"
         errorPage="../../error.jsp"
%>
<%@ include file="../include/siteHeader.jsp"%>
<%
  String strTotalArea = "";
  String strErrorMessage = "";
  String strNovellName = JSPHelper.getRequestString(request, "novell_name");
  String strNovellPass = JSPHelper.getRequestString(request, "novell_pass");
  String strNovellCookie = JSPHelper.getCookie(request, "User");
  String strNovellUser = (String)session.getAttribute("User");
  String strLid = JSPHelper.getRequestString(request, "lid");
  String strPageName = "";
  strPageName = "HydAuth.jsp";
  if (strNovellUser == null )
  {
	  if (strNovellName != null && strNovellPass != null)
	  {
	   CSULDAP csuLDAP = new CSULDAP();
	   //First Authenticate the user in the LDAP System
	   if (csuLDAP.isUserAuthenticated(strNovellName, strNovellPass))
	   {//Authentication succeeded!!
	    CSULDAPQuery LdapQuery = new CSULDAPQuery("FIMSapp", "vision#24");
	    //Old Account Name was C_AUTOCAD_USER
	    //New Account Name created as a roll up on 4/27/2005 is C_AUTODESK_PRODUCTS_USER
	    if (LdapQuery.isGroupMember(strNovellName, "A_FIMS_HYDE"))
	    {//Checks for Engineering Desktop Group designation privilages.
	     session.setAttribute("User", strNovellName);
%>
      <jsp:include page="<%=strPageName%>" />
<%
	     return;
	    }
	    else
	    {
	     strErrorMessage = "You were authenticated, but you do not have edit permissions to this applications.";
	    }
	   }
	   else
	   {
	     strErrorMessage = "We are unable to authenticate this User ID and Password.";
	   }
	  }
	  	%>
	  	<body>
			<table border="1" cellspacing="1" width="468" bgcolor="#DDDDDD">
			  <tr>
			    <td width="468" valign="top" align="center" height="250">
			     <font class="maroon">
			      <b>Hydrant Permit<br>
			         Welcome to HYDE, Please enter you Network login.<br>
			      </b>
			    </font>
			    <font color="#FF0000">
			     <br><b><%=strErrorMessage%></b>
			    </font>
			    <form name="dwg" method="POST" action="<%=strPageName%>" target="_self">
			      <table border="1" cellspacing="1" width="456">
			        <tr>
			          <td width="196" align="right">
			           <font class="blue">
			            Your Novell Username:
			           </font>
			          </td>
			          <td width="248">
			           <input type="text" name="novell_name" size="20" value="">
			          </td>
			        </tr>
			        <tr>
			          <td width="196" align="right">
			           <font class="blue">
			            Your Novell Password:
			           </font>
			          </td>
			          <td width="248">
			           <input type="password" name="novell_pass" size="20" value="">
			          </td>
			        </tr>
			        <tr>
			         <td colspan="2" valign="middle" align="center" width="450">
			          <center>
			           <input class="btns" type="submit" value="Authenticate" name="DoIt">
			           <input class="btns" type="button" value="Cancel" name="close" onClick="top.close();">
			          </center>
			         </td>
			        </tr>
			      </table>
			    </form>
			    </td>
			  </tr>
			</table>
			</body>
	  	<%
  }else{
	 	strPageName = "HydRequest.jsp?lid=" + strLid;
		%><jsp:forward page="<%=strPageName%>" /><%
	}
%>
</html>
