package de.jabc.cinco.meta.core.ge.style.validation;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.validation.Check;

import style.AbstractShape;
import style.Appearance;
import style.ConnectionDecorator;
import style.ContainerShape;
import style.EdgeStyle;
import style.Image;
import style.NodeStyle;
import style.Shape;
import style.Style;
import style.StylePackage;
import style.Styles;
import de.jabc.cinco.meta.core.utils.PathValidator;

public class JStyleValidator extends AbstractStyleValidator{

	public static String NO_PATH = "noPathSpecified";
	public static String INVALID_PATH = "invalidPath";
	
	@Check
	public void imagePath(Image image) {
		if (image.getPath() == null || image.getPath().isEmpty())
 			warning("No Path specified", StylePackage.Literals.IMAGE__PATH, NO_PATH);
 		
		
 		String retVal = PathValidator.checkPath(image, image.getPath());
 		if (!retVal.isEmpty())
 			error(retVal, StylePackage.Literals.IMAGE__PATH, INVALID_PATH);
	}
	
	@Check
	public void checkUniqueStyleNames(NodeStyle ns) {		
		List<Style> nodeStyles = getStyles(ns).stream().
				filter( s -> s instanceof NodeStyle && s.getName().equals(ns.getName())).
				collect(Collectors.toList());

		if (nodeStyles.size() >= 2 )
			error("Duplicate nodeStyle definition: " + ns.getName(), StylePackage.Literals.STYLE__NAME);
	}		
	
	@Check
	public void checkUniqueStyleNames(EdgeStyle es) {
		List<Style> tmp = ((Styles) es.eContainer()).getStyles().stream().
				filter( s -> (s instanceof EdgeStyle) && (s.getName().equals(es.getName())) ).
				collect(Collectors.toList());
		
		if (tmp.size() >= 2)
			error("Duplicate edgeStyle definition: " + es.getName(), StylePackage.Literals.STYLE__NAME);
	}	
	
	@Check
	public void checkUniqueDecoratorNames(ConnectionDecorator cd) {
		List<ConnectionDecorator> filtered = ((EdgeStyle) cd.eContainer()).getDecorator().
			stream().filter(tmp -> tmp.getName() != null &&  tmp.getName().equals(cd.getName()) && !tmp.getName().isEmpty()).collect(Collectors.toList());
		if (filtered.size() >= 2)
			error("Duplicate decorator name: " + cd.getName(), StylePackage.Literals.CONNECTION_DECORATOR__NAME);		
	}
	
	@Check
	public void checkNoShapeNamesInDecorator(ConnectionDecorator cd){
		AbstractShape abstractShape = (AbstractShape) cd.getDecoratorShape();
		String sName = abstractShape.getName();
		if (sName != null && !sName.isEmpty())
			error("Naming elements not allowed here. Assign a name directly to the decorator", 
					StylePackage.Literals.CONNECTION_DECORATOR__DECORATOR_SHAPE);
	}

	@Check
	public void checkUniqueShapeNames(AbstractShape as) {
		AbstractShape mainShape = getMainShape(as);
		ArrayList<AbstractShape> shapes = new ArrayList<AbstractShape>();
		getAllShapes(mainShape, shapes);
		List<AbstractShape> namedShapes = shapes.stream().filter(s -> s.getName() != null && s.getName().equals(as.getName())).collect(Collectors.toList());
		if (namedShapes.size() >= 2 )
			error("Duplicate shape name..." , StylePackage.Literals.ABSTRACT_SHAPE__NAME);
		
	}
	
	public void uniqueShapeNames(Shape shape, String string) {
		
	}
	
	private List<Style> getStyles(Style s) {
		return ((Styles) s.eContainer()).getStyles();
	}
	
	private void getAllShapes(AbstractShape as, List<AbstractShape> result) {
		result.add(as);
		if (as instanceof ContainerShape)
			for (AbstractShape s : ((ContainerShape) as).getChildren()) {
				getAllShapes(s, result);
			}
	}
	
	private AbstractShape getMainShape(AbstractShape as) {
		AbstractShape i = as;
		while (i != null && i.eContainer() instanceof AbstractShape)
			i = (AbstractShape) i.eContainer();
		return i;
	}
}
