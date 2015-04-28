package de.jabc.cinco.meta.plugin.papyrus.utils;

import style.Color;
import style.DecoratorShapes;
import style.MultiText;
import style.Shape;
import style.Text;

public class Formatter {
	public static String toHex(Color color)
	{
		return String.format("#%02x%02x%02x", color.getR(), color.getG(), color.getB());
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
}
