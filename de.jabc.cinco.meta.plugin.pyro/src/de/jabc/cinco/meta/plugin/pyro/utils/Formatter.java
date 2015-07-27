package de.jabc.cinco.meta.plugin.pyro.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.pyro.model.FontType;
import de.jabc.cinco.meta.plugin.pyro.model.PolygonPoint;
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement;
import style.Color;
import style.DecoratorShapes;
import style.Font;
import style.MultiText;
import style.Point;
import style.Shape;
import style.Text;

public class Formatter {
	public static String toHex(Color color)
	{
		return String.format("%02x%02x%02x", color.getR(), color.getG(), color.getB());
	}
	
	public static String getShapeText(Shape shape)
	{
		if(shape instanceof Text) {
			return ((Text) shape).getValue();
		}
		if(shape instanceof MultiText) {
			return ((MultiText) shape).getValue();
		}
		return "";
	}
	
	public static String getLabelText(StyledModelElement styledModelElement)
	{
		ArrayList<String> labels = styledModelElement.getLabel();
		if(labels.isEmpty()){
			return "";
		}
		Object[] args = new Object[labels.size()];
		for(int i = 0;i<args.length;i++) {
			Pattern pattern = Pattern.compile("\\{([^}]*)\\}");
			Matcher matcher = pattern.matcher(labels.get(i));
			if (matcher.find())
			{
				String attrName = matcher.group(0);
				attrName = attrName.substring(1, attrName.length()-1);
				args[i] = "'+ getAttributeLabel(attributes,'"+attrName+"') +'";
			}
		}
		String formatString = styledModelElement.getStyledLabel().getValue();
		String templateString = String.format(formatString, args);
		return templateString;
	}
	
	public static String getEdgeConnector(DecoratorShapes decorator,double width)
	{
		if(decorator == DecoratorShapes.ARROW) {
			return "d: 'M 0 0 L "+width+" "+width+" 0 0 L "+width+" -"+width+" 0 0 "+width+" 0 z'";
		}
		if(decorator == DecoratorShapes.CIRCLE) {
			String d = "d: 'M ";
			int countPoints = (int) Math.round(width);
			countPoints*=10;
			double radius = width;
			double slice = 2 * Math.PI / countPoints;
			for (int i = 0; i < countPoints ; i++)
		    {
		        double angle = slice * i;
		        double newX = (0 + radius * Math.cos(angle));
		        double newY = (0 + radius * Math.sin(angle));
		        d += newX+" "+newY+" ";
		    }
			return d + "z'";
			
		}
		if(decorator == DecoratorShapes.DIAMOND) {
			return "d: 'M 0 0 L "+width+" "+width+" "+(2*width)+" 0 L "+width+" -"+width+" 0 0 z'";
		}
		if(decorator == DecoratorShapes.TRIANGLE) {
			return "d: 'M "+(2*width)+" 0 L 0 "+width+" L "+(2*width)+" "+(2*width)+" z'";
		}
		return "d: 'M 0 0 L 0 0 L 0 0 z'";
	}
	public static FontType toFontType(Font font) {
		if(font.isIsBold()) {
			return FontType.BOLD;
		}
		if(font.isIsItalic()) {
			return FontType.ITALIC;
		}
		return FontType.NORMAL;
	}
	
	public static ArrayList<PolygonPoint> getPolygonPoints(List<Point> points) {
		ArrayList<PolygonPoint> polygonPoints = new ArrayList<PolygonPoint>();
		for(Point point : points){
			polygonPoints.add(new PolygonPoint(point.getX(),point.getY()));
		}
		return polygonPoints;
	}
	
	public static void printConnectionConstraints(ArrayList<ConnectionConstraint> ccs) {
		for(ConnectionConstraint cc : ccs) {
			System.out.println(cc.toString());
		}
	}
}
