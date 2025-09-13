<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@include file="dbConn.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="OpenLayers-6.9/libs/v6.9.0-dist/ol.css" type="text/css">
<script src="OpenLayers-6.9/libs/v6.9.0-dist/ol.js"></script>
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
Statement st = null;
double lat = 0,lon=0;
String loc="";
String LatitudeDir = "";
String LongitudeDir = "";
String dttm ="";

try{
Class.forName(MM_dbConn_DRIVER);
conn = DriverManager.getConnection(MM_dbConn_STRING,MM_dbConn_USERNAME,MM_dbConn_PASSWORD);
st = conn.createStatement();
String vehicleno = request.getParameter("VehicleNo");
vehicleno = vehicleno.replaceAll(" ","");

String sql = "select * from db_gps.t_onlinedata where REPLACE(vehicleregno,' ','')='"+vehicleno+"'";
System.out.println(sql);
ResultSet rs = st.executeQuery(sql);
if(rs.next()){
	lat = rs.getDouble("LatitudePosition");
	lon = rs.getDouble("LongitudePosition");
	loc = rs.getString("Location");
	dttm = rs.getString("TheDate")+" "+rs.getString("TheTime");
	
	LatitudeDir = rs.getString("LatitudeDir");
    LongitudeDir = rs.getString("LongitudeDir");
    
    if(LatitudeDir.equals("S")){
    	lat = -1*lat;
    }
    if(LongitudeDir.equals("W")){
    	lon = -1*lon;
    }
    
    System.out.println(lat+","+lon+":->"+loc);
    
}else{
	out.print("<script>alert('Vehicle "+vehicleno+" Does Not Exists'); window.location.href='index.html' </script>");
}

}catch(Exception e){
	out.print("<script>alert('Some Error Occurred'); window.location.href='index.html' </script>");
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
    var desc1 = new String('<%=dttm%>') ;
	
    console.log("lat:",lat);
    console.log("lon:",lon);
    console.log("loc:",desc);
    
     	var container = document.getElementById('popup');
     	var content = document.getElementById('popup-content');
     	var closer = document.getElementById('popup-closer'); 
        
        /* var data = "<html><body>Latitude:"+lat+" Longitude:"+lon+"<br>Location:"+desc+"</body></html>"; */
        var data = "<html><body>Latitude / Longitude :"+lat+"&nbsp "+lon+"<br>Location:"+desc+"<br>Time:"+desc1+"</body></html>";
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