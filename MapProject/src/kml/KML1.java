package kml;

import java.io.File;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class KML1 {
   public static boolean generateKMLFORLINE(List coordinatesList, String fileName, HashMap startMarker, HashMap endMarker, String color) {
      boolean flag = false;
      String outputString = "<?xml version='1.0' encoding='utf-8'?><kml xmlns='http://earth.google.com/kml/2.0'><Folder><name>Shapefile Converter Generated File</name><open>1</open>\n<Placemark>\n<name> </name>\n<Style>\n<LineStyle><color>" + color + "</color><width>3</width>" + "</LineStyle></Style>";
      String name = "";
      String description = "";
      String coordinates = "";

      HashMap coordinateMap;
      for(Iterator iterator = coordinatesList.iterator(); iterator.hasNext(); coordinates = coordinates + (String)coordinateMap.get("longi") + "," + (String)coordinateMap.get("lat") + ",0 ") {
         coordinateMap = (HashMap)iterator.next();
      }

      outputString = outputString + "<LineString><coordinates>" + coordinates + "</coordinates>\n" + "</LineString></Placemark>\n";
      coordinates = coordinates + (String)startMarker.get("longi") + "," + (String)startMarker.get("lat") + ",0 ";
      outputString = outputString + "</Folder>\n</kml>\n";

      try {
         File f = new File(fileName);
         FileOutputStream fop = new FileOutputStream(f);
         fop.write(outputString.getBytes());
         fop.close();
         flag = true;
      } catch (Exception var12) {
         var12.printStackTrace();
      }

      return flag;
   }
}
