/*
 * HYDAutoCompleteServlet.java
 *focus on modified 
 *include calling objects 
 * called by HydRequest.jsp
 * Created on June 20, 2005, 7:24 PM
 *
 	1) (DONE)Check if _PreparedStatement is not null and _DatabaseConnection 
 		 (DONE)Checking for _DatabaseConnection
 		 	_Statement is now _PreparedStatement and a PreparedStatement object and prepared statements 
 		 	do not have a option for checking connections and closing them at version 1.5. http://java.sun.com/j2se/1.5.0/docs/api/java/sql/PreparedStatement.html
	2) (DONE)Use a common error notifer 
	3) (DONE) Make all of the class level vars private.
  4) (DONE) Try to using the underscore ( _ ) prefix with all class level vars.
  5) Use prams in instead of values for the sql statments
  	 Prepared Statment tutorial
  	 	http://java.sun.com/docs/books/tutorial/jdbc/basics/prepared.html
	6) (DONE)Look into a way to display class and method name in error handler
  */   
package org.csu.gis; 
import java.io.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.csu.util.*;
import oracle.jdbc.driver.*;

/**
 *
 * @author nate
 * @version
 */
public class HYDAutoCompleteServlet extends HttpServlet {
    private List<String> _PermitDetail = new ArrayList<String>();
    private String _Description = "";
    private Connection _DatabaseConnection;
    private PreparedStatement _PreparedStatement;
    private ResultSet _ResultSet;
    private HttpServletResponse hTTPResponse;

  public void init(ServletConfig config) throws ServletException {
  }
    
    /** Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     */
  protected void doGet(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
       	hTTPResponse = response;
        String permits = request.getParameter("perms");
        String CustomerName = request.getParameter("name");
        String verboseString = request.getParameter("verbose");
        String permitNumDetail = request.getParameter("permNumDetail");
        String CustomerNameDetail = request.getParameter("NameDetail");
        String AddHyde = request.getParameter("addhyd");
        String AddPermit = request.getParameter("addpermit");
        String removeHyde = request.getParameter("removehyd");
        String removePermit = request.getParameter("removepermit");
        String UserName = request.getParameter("username");
      //VerbosePrinting("--------------------- ");  
      //VerbosePrinting("HYDAutoComplete  perms = ["+ permits+"]");    
      //VerbosePrinting("HYDAutoComplete  name = ["+ CustomerName+"]");   
      //VerbosePrinting("HYDAutoComplete  NameDetail = ["+ CustomerNameDetail+"]"); 
      //VerbosePrinting("HYDAutoComplete  AddHyde = ["+ AddHyde+"]");   
      //VerbosePrinting("HYDAutoComplete  AddPermit = ["+ AddPermit+"]");   
			//VerbosePrinting("HYDAutoComplete  removehyd = ["+ removeHyde+"]");   
      //VerbosePrinting("HYDAutoComplete  removepermit = ["+ removePermit+"]");   
			VerbosePrinting("HYDAutoComplete  username = ["+ UserName+"]"); 
      //VerbosePrinting("--------------------- ");  
        try{
        	//Logic to Search for permits
	        	if ((permits != null) || (CustomerName != null) ){
		        	if (permits != null){
		        		Long   perm = new Long(permits);
		        		//VerbosePrinting("--------------------- ");  
		        		//VerbosePrinting(" 1 Permits_By_Permit_Number and Sending  "+ perm);   
		        		//VerbosePrinting("--------------------- ");  
		        		Permits_By_Permit_Number(perm);
		        		Print_Search();
		        	}
		        	if (CustomerName != null){
		        		//VerbosePrinting("--------------------- ");  
		        		//VerbosePrinting(" 2 Permits_By_Customer_Name and Sending  "+ CustomerName);
		        		//VerbosePrinting("--------------------- ");  
		        		Permits_By_Customer_Name(CustomerName);
		        		Print_Name_Search();
		        	}
	        	}
	        	
	          //Logic to search for permit details
	        	if ((permitNumDetail != null) || (CustomerNameDetail != null)){
			        if (permitNumDetail != null){
			        	
			        	Long   permDetail = new Long(permitNumDetail);
			        	//VerbosePrinting("--------------------- ");  
			        	//VerbosePrinting(" 3 Permits_DetailByNumber and Sending  "+ permDetail);   
			        	//VerbosePrinting("--------------------- ");  
			        	Permits_DetailByNumber(permDetail);
			       
			        	Print_PermitDetail();
			        }
			        if (CustomerNameDetail != null){
			        	//VerbosePrinting("--------------------- ");  
			        	//VerbosePrinting(" 4 Permits_DetailByName and Sending  "+ CustomerNameDetail);   
			        		//VerbosePrinting("--------------------- ");  
			        	Permits_DetailByName(CustomerNameDetail);
			        	Print_Name_Search();
			        }
		        	
						}
						if ((AddHyde != null) && (AddPermit != null)){
							VerbosePrinting("--------------------- ");  
			       //VerbosePrinting(" Ading ["+ AddHyde + "] to ["+AddPermit);   
			       //VerbosePrinting("--------------------- ");  
		        		Add_HYDE_To_Permit(AddHyde,AddPermit,UserName);
						}
						if ((removeHyde != null) && (removePermit != null)){
		        		Deactivate_HYDE_From_Permit(removeHyde,removePermit,UserName);
						}
        	}catch(Exception ex){
						ErrorNotifer(" HYDAutoCompleteServlet.DoGET exception " , ex);
				}
  }
    
    /** Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     */
  protected void doPost(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
        doGet(request, response);
  }
    
    /** Prints the content for the server
     */
  private void Print_Search()throws IOException{
    	try{ 
    	 if (_PermitDetail.size() > 0) {
	            PrintWriter out = hTTPResponse.getWriter();
	            hTTPResponse.setContentType("text/xml");
	            hTTPResponse.setHeader("Cache-Control", "no-cache");
	            out.println("<response>");
	            Iterator iter = _PermitDetail.iterator();
	            while(iter.hasNext()) {
	                
									String perm ="<perm>" + (String) iter.next() + "</perm>";
                //VerbosePrinting("Print_PermitDetail Printing  "+ perm); 
	                out.println(perm);
            }
            out.println("</response>");
            out.close();
        	} else {
            hTTPResponse.setStatus(HttpServletResponse.SC_NO_CONTENT);
            //response.flushBuffer();
          }
     		}catch(Exception ex){
        	ErrorNotifer("Print_Search",ex); 
        }
  }

  private void Print_Name_Search()throws IOException{
    	try{ 
    	 if (_PermitDetail.size() > 0) {
	            PrintWriter out = hTTPResponse.getWriter();
	            hTTPResponse.setContentType("text/xml");
	            hTTPResponse.setHeader("Cache-Control", "no-cache");
	            out.println("<response>");
	            Iterator iter = _PermitDetail.iterator();
	            while(iter.hasNext()) {
	                String name = (String) iter.next();
	                out.println("<name>" + name + "</name>");
            }
            out.println("</response>");
            out.close();
        	} else {
            hTTPResponse.setStatus(HttpServletResponse.SC_NO_CONTENT);
            //response.flushBuffer();
          }
     		}catch(Exception ex){
        	ErrorNotifer("Print_Name_Search",ex); 
        }
  }

  private void Print_PermitDetail()throws ServletException, IOException{
    	try{
    	  if (_PermitDetail.size() > 0) {
            PrintWriter out = hTTPResponse.getWriter();
            hTTPResponse.setContentType("text/xml");
            hTTPResponse.setHeader("Cache-Control", "no-cache");
            out.println("<response>");
            Iterator iter = _PermitDetail.iterator();
            while(iter.hasNext()) {
                String custname ="<custName>" + (String) iter.next() + "</custName>";
                //VerbosePrinting("Print_PermitDetail Printing  "+ custname);   
                out.println(custname);
            }
            out.println("</response>");
            out.close();
        	} else {
            hTTPResponse.setStatus(HttpServletResponse.SC_NO_CONTENT);
            //response.flushBuffer();
        	}
        }catch(Exception ex){
        	ErrorNotifer("Print_PermitDetail",ex); 
        }
  }
    private void Add_HYDE_To_Permit(String LID, String permitNum, String UserName)throws Exception {
		  try{
		  		//VerbosePrinting(LID + " " + permitNum);
					_DatabaseConnection = CSUConnection.getPoolConnection("oraArcIms");
					//Prepare the call to the stored function.
					_PreparedStatement = _DatabaseConnection.prepareCall("{CALL GISAPPSDBM.HYDE.Add_hyd_to_permit(?,?,?)}");
					//The statement will return a "ref cursor"
					//Set the stored function's in parameters
					_PreparedStatement.setString(1, permitNum); 					//... and call the stored function...
					_PreparedStatement.setString(2, LID);
					_PreparedStatement.setString(3, UserName);
					_PreparedStatement.execute();
					//Get the ResultSet					
					//VerbosePrinting("Add_HYDE_To_Permit Executed ");
			}catch(Exception ex){
					ErrorNotifer("Add_HYDE_To_Permit" , ex);
			}finally{ 
				if (!(_DatabaseConnection.isClosed())){
				  //Closing the Database connection closes the statment
					_DatabaseConnection.close();
				}
		 		
			}
	}
	private void Deactivate_HYDE_From_Permit(String LID, String permitNum, String UserName)throws Exception {
		  try{
		  		//VerbosePrinting("Deactivate_HYDE_From_Permit " + LID + " " + permitNum);
					_DatabaseConnection = CSUConnection.getPoolConnection("oraArcIms");
		     
					//Prepare the call to the stored function.
					////VerbosePrinting("Preparing the callable statment");
				//VerbosePrinting("Deactivate_HYDE_From_Permit Preparing Call");
					_PreparedStatement = _DatabaseConnection.prepareCall("{CALL GISAPPSDBM.HYDE.Deactivate_hyde_from_permit(?,?,?)}");
					//The statement will return a "ref cursor"
					//Set the stored function's in parameters
					_PreparedStatement.setString(1, permitNum); 					//... and call the stored function...
					_PreparedStatement.setString(2, LID);
					_PreparedStatement.setString(3, UserName);
				//VerbosePrinting("Deactivate_HYDE_From_Permit Set Prams ");
					//VerbosePrinting("Execute Search Now For " + name);
					_PreparedStatement.execute();
					//Get the ResultSet					
				//VerbosePrinting("Deactivate_HYDE_From_Permit Executed ");
			}catch(Exception ex){
					ErrorNotifer("Deactivate_HYDE_From_Permit" , ex);
			}finally{ 
				if (!(_DatabaseConnection.isClosed())){
				  //Closing the Database connection closes the statment
					_DatabaseConnection.close();
				}
		 		
			}
	}
    
  private void Permits_By_Customer_Name(String name)throws Exception {
		  try{
					_DatabaseConnection = CSUConnection.getPoolConnection("oraArcIms");
					_PermitDetail.clear();
					
				 	_PreparedStatement = _DatabaseConnection.prepareStatement("SELECT  DISTINCT(PERMIT_CUST_NAME) PERMIT_CUST_NAME FROM  GISAPPSDBM.HYDE_PERMIT	WHERE   UPPER (PERMIT_CUST_NAME) LIKE UPPER((?)) ORDER BY PERMIT_CUST_NAME");
				 _PreparedStatement.setString(1, name+"%");
				 _ResultSet = _PreparedStatement.executeQuery();
		     /*
					//Prepare the call to the stored function.
					VerbosePrinting("Preparing the callable statment");
					CallableStatement CallStatment = _DatabaseConnection.prepareCall("BEGIN GISAPPSDBM.HYDE.GET_PERMITS_CUST_NAME(?,?); END;");
					//The statement will return a "ref cursor"
					//Set the stored function's in parameters
					VerbosePrinting("Setting Name");
					CallStatment.setString(1, name);
					VerbosePrinting("Setting Output");
					CallStatment.registerOutParameter(2, java.sql.Types.OTHER);
					//... and call the stored function...
					VerbosePrinting("Execute Search Now For " + name);
					CallStatment.execute();
					_ResultSet = (ResultSet) CallStatment.getObject(2); 
					//Get the ResultSet					
			   */
					while (_ResultSet.next()) {
						VerbosePrinting("Found data");
						_PermitDetail.add(_ResultSet.getString("PERMIT_CUST_NAME"));					
					}
					
			}catch(Exception ex){
					ErrorNotifer("Permits_By_Customer_Name" , ex);
			}finally{ 
				if (!(_DatabaseConnection.isClosed())){
				  //Closing the Database connection closes the statment
					_DatabaseConnection.close();
				}
		 		
			}
	}    

	private void Permits_By_Permit_Number(Long perms)throws Exception {
		  
		  try{
				  _DatabaseConnection = CSUConnection.getPoolConnection("oraArcIms");
					_PermitDetail.clear();
					_PreparedStatement = _DatabaseConnection.prepareCall("{CALL GISAPPSDBM.HYDE.GET_PERMITS_BY_PERM_NUM(?)}");
					//The statement will return a "ref cursor"
					//Set the stored function's in parameters
					_PreparedStatement.setLong(1, perms);
					//... and call the stored function...
					//VerbosePrinting("Execute Search Now For " + name);
					_ResultSet = _PreparedStatement.executeQuery();
					//Get the ResultSet	
					String CurrentPerm = "";
					while (_ResultSet.next()) {

						CurrentPerm = _ResultSet.getString("PERMIT_NUMBER");
						////VerbosePrinting("Adding [" + CurrentPerm+ "]");
		   			_PermitDetail.add(CurrentPerm);
					}
			}catch(Exception ex){
					ErrorNotifer("Permits_By_Permit_Number " , ex);
			}finally{ 
					//Closing the Database connection closes the statment
					if (!(_DatabaseConnection.isClosed())){
					_DatabaseConnection.close();
				}
			}
	}    

  private void Permits_DetailByName(String CustName)throws Exception {
		  try{
		  	////VerbosePrinting("Permit Details by Name = " + CustName);
		  	_DatabaseConnection = CSUConnection.getPoolConnection("oraArcIms");
				_PermitDetail.clear();
	  		_PreparedStatement = _DatabaseConnection.prepareCall("{CALL GISAPPSDBM.HYDE.Get_permit_detail_by_cust_name(?)}");
					//The statement will return a "ref cursor"
					//Set the stored function's in parameters				
					_PreparedStatement.setString(1, CustName);
					//... and call the stored function...
					////VerbosePrinting("Execute Search Now For " + name);
					_ResultSet = _PreparedStatement.executeQuery();
					//Get the ResultSet	

				String Permit_Number = "";
				String PermitValue = "";
				
				while (_ResultSet.next()) {
					if (!(Permit_Number.equals(_ResultSet.getString("PERM_NUM")))){
						if (!(Permit_Number.equals(""))){
							_PermitDetail.add(PermitValue);
							//VerbosePrinting("Added " + PermitValue);
						}
						Permit_Number = _ResultSet.getString("PERM_NUM");
						PermitValue = Permit_Number;
					}
					  PermitValue = PermitValue + "BREAK" + _ResultSet.getString("LID");
				}
				_PermitDetail.add(PermitValue);
				
			}catch(Exception ex){
					ErrorNotifer(" HYDAutoCompleteServlet.Permits_DetailByName exception " , ex); 
			}finally{ 
				//Closing the Database connection closes the statment
				if (!(_DatabaseConnection.isClosed())){
					_DatabaseConnection.close();
				}
			}
	} 
		
	 
	private void Permits_DetailByNumber(Long perms)throws Exception {
		  try{
		  	_DatabaseConnection = CSUConnection.getPoolConnection("oraArcIms");
				_PermitDetail.clear();
				//VerbosePrinting("Call DB with [" + perms + "] as a value");
			 	_PreparedStatement = _DatabaseConnection.prepareCall("{CALL GISAPPSDBM.HYDE.GET_PERMIT_DETAIL_BY_PERM_NUM(?)}");
				//The statement will return a "ref cursor"
				//Set the stored function's in parameters
				_PreparedStatement.setLong(1, perms);
				//... and call the stored function...
				//VerbosePrinting("Execute Search Now For " + perms);
				_ResultSet = _PreparedStatement.executeQuery();
			
				//VerbosePrinting("Execute Search Workded for " + perms);
			//Get the ResultSet	

				String Cust_Name = "";
			while (_ResultSet.next()) {
				Cust_Name = _ResultSet.getString("CUST_NAME");
				
				//VerbosePrinting("Customer Name for permit "+ perms +" is  " + Cust_Name);		
				
				_PermitDetail.add(Cust_Name);
			}
			}catch(Exception ex){
					ErrorNotifer(" HYDAutoCompleteServlet.Permits_DetailByName exception " , ex); 
			}finally{ 
				//Closing the Database connection closes the statment
				if (!(_DatabaseConnection.isClosed())){
					_DatabaseConnection.close();
				}
			}
	} 
	
		 
	private void ErrorNotifer (String message, Exception ex){
		  
			System.out.println(message + " Detailed Error Message = " + ex.getMessage());
			ex.printStackTrace();

	}
	private void VerbosePrinting (String message){
			System.out.println(message);
	}
		
  /** Returns a short _Descriptionription of the servlet.
  */
  public String getServletInfo() {
        return "Short _Descriptionription";
  }
}
