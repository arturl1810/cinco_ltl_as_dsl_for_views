package de.jabc.cinco.meta.core.utils.dummycreator;

import org.eclipse.emf.common.util.BasicEList;

import style.AbsolutPosition;
import style.AbstractPosition;
import style.AbstractShape;
import style.Appearance;
import style.Color;
import style.ConnectionDecorator;
import style.DecoratorShapes;
import style.EdgeStyle;
import style.Ellipse;
import style.NodeStyle;
import style.PredefinedDecorator;
import style.Rectangle;
import style.RoundedRectangle;
import style.Size;
import style.StyleFactory;
import style.Styles;
import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.IncomingEdgeElementConnection;
import mgl.MglFactory;
//import mgl.MglPackage;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;
//import mgl.ReferencedEClass;

public class DummyGenerator {

	//*****************************************			GRPAHMODEL		*********************************//
	public static GraphModel createDummyGraphModel() {
//		GraphModel gm = MglFactory.eINSTANCE.createGraphModel();
//		setGraphModelAttributes(gm);
//
//		Node n1 = createNode("Start");
//		n1.getAttributes().add(createAttribute("EString", "label", 1, 0));
//		n1.getAnnotations().add(createStyleAnnotation("circle"));
//		
////		ReferencedEClass n2 = createRefEClass("ExtNode");
////		n2.getAnnotations().add(createStyleAnnotation("rrect"));
//		
//		NodeContainer c1 = createContainer("Swimlane");
//		c1.getContainableElements().add(createGEC(-1, 0, n1, c1));
//		c1.getAnnotations().add(createStyleAnnotation("rect"));
//		
//		Edge e1 = createEdge("Transition");
//		e1.getAnnotations().add(createStyleAnnotation("simpleArrow"));
//		
//		n1.getOutgoingEdgeConnections().add(createOEEC(-1, 0, e1));
////		n2.getIncomingEdgeConnections().add(createIEEC(-1, 0, e1));
////		n2.getOutgoingEdgeConnections().add(createOEEC(-1, 0, e1));
//		
//		gm.getNodes().add(n1);
//		//gm.getNodes().add(n2);
//		
//		gm.getNodeContainers().add(c1);
//		
//		gm.getEdges().add(e1);
		GraphModel gm = MglFactory.eINSTANCE.createGraphModel();
		//setGraphModelAttributes(gm);

		
		
//		ReferencedEClass n2 = createRefEClass("ExtNode");
//		n2.getAnnotations().add(createStyleAnnotation("rrect"));
		
//		NodeContainer c1 = createContainer("Swimlane");
//		c1.getContainableElements().add(createGEC(-1, 0, n1, /*n2,*/ c1));
//		c1.getAnnotations().add(createStyleAnnotation("rect"));
		
//		n2.getIncomingEdgeConnections().add(createIEEC(-1, 0, e1));
//		n2.getOutgoingEdgeConnections().add(createOEEC(-1, 0, e1));
		
//		gm.getNodes().add(n2);
		
		//gm.getNodeContainers().add(c1);
		
		
		gm.setName("SomeGraph");
		gm.setNsURI("http:/cinco.de/product/somegraph");
		gm.setFileExtension("somegraph");
		gm.setPackage("blub.package");
		Edge transition = createEdge("Transition");
		Node someNode = createNode("SomeNode");
		someNode.getAttributes().add(createAttribute("EString", "label", -1,0));
		someNode.getIncomingEdgeConnections().add(createIEEC(-1, 0, transition));
		someNode.getOutgoingEdgeConnections().add(createOEEC(-1, 0, transition));
		//someNode.getAnnotations().add(createStyleAnnotation("ffjfjf"));
		//transition.getAnnotations().add(createStyleAnnotation("ffjfjf"));
		//gm.getAnnotations().add(createStyleAnnotation("ffjfjf"));
		gm.getNodes().add(someNode);
		gm.getEdges().add(transition);
		return prepareGraphModel(gm);
	}
	
	
	//*****************************************			STYLE			*********************************//
	public static Styles createDummyStyles() {
		Styles styles = StyleFactory.eINSTANCE.createStyles();
		
		Appearance app1 = createAppearance("default");
		app1.setForeground(createColor(0, 0, 0));
		app1.setBackground(createColor(133, 122, 54));
		app1.setLineWidth(2);
		
		NodeStyle ns1 = createNodeStyle("circle");
		Ellipse ms1 = createEllipse();
		setPositionAndSize(ms1, createPosition(0, 0), createSize(30, 30));
		ms1.setReferencedAppearance(app1);
		ns1.setMainShape(ms1);
		
		NodeStyle ns2 = createNodeStyle("rect");
		Rectangle ms2 = createRect();
		setPositionAndSize(ms2, createPosition(0, 0), createSize(150, 100));
		ms2.setReferencedAppearance(app1);
		ns2.setMainShape(ms2);
		
		NodeStyle ns3 = createNodeStyle("rrect");
		RoundedRectangle ms3 = createRRect(15,15);
		setPositionAndSize(ms3, createPosition(0, 0), createSize(50, 20));
		ms3.setReferencedAppearance(app1);
		ns3.setMainShape(ms3);
		
		EdgeStyle es1 = createEdgeStyle("simpleArrow");
		es1.setReferencedAppearance(app1);
		es1.getDecorator().add(createDecorator(1.0, false, DecoratorShapes.ARROW, app1));
		
		styles.getAppearances().add(app1);
		
		styles.getStyles().add(ns1);
		styles.getStyles().add(ns2);
		styles.getStyles().add(ns3);
		styles.getStyles().add(es1);
		
		return styles;
	}

	private static Node createNode(String name) {
		Node n = MglFactory.eINSTANCE.createNode();
		n.setName(name);
		n.setIsAbstract(false);
		return n;
	}
	
	private static NodeContainer createContainer(String name) {
		NodeContainer c = MglFactory.eINSTANCE.createNodeContainer();
		c.setName(name);
		return c;
	}

//	private static ReferencedEClass createRefEClass(String name) {
//		ReferencedEClass r = MglFactory.eINSTANCE.createReferencedEClass();
//		r.setName(name);
//		r.setType(MglPackage.Literals.NODE);
//		r.setReferenceName("mgl.Node");
//		return r;
//	}
	
	private static Edge createEdge(String name) {
		Edge e = MglFactory.eINSTANCE.createEdge();
		e.setName(name);
		return e;
	}
	
	private static Attribute createAttribute(String type, String name, int upper, int lower) {
		Attribute a = MglFactory.eINSTANCE.createAttribute();
		a.setName(name);
		a.setType(type);
		a.setUpperBound(upper);
		a.setLowerBound(lower);
		return a;
	}
	
	private static Annotation createStyleAnnotation(String...values) {
		return createAnnotation("style", values);
	}
	
	private static Annotation createAnnotation(String name, String...values) {
		Annotation a = MglFactory.eINSTANCE.createAnnotation();
		a.setName(name);
		for (String s : values)
			a.getValue().add(s);
		return a;
	}
	
	private static GraphicalElementContainment createGEC(int upper, int lower, GraphicalModelElement...elements) {
		GraphicalElementContainment gec = MglFactory.eINSTANCE.createGraphicalElementContainment();
		gec.setUpperBound(upper);
		gec.setLowerBound(lower);
		for (GraphicalModelElement e : elements)
			gec.getTypes().add(e);
		return gec;
	}
	
	private static IncomingEdgeElementConnection createIEEC(int upper, int lower, Edge...edges) {
		IncomingEdgeElementConnection ieec = MglFactory.eINSTANCE.createIncomingEdgeElementConnection();
		for (Edge e : edges)
			ieec.getConnectingEdges().add(e);
		return ieec;
	}
	
	private static OutgoingEdgeElementConnection createOEEC(int upper, int lower, Edge...edges) {
		OutgoingEdgeElementConnection oeec = MglFactory.eINSTANCE.createOutgoingEdgeElementConnection();
		oeec.setUpperBound(upper);
		oeec.setLowerBound(lower);
		for (Edge e : edges)
			oeec.getConnectingEdges().add(e);
		return oeec;
	}
	
	private static void setGraphModelAttributes(GraphModel gm) {
		gm.setName("Dummy");
		gm.setFileExtension(".dummy");
		gm.setNsURI("http://cinco.scce.info.product.dummy");
		gm.setPackage("info.scce.cinco.product.dummy");
	}


	
	private static NodeStyle createNodeStyle(String name) {
		NodeStyle s = StyleFactory.eINSTANCE.createNodeStyle();
		s.setName(name);
		return s;
	}
	
	private static EdgeStyle createEdgeStyle(String name) {
		EdgeStyle e = StyleFactory.eINSTANCE.createEdgeStyle();
		e.setName(name);
		return e;
	}
	
	private static Appearance createAppearance(String name) {
		Appearance a = StyleFactory.eINSTANCE.createAppearance();
		a.setName(name);
		return a;
	}
	
	private static Ellipse createEllipse() {
		Ellipse e = StyleFactory.eINSTANCE.createEllipse();
		return e;
	}
	
	private static Rectangle createRect() {
		Rectangle r = StyleFactory.eINSTANCE.createRectangle();
		return r;
	}
	
	private static RoundedRectangle createRRect(int cornerWidth, int cornerHeight) {
		RoundedRectangle rrect = StyleFactory.eINSTANCE.createRoundedRectangle();
		rrect.setCornerWidth(cornerWidth);
		rrect.setCornerHeight(cornerHeight);
		return rrect;
	}
	
	private static ConnectionDecorator createDecorator(double loc, boolean move, DecoratorShapes ds, Appearance app) {
		ConnectionDecorator cd = StyleFactory.eINSTANCE.createConnectionDecorator();
		cd.setLocation(loc);
		cd.setMovable(move);
		PredefinedDecorator pd = StyleFactory.eINSTANCE.createPredefinedDecorator();
		pd.setShape(ds);
		pd.setInlineAppearance(app);
		cd.setPredefinedDecorator(pd);
		return cd;
	}
	
	private static AbstractPosition createPosition(int x, int y) {
		AbsolutPosition p = StyleFactory.eINSTANCE.createAbsolutPosition();
		p.setXPos(x);
		p.setYPos(y);
		return p;
	}
	
	private static Size createSize(int w, int h) {
		Size s = StyleFactory.eINSTANCE.createSize();
		s.setWidth(w);
		s.setHeight(h);
		return s;
	}
	
	private static Color createColor(int r, int g, int b) {
		Color c = StyleFactory.eINSTANCE.createColor();
		c.setR(r);
		c.setG(g);
		c.setB(b);
		return c;
	}
	
	private static void setPositionAndSize(AbstractShape as, AbstractPosition pos, Size size) {
		as.setPosition(pos);
		as.setSize(size);
	}
	
	private static GraphModel prepareGraphModel(GraphModel graphModel){
		BasicEList<GraphicalModelElement> connectableElements = new BasicEList<GraphicalModelElement>();
		
		connectableElements.addAll(graphModel.getNodes());
		for(GraphicalModelElement elem:connectableElements){
			for(IncomingEdgeElementConnection connect:elem.getIncomingEdgeConnections()){
				if(connect.getConnectingEdges()==null||connect.getConnectingEdges().isEmpty()){
					
					connect.getConnectingEdges().addAll(graphModel.getEdges());
				}
			}
			for(OutgoingEdgeElementConnection connect:elem.getOutgoingEdgeConnections()){
				if(connect.getConnectingEdges()== null ||connect.getConnectingEdges().isEmpty()){
					
					connect.getConnectingEdges().addAll(graphModel.getEdges());
				}
			}
		}
		
		return graphModel;
		
		
	}
}
