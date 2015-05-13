package de.jabc.cinco.meta.plugin.papyrus.utils;

import java.util.ArrayList;
import java.util.List;

import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.FontType;
import de.jabc.cinco.meta.plugin.papyrus.model.PolygonPoint;
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
	
	public static String getEdgeConnector(DecoratorShapes decorator)
	{
		if(decorator == DecoratorShapes.ARROW) {
			return "d: 'M 10 0 L 0 5 L 0 0 z'";
		}
		if(decorator == DecoratorShapes.CIRCLE) {
			
		}
		if(decorator == DecoratorShapes.DIAMOND) {
			
		}
		if(decorator == DecoratorShapes.TRIANGLE) {
			return "d: M 10 0 L 0 5 L 10 10 z";
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
