<%@ page language="java"
         import="java.net.*,org.csu.gis.*, org.csu.gis.JSPHelper,
                 java.text.SimpleDateFormat,
                 org.xml.sax.*, org.w3c.dom.*, javax.xml.parsers.*"
         errorPage="../../error.jsp"
%>
<%@ include file="../include/siteHeader.jsp"%>
<%
  String strNovellUser = (String)session.getAttribute("User");
  String strLid = JSPHelper.getRequestString(request, "lid");
  if (strLid.equalsIgnoreCase("null")){
  	strLid = "Select a Hydrant";
  }
  Cookie UserID = new Cookie("User", strNovellUser);
  UserID.setMaxAge(31 * 60 * 60 * 9); //One Month
  UserID.setPath("/");
  response.addCookie(UserID);
  %>
   <style type="text/css">

    .mouseOut {
    background: #708090;
    color: #FFFAFA;
    }

    .mouseOver {
    background: #FFFAFA;
    color: #000000;
    }
    
    input.removeButton
		{
		 	font-size:9px;
		  font-family:Arial,sans-serif;
		  font-weight:bold;
		  color:#CC3333;
		}
    input.addButton
		{
   
	   font-size:9px;
	   font-family:Arial,sans-serif;
	   font-weight:bold;
   	 color:#336633;
		}
</style>

		
    
    </style>
    <script type="text/javascript">        
        var xmlHttp;
        var PermitNumberDivision_PopUp;
        var PermitNumber;
        var CustomerName;
        var PermitNumberTable;
        var PermitNumberTableBody;
        var CustomerNameTableBody;
        var PermitInfoDetailTable;            
//---------------------------------------------        
//Init Vars 
//---------------------------------------------
        //Init for objects used in display
        function initVars() {
        	  //Permit Vars 
            PermitNumber = document.getElementById("InputPermitNumber");          
            PermitNumberTable = document.getElementById("PermitNumber_Table");
            PermitNumberDivision_PopUp = document.getElementById("PermitNumber_PopUp");
            PermitNumberTableBody = document.getElementById("PermitNumber_Table_body");
            //Customer Name vars
            CustomerName = document.getElementById("InputCustomerName");      
            CustomerNameTable = document.getElementById("CustomerName_Table");    
            CustomerNameDivision_PopUp = document.getElementById("CustomerName_PopUp");
            CustomerNameTableBody = document.getElementById("CustomerName_Table_body");
						//Permit Info
						PermitInfoDetailTable = document.getElementById("PermitInfoDetail_Table");
        }

//---------------------------------------------
//Ajax Requried Functions
//Add sample of XML
//Add line spacing 
//----------------------------------------------
        function createXMLHttpRequest() {
        	if (! xmlHttp){
            if (window.ActiveXObject) {
                xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            else if (window.XMLHttpRequest) {
                xmlHttp = new XMLHttpRequest();                
            }
          }
        }
        
        function Permit_Number_CallBack() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.status == 200) {
                	  //Retrive values from the xml response
                    var perm_num = xmlHttp.responseXML.getElementsByTagName("perm")[0].firstChild.data;
                    //Set Values
                    Fill_Permit_Number_Drop_Down(xmlHttp.responseXML.getElementsByTagName("perm"));
                    Clear_Permit_Info_Table();
                } else if (xmlHttp.status == 204){
                    Clear_Permit_Number_Drop_Down();
                }
            }
        }
        //-------------------------------------------
         function Customer_Name_CallBack() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.status == 200) {
                	  //Retrive values from the xml response
                    var CustName = xmlHttp.responseXML.getElementsByTagName("name")[0].firstChild.data;
                    //Set Values
                    Fill_Customer_Name_Drop_Down(xmlHttp.responseXML.getElementsByTagName("name"));
										
                } else if (xmlHttp.status == 204){
                    Clear_Customer_Name_Drop_Down();
                }
            }
        }
        function Permit_DetailUpdate_Callback() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.status == 200) {
                	  Find_Permit_Detail_By_Customer_Name();
            }
        	}
      	}
        //--------------------------------------------
         function Customer_Name_Detail_CallBack() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.status == 200) {
                	  //Retrive values from the xml response
                    var CustName = CustomerName.value;
                    //Set Values
                    Fill_Permit_Detail_Data( xmlHttp.responseXML.getElementsByTagName("name"));
                    
                } else if (xmlHttp.status == 204){
                    Clear_Customer_Name_Drop_Down();
                }
            }
        }
				
				function Permit_Num_Detail_CallBack() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.status == 200) {
                //Retrive values from the xml response
                var CustName = xmlHttp.responseXML.getElementsByTagName("custName")[0].firstChild.data;
                CustomerName.value = CustName;
                Find_Permit_Detail_By_Customer_Name();
                
            }
        }
      }
//-------------------------------------------
//Get Data Based on data entered in page
//HYDAutoCompleteServlet is a serverlet 
//-------------------------------------------

        //Calls Java Servlet to return Permit data based on customer name
				function Find_Permits_By_Customer_Name() {
            initVars();
            if (CustomerName.value.length > 0) {
                createXMLHttpRequest();            
                var url = "HYDAutoCompleteServlet?name=" + escape(CustomerName.value);                     
                xmlHttp.open("GET", url, true);
                xmlHttp.onreadystatechange = Customer_Name_CallBack;
                
                xmlHttp.send(null);
            } else {
                Clear_Customer_Name_Drop_Down();
            }
        }        

				//Calls Java Servlet to return Permit detail data based on customer name
				function Find_Permit_Detail_By_Customer_Name() {
            initVars();
            if (CustomerName.value.length > 0) {
                createXMLHttpRequest();            
                var url = "HYDAutoCompleteServlet?NameDetail=" + escape(CustomerName.value);                     
                xmlHttp.open("GET", url, true);
                xmlHttp.onreadystatechange = Customer_Name_Detail_CallBack;
                xmlHttp.send(null);
            } else {
                Clear_Permit_Info_Table();
            }
        }        

				//Calls Java Servlet to return Permit detail data based on customer name
				function Find_Permit_Detail_By_Permit_Num() {
            initVars();
            if (PermitNumber.value.length > 0) {
                createXMLHttpRequest();  
                var url = "HYDAutoCompleteServlet?permNumDetail=" + escape(PermitNumber.value);                     
                xmlHttp.open("GET", url, true);
                xmlHttp.onreadystatechange = Permit_Num_Detail_CallBack;
                xmlHttp.send(null);
            } else {
                Clear_Permit_Info_Table();
            }
        } 
        
        function Find_Permits_By_Permit_Number() {
            initVars();
            if (PermitNumber.value.length > 0) {
                createXMLHttpRequest();            
                var url = "HYDAutoCompleteServlet?perms=" + escape(PermitNumber.value);                     
                xmlHttp.open("GET", url, true);
                xmlHttp.onreadystatechange = Permit_Number_CallBack;
                xmlHttp.send(null);
            } else {
                Clear_Permit_Number_Drop_Down();
            }
        }
        

                //Calls Java Servlet to return Permit data based on customer name
				function Add_Hydrant_To_Permit(AddingToPermit) {
					 var lid = document.getElementById("ActiveLID");
					 var username = document.getElementById("UserName");
					 if (lid.value == "Select a Hydrant"){
					 		alert("Select a Hydrant first then click on the A button");
					 	}else{   
            if (lid.value.length > 0) {
                createXMLHttpRequest();                       
                var url = "HYDAutoCompleteServlet?addhyd=" + escape(lid.value) + "&addpermit=" + escape(AddingToPermit) +"&username="+username;                     
                xmlHttp.open("GET", url, true);
                xmlHttp.onreadystatechange = Permit_DetailUpdate_Callback;
                xmlHttp.send(null);
            } else {
                Clear_Customer_Name_Drop_Down();
            }
          }
        } 
        
        function Deactive_Hydrant_From_Permit(permit) {
        	 var username = document.getElementById("UserName");
        	 var PermitDetailBrokenUp = permit.split("PERMEQL");  
                createXMLHttpRequest();                       
                var url = "HYDAutoCompleteServlet?removehyd=" + escape(PermitDetailBrokenUp[0]) + "&removepermit=" + escape(PermitDetailBrokenUp[1])+"&username="+username;                     
                xmlHttp.open("GET", url, true);
                xmlHttp.onreadystatechange = Permit_DetailUpdate_Callback;
                xmlHttp.send(null);
        } 
        
        
//--------------------------------------------
//Set Page Data
//--------------------------------------------
				
				//Set page details based on Ajax call back        
        function Fill_Permit_Number_Drop_Down(the_names) {            
            Clear_Permit_Number_Drop_Down();
            var size = the_names.length;
            Set_Offsets_Permit_Number();
            
            var row, cell, txtNode;
            if (size > 1){
            for (var i = 0; i < size; i++) {
                var nextNode = the_names[i].firstChild.data;
                row = document.createElement("tr");
                cell = document.createElement("td");
                
                cell.onmouseout = function() {this.className='mouseOver';};
                cell.onmouseover = function() {this.className='mouseOut';};
                cell.setAttribute("bgcolor", "#FFFAFA");
                cell.setAttribute("border", "0");
                cell.onclick = function() { Fill_Permit_Number_Drop_Down_Cell(this); } ;                             

                txtNode = document.createTextNode(nextNode);
                cell.appendChild(txtNode);
                row.appendChild(cell);
                PermitNumberTableBody.appendChild(row);
            }
          }
        }

				//Set page details based on Ajax call back        
        function Fill_Customer_Name_Drop_Down(the_names) {            
            Clear_Customer_Name_Drop_Down();
            var size = the_names.length;
            Set_Offsets_Customer_Name();
            
            var row, cell, txtNode;
            if (size > 1){
            for (var i = 0; i < size; i++) {
                var nextNode = the_names[i].firstChild.data;
                row = document.createElement("tr");
                cell = document.createElement("td");
                
                cell.onmouseout = function() {this.className='mouseOver';};
                cell.onmouseover = function() {this.className='mouseOut';};
                cell.setAttribute("bgcolor", "#FFFAFA");
                cell.setAttribute("border", "0");
                cell.onclick = function() { Fill_Customer_Name_Drop_Down_Cell(this); } ;                             

                txtNode = document.createTextNode(nextNode);
                cell.appendChild(txtNode);
                row.appendChild(cell);
                CustomerNameTableBody.appendChild(row);
            }
          }
        }
        
        function Fill_Permit_Detail_Data(the_Permits) {            
            //Clear The Table
            Clear_Permit_Info_Table();
            //Instantiate the Objects
            var NumOfPermitsForCust = the_Permits.length;
            var PermitInfoDetailTableBody = document.createElement("tbody");

            
            //Add Body to PermitInfoTable
            PermitInfoDetailTable.appendChild(PermitInfoDetailTableBody);
        
           
            
            if (NumOfPermitsForCust > 0){
	            for (var i = 0; i < NumOfPermitsForCust; i++) {
	            	var DetailRow = document.createElement("tr"); 
	            	var PermitDetail = the_Permits[i].firstChild.data;;
								var PermitDetailBrokenUp = PermitDetail.split("BREAK");
	            	var permitSize = PermitDetailBrokenUp.length;
	            	PermitNumber.value = '';
	            	var CurrentPerm;
	            	
	            	if(permitSize > 0){
		            	for (var k = 0; k < permitSize; k++ ){
		            		 	var nextNode = PermitDetailBrokenUp[k];
		            		 	//The first piece of data is the permit number
		            		 	if (k == 0){		            		 		
		            		 		
		            		 		var CustomerNameAndPermitCell = document.createElement("td");  
		            		 		//CustomerNameAndPermitCell.setAttribute("rowSpan", permitSize);
		            		 		var TitleRow = document.createElement("tr");
		            		 		
		            		 		//var PermitNumberNode = document.createTextNode(CustName + " Permit " + nextNode);
		            		 		var PermitFont = document.createElement("font");
		            		 		//CCS seems to only work with FireFox not IE 
		            		 		//PermitFont.className="maroon";
	
		            		 		PermitFont.color= "#770000";
		            		 		var PermitNumberNode = document.createTextNode(nextNode);
		            		 		CurrentPerm = nextNode;
												PermitFont.appendChild(PermitNumberNode);
										  
		            		 	  //Setup Customer Detail row    
            						CustomerNameAndPermitCell.appendChild(PermitFont);
            						TitleRow.appendChild(CustomerNameAndPermitCell);
		            		 		//Permit Number Details
		            		 	  TitleRow.appendChild(CustomerNameAndPermitCell);
		            		 	  if(permitSize < 4){
			            		 		var HYDECheckBoxCell = document.createElement("td"); 
				                	var HydeCheckBox = document.createElement("input");

				      						HydeCheckBox.type = "button";
				                	HydeCheckBox.id = CurrentPerm;
				                	HydeCheckBox.value="A"
													HydeCheckBox.className="addButton";
													HydeCheckBox.onclick = function() {Add_Hydrant_To_Permit(this.id);} 
				                	HYDECheckBoxCell.appendChild(HydeCheckBox);
				     							TitleRow.appendChild(HYDECheckBoxCell);
		            		 	  }
		            		 		PermitInfoDetailTableBody.appendChild(TitleRow);
		            		 		
		            		 	}else{
		            		 		
		            		 		if (nextNode != "null"){
		            		 			var LIDDetails = document.createTextNode(nextNode);
			            		 		var HydeFont = document.createElement("font");
			            		 		var LIDCheckBoxCell = document.createElement("td"); 
				                	var LIDDetailCell = document.createElement("td"); 
				                	var LIDCheckBox = document.createElement("input");
				      						LIDCheckBox.type = "button";
					                LIDCheckBox.id = nextNode +"PERMEQL"+CurrentPerm;
					                LIDCheckBox.value="X"
													LIDCheckBox.className="removeButton";
													LIDCheckBox.onclick = function() {Deactive_Hydrant_From_Permit(this.id);} 
				                	
				                	HydeFont.className = "blue";
				                	LIDCheckBoxCell.appendChild(LIDCheckBox);
				                	HydeFont.appendChild(LIDDetails);
				                	LIDDetailCell.appendChild(HydeFont);
				                	
				               		DetailRow.appendChild(LIDDetailCell);
				     							DetailRow.appendChild(LIDCheckBoxCell);
				     							PermitInfoDetailTableBody.appendChild(DetailRow);
				     						}
			     					}
		              }
		              
	            	}
	            	
	            }
          }
        }

				//Sets the Name input box
				function Fill_Customer_Name_Box(CustName) {            
                CustomerName.value = CustName;
                Find_Permit_Detail_By_Customer_Name();
               
        }
  			//Sets the Name input box
				function Fill_Permit_Number_Box(PermNum) {            
                PermitNumber.value = PermNum;
                Find_Permit_Detail_By_Permit_Num();
        }      
				//Populate Cell for Drop down with returned data
				function Fill_Permit_Number_Drop_Down_Cell(cell) {
            PermitNumber.value = cell.firstChild.nodeValue;
            PermitNumber.value = cell.firstChild.nodeValue;
            Clear_Permit_Number_Drop_Down();
            Find_Permits_By_Permit_Number();
            //The ajax call run together with out this to pause it 
            setTimeout("Find_Permit_Detail_By_Permit_Num()",100);
        }
        
				//Populate Cell for Drop down with returned data
				function Fill_Customer_Name_Drop_Down_Cell(cell) {
            CustomerName.value = cell.firstChild.nodeValue;
            CustomerName.value = cell.firstChild.nodeValue;
            Clear_Customer_Name_Drop_Down();
            //The ajax call run together with out this to pause it 
            setTimeout("Find_Permit_Detail_By_Customer_Name()",100);
        }
        
        //Populate Cell for Drop down with returned data
				function Fill_Customer_Name_Detail_Cell(cell) {
            CustomerName.value = cell.firstChild.nodeValue;
            CustomerName.value = cell.firstChild.nodeValue;
            //Find_Permits_By_Customer_Name();
        }
        

//-----------------------------				
//Clear Page Content
//-----------------------------
				function Clear_Permit_Number_Drop_Down() {
            var ind = PermitNumberTableBody.childNodes.length;
            for (var i = ind - 1; i >= 0 ; i--) {
                 PermitNumberTableBody.removeChild(PermitNumberTableBody.childNodes[i]);
            }
            PermitNumberDivision_PopUp.style.border = "none";
        }

				function Clear_Customer_Name_Drop_Down() {
            var ind = CustomerNameTableBody.childNodes.length;
            for (var i = ind - 1; i >= 0 ; i--) {
                 CustomerNameTableBody.removeChild(CustomerNameTableBody.childNodes[i]);
            }
            CustomerNameDivision_PopUp.style.border = "none";
        }

				function Clear_Permit_Info_Table() {
               var ind = PermitInfoDetailTable.childNodes.length;
            for (var i = ind - 1; i >= 0 ; i--) {
                 PermitInfoDetailTable.removeChild(PermitInfoDetailTable.childNodes[i]);
            }
        
        }
        
//------------------------------
//Set Format for Drop Down Boxes 
//-------------------------------
				//Set offsets for drop down 
				 function Set_Offsets_Permit_Number() {
            var end = PermitNumber.offsetWidth;
            var left = calculateOffsetLeft(PermitNumber);
            var top = calculateOffsetTop(PermitNumber) + PermitNumber.offsetHeight;

            PermitNumberDivision_PopUp.style.border = "black 1px solid";
            PermitNumberDivision_PopUp.style.left = left + "px";
            PermitNumberDivision_PopUp.style.top = top + "px";
            PermitNumberTable.style.width = end + "px";
        }
				//Set offsets for drop down 
				 function Set_Offsets_Customer_Name() {
						var end = CustomerName.offsetWidth;
            var left = calculateOffsetLeft(CustomerName);
            var top = calculateOffsetTop(CustomerName) + PermitNumber.offsetHeight;

            CustomerNameDivision_PopUp.style.border = "black 1px solid";
            CustomerNameDivision_PopUp.style.left = left + "px";
            CustomerNameDivision_PopUp.style.top = top + "px";
            CustomerNameTable.style.width = end + "px";
        }

//---------------------------------
//General Functions for offset work
//----------------------------------
        function calculateOffsetLeft(field) {
          return calculateOffset(field, "offsetLeft");
        }

        function calculateOffsetTop(field) {
          return calculateOffset(field, "offsetTop");
        }

        function calculateOffset(field, attr) {
          var offset = 0;
          while(field) {
            offset += field[attr]; 
            field = field.offsetParent;
          }
          return offset;
        }


      
  
</script>
<body>
<font class="maroon">
      <b>Welcome to HYDE, <input type="text" id="UserName" value="<%=strNovellUser%>" readonly=true /> <br></b>
    </font>
    <br>
<table border="1" cellspacing="1" width="468" bgcolor="#DDDDDD">
    <form name="dwg" method="POST" action="HydAuth.jsp" target="_self">
        <tr>
          <td width="196" align="right">
           <font class="blue">
            Current LID 
           </font>
          </td>
          <td width="248">
           <font class="blue">
           <input type="text" id="ActiveLID" value="<%=strLid%>" readonly=true />
           </font>
          </td>
        </tr>
		</form>
</table>
<br>
<font class="maroon"> <b> Search </b> </font>
<table border="1" cellspacing="1" width="468" bgcolor="#DDDDDD">
    <form name="Hyd" method="POST" action="HydAuth.jsp" target="_self">
          <td width="196" align="right">
           <font class="blue"> Customer Name </font>
          </td>
          <td>
          	<input type="text" size="40" id="InputCustomerName" onkeyup="Find_Permits_By_Customer_Name()"  style="height:20;"/>
          	<div style="position:absolute;" id="CustomerName_PopUp">
        			<table id="CustomerName_Table" bgcolor="#FFFAFA" border="0" cellspacing="0" cellpadding="0"/>            
           			<tbody id="CustomerName_Table_body"></tbody>
        			</table>
        		</div>
        	</td>
  			</tr>
  			<tr>
  			<tr>
          <td width="196" align="right">
           <font class="blue"> Enter a Permit # </font>
          </td>
          <td width="248">
              <input type="text" size="20" id="InputPermitNumber" onkeyup="Find_Permits_By_Permit_Number()" style="height:20;"/>
    					<div style="position:absolute;" id="PermitNumber_PopUp">
	        			<table id="PermitNumber_Table" bgcolor="#FFFAFA" border="0" cellspacing="0" cellpadding="0"/>            
           				<tbody id="PermitNumber_Table_body"></tbody>
        				</table>
    					</div>
          </td>
        </tr>
</table>
<br>
<font class="maroon"> <b> Permit Detail </b> </font>
<table id="PermitInfo_Table" border="1" cellspacing="1" bgcolor="#DDDDDD" rules="rows"/>            
	<tbody id="PermitInfoDetail_Table"></tbody>
</table>
</form>
</body>
 
</html>
 