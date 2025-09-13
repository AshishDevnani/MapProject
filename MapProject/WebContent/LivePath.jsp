<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@include file="dbConn.jsp" %>
   <%@ page import="kml.KML1" %>
     <%@ page import="java.io.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="OpenLayers-6.9/libs/v6.9.0-dist/ol.css" type="text/css">
<script src="OpenLayers-6.9/libs/v6.9.0-dist/ol.js"></script>
<script>
markers2 = []
markersSI = [] //SI
markersStamp=[]

var vectorGML;
layergml=false;
var content1;

function createMarkerStamps(name,html,stamp,lat,lon){
 	console.log("in create marker stamps function"+"lat:"+lat+" long:"+lon);
 	var markstamps = new ol.Feature({
 		geometry : new ol.geom.Point([ lon, lat ]),
 		text : html,
 		name : name
 	});
 	
 	markersStamp.push(markstamps);
 	
 }

function loadKML(url){
	console.log("inside loadKML() fn:",url);
	layergml=true;
	vectorGML = new ol.layer.Vector({
		 source: new ol.source.Vector({
			 url: url,
			 format: new ol.format.KML({
				 extractStyles: false
			 })
		 }),
		 style: new ol.style.Style({
			 stroke: new ol.style.Stroke({
		        color: '#000000',     //journey path color black
		        width: 3,
		    })
		 
		 })
	 });
	
	console.log("vectorGML:"+vectorGML)
	
}

function loadKML2(kmlurl){
	 const vector = new ol.layer.Vector({
		 source: new ol.source.Vector({
			 url: kmlurl,
			 format: new ol.format.KML({
				 extractStyles: true
			 })
		 }),
		 
	 });	
return vector;
 }
 
function createMarker(name, html, stamp, lat, lon) {
 	console.log("stamp:" +stamp);
 	var markerStamp = new ol.Feature({
 		geometry : new ol.geom.Point([ lon, lat ]),
 		text : html,
 		name : name
 	});

 	markersSI.push(markerStamp);
 	
 }

 function createMarker2(name, html, lat, lon) { //start location
 	console.log("startlat:",lat);
 	console.log("startlon:",lon);
	 var mark = new ol.Feature({
 		geometry : new ol.geom.Point([ lon, lat ]),
 		text : html,
 		name : name
 	});

 	markers2.push(mark);

 }
</script>
<style> /*newly added for vehicle mouseover popup  */
 .ol-popup {
            position: absolute;
            background-color: white;
            -webkit-filter: drop-shadow(0 1px 4px rgba(0, 0, 0, 0.2));
            filter: drop-shadow(0 1px 4px rgba(0, 0, 0, 0.2));
            padding: 10px;
            border-radius: 10px;
            border: 1px solid #cccccc;
            bottom: 12px;
            left: -50px;
            min-width: 200px;
        }

        .ol-popup:after,
        .ol-popup:before {
            top: 100%;
            border: solid transparent;
            content: " ";
            height: 0;
            width: 0;
            position: absolute;
            pointer-events: none;
        }

        .ol-popup:after {
            border-top-color: white;
            border-width: 10px;
            left: 48px;
            margin-left: -10px;
        }

        .ol-popup:before {
            border-top-color: #cccccc;
            border-width: 11px;
            left: 48px;
            margin-left: -11px;
        }
        
         .ol-popup-closer {
            text-decoration: none;
            position: absolute;
            top: 2px;
            right: 8px;
        }

        .ol-popup-closer:after {
            content: "X";
        }

</style> 
</head>
<body onload="init();">
<%
Connection conn = null;
Statement st = null,st1 = null,st2=null,st3=null;
double lat = 0,lon=0;
String loc="";
String LatitudeDir = "";
String LongitudeDir = "";
String vehiclecode = "";
String laststampdatetime="";
try{
Class.forName(MM_dbConn_DRIVER);
conn = DriverManager.getConnection(MM_dbConn_STRING,MM_dbConn_USERNAME,MM_dbConn_PASSWORD);
st = conn.createStatement();
st1 = conn.createStatement();
st2 = conn.createStatement();
st3 = conn.createStatement();
String vehicleno = request.getParameter("VehicleNo");
vehicleno = vehicleno.replaceAll(" ","");
int hours = 0;
try{
	hours = Integer.parseInt(request.getParameter("HoursSince"));
}catch(Exception e){
	
	//e.printStackTrace();
	hours = 12;
	
}

String sql = "select * from db_gps.t_onlinedata where REPLACE(vehicleregno,' ','')='"+vehicleno+"'";
System.out.println(sql);
ResultSet rs = st.executeQuery(sql);
if(rs.next()){
	lat = rs.getDouble("LatitudePosition");
	lon = rs.getDouble("LongitudePosition");
	loc = rs.getString("Location");
	vehiclecode = rs.getString("vehiclecode");
	
	LatitudeDir = rs.getString("LatitudeDir");
    LongitudeDir = rs.getString("LongitudeDir");
    
    if(LatitudeDir.equals("S")){
    	lat = -1*lat;
    }
    if(LongitudeDir.equals("W")){
    	lon = -1*lon;
    }
    
    System.out.println(lat+","+lon+":->"+loc);
    
    HashMap<String, String> coordinateMap = null;
    HashMap<String, String> coordinateMapStart = null;
    HashMap<String, String> coordinateMapEnd = null;
    List<HashMap<String, String>> coordinateList = null;
  
    
    
    coordinateList=new ArrayList<HashMap<String, String>>();
    
    double Lat=0,Lon=0;
    String Location="";
   String sql1="select DATE_FORMAT(Thefielddatadatetime, '%Y-%m-%d %H:%i:00') x, Speed,LatinDec,LonginDec,TheFieldSubject,TheFieldDataDate,TheFieldDataTime,LatitudeDir,LongitudeDir from t_veh"+ vehiclecode +" where  DATE_FORMAT(Thefielddatadatetime, '%i') >= 0 and TheFieldDataDateTime >= (now() - interval "+hours+" hour)  and TheFiledTextFileName IN ('AC','DC','OS','SI','ON','OF','ST','SP','PF','PO') order by TheFieldDataDateTime asc";
   System.out.println(sql1);
   ResultSet rst = st1.executeQuery(sql1);
   boolean includeflag =true;
   while(rst.next()){
	   
	     LatitudeDir = rst.getString("LatitudeDir");
	     LongitudeDir = rst.getString("LongitudeDir");
	     double speed = rst.getDouble("Speed");
	    
	    Lat=rst.getDouble("LatinDec");
		Lon=rst.getDouble("LonginDec");
	    
	    if(LatitudeDir.equals("S")){
	    	Lat = -1*Lat;
	    }
	    if(LongitudeDir.equals("W")){
	    	Lon = -1*Lon;
	    }
	    Location = rst.getString("TheFieldSubject");
		
	   
		    coordinateMap =  new java.util.HashMap<String, String>();
		    coordinateMap.put("name",Location);
		    coordinateMap.put("desc", Location);
		    coordinateMap.put("lat",String.valueOf(Lat)); 
		    coordinateMap.put("longi",String.valueOf(Lon));                         
		    coordinateList.add(coordinateMap);
	     
		    System.out.println(Lat+","+Lon+" "+speed+" "+Location+" ");
		    
		    String dtl = new SimpleDateFormat("dd-MM-yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(rst.getString("TheFieldDataDate")));
			String html1="<b>location:</b><br>"+Location+"<br><b>Date Time : </b>"+dtl+" " +rst.getString("TheFieldDataTime")+"<br><b>Speed:</b>"+speed;
		 
			%>
			<script>
			   createMarkerStamps("<div class='bodyText'><%= html1%></div>","<div class='bodyText'><%= html1%></div>","SI",<%= Lat%>,<%=Lon%>);
			</script>
			<%
   }
   rst = null;
   
   //1st Stamp
   String sql2="select LatinDec,LonginDec,TheFieldSubject,TheFieldDataDate,TheFieldDataTime,LatitudeDir,LongitudeDir from t_veh"+ vehiclecode +" where TheFieldDataDateTime >= (now() - interval "+hours+" hour) and TheFiledTextFileName IN ('AC','DC','OS','SI','ON','OF','ST','SP','PF','PO') order by TheFieldDataDateTime asc limit 1";
   System.out.println(sql2);
   rst = st2.executeQuery(sql2);
   if(rst.next()){
	   
	     LatitudeDir = rst.getString("LatitudeDir");
	     LongitudeDir = rst.getString("LongitudeDir");
	    
	    Lat=rst.getDouble("LatinDec");
		Lon=rst.getDouble("LonginDec");
	    
	    if(LatitudeDir.equals("S")){
	    	Lat = -1*Lat;
	    }
	    if(LongitudeDir.equals("W")){
	    	Lon = -1*Lon;
	    }	
	    
	    Location =rst.getString("TheFieldSubject");
        
        String dt1 = new SimpleDateFormat("dd-MM-yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(rst.getString("TheFieldDataDate")));
    	String html2="<b>Start location:</b><br>"+Location+"<br><b>Date Time : </b>"+dt1+" " +rst.getString("TheFieldDataTime");
    	System.out.println("Start label: "+html2);
    	System.out.println("Start location Marker....");
        
    	coordinateMapStart =  new java.util.HashMap<String, String>();
		coordinateMapStart.put("desc", rst.getString("TheFieldSubject"));
        coordinateMapStart.put("lat",String.valueOf(lat)); 
        coordinateMapStart.put("longi",String.valueOf(lon)); 
        
        
        
        %>
                <script>
		    	   createMarker2("<div class='bodyText'><%= html2%></div>","<div class='bodyText'><%= html2%></div>",<%= Lat%>,<%= Lon%>);
		    	</script>
	    <%
   }
   Lat=0;Lon=0;
   Location="";
   rst = null;
   String sql3 = "select TheFieldSubject,LatinDec,LonginDec,TheFieldDataDate,TheFieldDataTime,LatitudeDir,LongitudeDir from t_veh"+ vehiclecode +" where TheFieldDataDateTime >=(now() - interval "+hours+" hour)  and TheFiledTextFileName IN('AC','DC','OS','SI','ON','OF','ST','SP','PF','PO') order by TheFieldDataDateTime desc limit 1";
   System.out.println(sql3);
   rst = st3.executeQuery(sql3);
   if(rst.next()){
	  
	   LatitudeDir = rst.getString("LatitudeDir");
	     LongitudeDir = rst.getString("LongitudeDir");
	    
	    Lat=rst.getDouble("LatinDec");
		Lon=rst.getDouble("LonginDec");
	    
		if(LatitudeDir.equals("S")){
	    	Lat = -1*Lat;
	    }
	    if(LongitudeDir.equals("W")){
	    	Lon = -1*Lon;
	    }
		
	    coordinateMapEnd =  new java.util.HashMap<String, String>();
	    coordinateMapEnd.put("name",rst.getString("TheFieldSubject"));
	    coordinateMapEnd.put("desc", rst.getString("TheFieldSubject"));
	    coordinateMapEnd.put("lat",String.valueOf(lat)); 
	    coordinateMapEnd.put("longi",String.valueOf(lon));  
	    
	    Location=rst.getString("TheFieldSubject");
		String dt = new SimpleDateFormat("dd-MM-yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(rst.getString("TheFieldDataDate")));
		String html1="<b>Last location:</b><br>"+Location+"<br><b>Date Time : </b>"+dt+" " +rst.getString("TheFieldDataTime");
	 	//System.out.println("html:"+html1);
		System.out.println("stamp based Marker Creation logic follows:"+lat+","+lon);
	    
	    %>
		<script>
		  createMarker("<div class='bodyText'><%= html1%></div>","<div class='bodyText'><%= html1%></div>","SI",<%= Lat%>,<%= Lon%>);
		</script>    
		
		<%
		
		laststampdatetime = dt+" "+rst.getString("TheFieldDataTime");
		System.out.println("OnlineDateTime:"+laststampdatetime);
	    
    }
   

   String dir = request.getRealPath("/");
   System.out.println("getRealPath:-"+dir);
   
   String tripid1=null;
   String kmlfile = "";

 
  System.out.println("----------------------------------");

  tripid1 = vehiclecode;
  
  dir=dir+"KML/"+"kml_"+tripid1+".kml";	

  System.out.println("dir:"+dir);
   boolean flag1=false;
   String color="FFC475";
   try{

  if(coordinateList.size()!=0 && coordinateMapStart != null && coordinateMapEnd != null  ){
    flag1=KML1.generateKMLFORLINE(coordinateList,dir,coordinateMapStart,coordinateMapEnd,color);
  }
  	}catch(Exception e){
  	e.printStackTrace();
  	flag1 = false;
  } 
 
  System.out.println("flag kml for line: "+flag1);
  System.out.println("****************************************************");

  
  
  %>
   <script>
		var filename = <%=tripid1%>;
  		var url="KML/kml_"+filename+".kml?date="+new Date().getTime();
  		console.log("before loadKML() fn call :",url);
  		try{
  		    loadKML(url);
  		}
  		catch (e) {
  			alert(e);
  		}
  	
  	
  </script>

 <%
	    
}else{
	out.print("<script>alert('Vehicle "+vehicleno+" Does Not Exists'); window.close(); </script>");
}

}catch(Exception e){
	e.printStackTrace();
	out.print("<script>alert('Some Error Occurred "+e.getMessage()+" '); window.close(); </script>");
}finally{
	if(conn!=null){
		conn.close();
	}
}

%>

<div id="map" style="width:1920px;height:1080px"></div>
<div id="popup" class="ol-popup">
								<a href="#" id="popup-closer" class="ol-popup-closer"></a>
								<div id="popup-content"></div>
							</div>
</body>
<script type="text/javascript">


function init(){
    console.log("in init();")  	
	var lat=<%=lat %>; //latinDec in database
    var lon=<%=lon%>; //longinDec in database
    var desc = new String('<%=loc%>') ;  
    var dttm = new String('<%=laststampdatetime%>')
	
    console.log("lat:",lat);
    console.log("lon:",lon);
    console.log("loc:",desc);
    
     	var container = document.getElementById('popup');
     	var content = document.getElementById('popup-content');
     	var closer = document.getElementById('popup-closer'); 
        
        /* var data = "<html><body>Latitude:"+lat+" Longitude:"+lon+"<br>Location:"+desc+"</body></html>"; */
        var data = "<html><body>Latitude / Longitude :"+lat+"&nbsp "+lon+"<br>Location:"+desc+"<br>DateTime:"+dttm+"</body></html>";
     	closer.onclick = function() {
     	    overlay.setPosition(undefined);
     	    closer.blur();
     	    return false;
     	};
     	
     	var overlay = new ol.Overlay({
     		element : container,
     		autoPan : true,
     		autoPanAnimation : {
     			duration : 250
     		}
     	});
        
        const map = new ol.Map({
            
           	view: new ol.View({
           		projection : 'EPSG:4326',
                   center: [lon,lat],
                   zoom: 12,
                   maxZoom: 15
               }),
               
               target: 'map',
               
                layers: [
               	 new ol.layer.Tile({
               			source : new ol.source.XYZ({
               	  			attributions:['<a href="http://myfleetview.net/FleetView/index.jsp" style="text-decoration:none"><font face="Hemi Head 426" size="04" color="#0853A0">FleetView <br><font face="Hemi Head 426" size="01" color="#0853A0">Transworld Technologies Ltd.</a>'],
               	 			attributionsCollapsible: true,
               	 			url: 'http://maps.myfleetview.com/osm/{z}/{x}/{y}.png'
               	 		})
               		})
                   ] ,
            overlays : [ overlay ]    

           });
    	 
        try{
    		 vectorKML = loadKML2('KML/TWIndiaBoundry.kml');
    	 	 console.log("vector kml:" +vectorKML);
    	 	 map.addLayer(vectorKML);
    	}catch(e){
    		alert(e);
    	}
    	
    	console.log("in init markersSI:"+markersSI+" "+markersSI.length);
    	
    	if (markersSI.length != 0) {
     		var vectorSI = new ol.layer.Vector({
     			title : 'SI',
     			source : new ol.source.Vector({
     				features : markersSI
     			//array
     			}),
     			style : new ol.style.Style({
     				image : new ol.style.Icon({
     					src : 'images/mm_20_green.png'
     				})
     			})

     		});
     		map.addLayer(vectorSI);
     	}
    	
    	console.log("in init markers2:"+markers2+" "+markers2.length);
    	
    	var vectorLayer2 = new ol.layer.Vector({
     		title : 'Business Hubs',
     		source : new ol.source.Vector({
     			features : markers2
     		//array
     		}),
     		style : new ol.style.Style({
     			image : new ol.style.Icon({
     				src : 'images/mm_20_black.png' //Start location
     			})
     		})

     	});

     	map.addLayer(vectorLayer2);
    	
     	
     	try{
     		
     		if(markersStamp.length !=0){
     	 		//console.log("all markers:"+markersStamp);
     	 	var	vectorStamps = new ol.layer.Vector({
     	 			title : 'All SI Stamps',
     	 			source : new ol.source.Vector({
     	 				features : markersStamp   //marker list				
     	 			}),
     	 			style: new ol.style.Style({
     	 				image : new ol.style.Icon({
     	 					src :'images/mm_20_blue.png'
     	 					
     	 				})
     	 		})
     	 	
     	 	});
     	 		
     	 	map.addLayer(vectorStamps);
     	 		
     	 	}
     		
     		
     	}catch(e){
     		console.log(e)
     	}
    	
     	try{
     	 	 console.log("GML Layer:"+layergml)
     	 	 if(layergml==true){
     	 		 map.addLayer(vectorGML)
     	 		 layergml=false
     	 	 }
     	 	}
     	 	 catch(e){
     	 	   	 alert(e);
     	 	 }
     	
           	         	 
           	 var mark = new ol.Feature({
        			geometry: new ol.geom.Point([lon,lat]),
        			text : data
        		})
        		
        		
        		
        		var vectorDynamic =  new ol.layer.Vector({
        			title : 'Dynamic',
        			source : new ol.source.Vector({
        				features : [mark]
        			}),
        			style: new ol.style.Style({
        		        image: new ol.style.Icon({
        		          src: 'images/mm_20_red.png'
        		        })
        		      })

        		})
        	map.addLayer(vectorDynamic);
           
           	 var full_sc = new ol.control.FullScreen({
            	 	label : 'F'
            	 });
            	 map.addControl(full_sc);
           	 
           	var slider = new ol.control.ZoomSlider();
        	 map.addControl(slider);
        	 
        	 var scaleline = new ol.control.ScaleLine();
        	 map.addControl(scaleline);

        	 var full_sc = new ol.control.FullScreen({
        	 	label : 'F'
        	 });
        	 map.addControl(full_sc);
        	 
        	 var featureOverlay = new ol.layer.Vector({
      	 		source : new ol.source.Vector(),
      	 		map : map
      	 	//our map object
      	 	});

        	 map.on('click', function(event) {
        	 		
        	 		if (featureOverlay) {
        	 			featureOverlay.getSource().clear()  //clear overlays if previously present
        	 			map.removeLayer(featureOverlay)     //remove overlay layer
        	 		}

        	 		feature = map.forEachFeatureAtPixel(event.pixel, function(feature,  //reads feature at pixel which mouse is pointing
        	 				layer) {
        	 			return feature;
        	 		});

        	 		if (feature) {

        	 			var geometry = feature.getGeometry();
        	 			var coordinate = event.coordinate;

        	 			featureOverlay.getSource().addFeature(feature);   //add the pop-up to the overlay
        	 			if(feature.get('text'))
        	 			{
        	 			   content1 = '<h6>' + feature.get('text') + '</h6>';	//setting the content of popup for markers 
        	 			}
        	 			
        	 			content.innerHTML = content1;    //set the content to appropriate div 
        	 			overlay.setPosition(coordinate);  //set popup to show against the marker prope
        				//content1="";																				       

        	 		} 
        	 	else {
        	 			overlay.setPosition(undefined);   //close pop-up when mouse exits a particular feature. 
        	 		}
        	 	
        	 	});
            
        }
 
           </script>

</html>