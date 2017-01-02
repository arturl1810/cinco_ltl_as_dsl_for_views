/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.ge.style.validation

import de.jabc.cinco.meta.core.utils.PathValidator
import java.util.ArrayList
import org.eclipse.xtext.validation.Check
import style.AbstractShape
import style.Alignment
import style.Appearance
import style.Image
import style.NodeStyle
import style.StylePackage
import style.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import style.Polyline
import style.Polygon

//import org.eclipse.xtext.validation.Check

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class StyleValidator extends JStyleValidator {

//  public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					MyDslPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}
	
	public static val NO_PATH = 'noPathSpecified'
	public static val INVALID_PATH = 'invalidPath'

	@Check
	def checkConnectionDecoratorShapePosition(ConnectionDecorator cd) {
		if(cd.decoratorShape != null && cd.decoratorShape instanceof AbstractShape){
			var abs = cd.decoratorShape as AbstractShape
			if(abs.position != null)
				error("Positions are not allowed", StylePackage.Literals.CONNECTION_DECORATOR__DECORATOR_SHAPE)
		}
	}
	
	@Check
	def checkConnectionDecoratorShapeSize(ConnectionDecorator cd) {
		if(cd.decoratorShape != null && cd.decoratorShape instanceof AbstractShape){
			var abs = cd.decoratorShape as AbstractShape
			if(abs.size.height < 0  || abs.size.width < 0 || abs.size.height > 1000  || abs.size.width > 1000 )
				warning("The size should be in [0,1000]", StylePackage.Literals.CONNECTION_DECORATOR__DECORATOR_SHAPE)
		}
	}
	
	@Check
	def checkConnectionDecoratorLocation(ConnectionDecorator cd) {	
		if(cd.location>1 || cd.location <0)
			warning("The location should be in [0,1]", StylePackage.Literals.CONNECTION_DECORATOR__LOCATION)
	}
	
	@Check
 	def checkImagePath (Image image) {
 		if (image.path.nullOrEmpty)
 			warning('No Path specified', StylePackage.Literals.IMAGE__PATH, NO_PATH)
 		
 		val retVal = PathValidator.checkPath(image, image.path) as String
 		if (!retVal.empty)
 			error(retVal, StylePackage.Literals.IMAGE__PATH, INVALID_PATH)
 	}
	
	@Check
	def checkAppearanceInheritance(Appearance app) {
		var retvalList = checkInheritance(app)
		if (!retvalList.nullOrEmpty)
			error("Circle in appearance inheritances caused by: " + retvalList, StylePackage.Literals.APPEARANCE__PARENT)
	}
	
	def checkInheritance(Appearance app) {
		var current = app
		var apps = new ArrayList
		while (current != null) {
			if (apps.contains(current.name))
				return apps
			apps.add(current.name)
			current = current.parent
		}
	}
	
	@Check
	def checkColorBackground(Appearance app){
		if (app.background.b > 255 || app.background.r > 255 || app.background.g > 255)
			error("Number(s) too large", StylePackage.Literals.APPEARANCE__BACKGROUND)
		if (app.background.b < 0 || app.background.r < 0 || app.background.g < 0)
			error("Number(s) has to be positiv", StylePackage.Literals.APPEARANCE__BACKGROUND)
	}
	
	@Check
	def checkColorForeground(Appearance app){
		if (app.foreground.b > 255 || app.foreground.r > 255 || app.foreground.g > 255)
			error("Number(s) too large", StylePackage.Literals.APPEARANCE__FOREGROUND)
		if (app.foreground.b < 0 || app.foreground.r < 0 || app.foreground.g < 0)
			error("Number(s) has to be positiv", StylePackage.Literals.APPEARANCE__FOREGROUND)
	}
	
	@Check
	def checkMainShapePosition(AbstractShape abs) {
		if (abs.eContainer instanceof NodeStyle) {
			val pos = abs.position
			if (pos instanceof Alignment)
				error("Relativ positions are not allowed in the topmost element", StylePackage.Literals.ABSTRACT_SHAPE__POSITION);
		}
	}
	
}
