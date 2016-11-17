package de.jabc.cinco.meta.core.ui.highlight;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;

import graphmodel.ModelElement;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.styles.Color;
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory;
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IDecorator;
import org.eclipse.graphiti.util.ColorConstant;
import org.eclipse.graphiti.util.IColorConstant;

public class Highlight {
	
	public static InstanceRegistry<Highlight> INSTANCE = new InstanceRegistry<>(() -> new Highlight());
	
	private HighlightDecorator deco = new HighlightDecorator(
			new ColorConstant(20, 150, 20), new ColorConstant(240, 255, 240));
	
	private Set<PictogramElement> pes = new HashSet<>();
	private Set<PictogramElement> affected = new HashSet<>();
	private Map<PictogramElement, ConnectionDecoratorLayouter> layouters = new HashMap<>();
	private Color diagramHltColor;
	private Color diagramOrgColor;
	private boolean on = false;
	
	public Highlight() {};
	
	public Highlight(IColorConstant fgColor, IColorConstant bgColor) {
		this();
		deco = new HighlightDecorator(fgColor, bgColor);
	}
	
	public Highlight(Highlight archetype) {
		this(archetype.deco.getForegroundColor(), archetype.deco.getBackgroundColor());
		pes = archetype.pes;
	}
	
	public Highlight add(PictogramElement pe) {
		if (pes.add(pe) && isOn()) {
			on(pe);
		}
		return this;
	}
	
	public Highlight add(ModelElement me) {
		add(eapi(me).getPictogramElement());
		return this;
	}
	
	public Highlight remove(PictogramElement pe) {
		if (pes.remove(pe) && isOn()) {
			off(pe);
		}
		return this;
	}
	
	public Highlight remove(ModelElement me) {
		remove(eapi(me).getPictogramElement());
		return this;
	}
	
	public Highlight clear() {
		System.out.println("Highlight clear");
		if (isOn()) {
			off();
		}
		pes.clear();
		return this;
	}
	
	public boolean isOn() {
		return on;
	}
	
	public Highlight setForegroundColor(IColorConstant fgColor) {
		deco.setForegroundColor(fgColor);
		return changed();
	}
	
	public Highlight setBackgroundColor(IColorConstant bgColor) {
		deco.setBackgroundColor(bgColor);
		return changed();
	}
	
	public Highlight setPictogramElements(PictogramElement... pes) {
		this.pes = new HashSet<PictogramElement>(Arrays.asList(pes));
		return changed();
	}
	
	public void on() {
		on(true);
	}
	
	public void on(boolean withdrawPrevious) {
		if (withdrawPrevious && isOn()) {
			off();
		}
		for (final PictogramElement pe : pes) {
			on(pe);
		}
		on = true;
	}
	
	public void on(PictogramElement pe) {
		if (pe instanceof Diagram) {
			diagramOn((Diagram)pe);
		} else {
			on(pe, deco);
		}
		affected.add(pe);
	}
	
	public void off() {
		for (PictogramElement pe : new HashSet<>(affected)) {
			off(pe);
		}
		on = false;
	}
	
	protected void off(PictogramElement pe) {
		if (pe instanceof Diagram) {
			diagramOff((Diagram)pe);
		} else {
			off(pe, null);
		}
		affected.remove(pe);
	}
	
	protected void diagramOn(Diagram diagram) {
		final GraphicsAlgorithm ga = diagram.getGraphicsAlgorithm();
		assertDiagramHltColor(diagram);
		diagramOrgColor = ga.getBackground();
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramHltColor);
		} catch(IllegalStateException expected) {
			// expected and ok as we want a non-permanent diagram color
		}
	}
	
	protected void diagramOff(Diagram diagram) {
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramOrgColor);
		} catch(IllegalStateException expected) {
			// expected and ok as we want to reset the diagram color
		}
	}
	
	protected void on(PictogramElement pe, final IDecorator dec) {
		DecoratorRegistry.INSTANCE.get().put(pe, dec);
		registerConnectionDecoratorLayouter(pe);
		HighlightUtils.triggerUpdate(pe);
	}
	
	protected void off(PictogramElement pe, final IDecorator dec) {
		DecoratorRegistry.INSTANCE.get().put(pe, dec);
		unregisterConnectionDecoratorLayouter(pe);
		HighlightUtils.triggerUpdate(pe);
	}
	
	private void registerConnectionDecoratorLayouter(PictogramElement pe) {
		if (pe instanceof Connection)
			layouters.put(pe, ConnectionDecoratorLayouter.applyTo(pe));
	}
	
	private void unregisterConnectionDecoratorLayouter(PictogramElement pe) {
		ConnectionDecoratorLayouter layouter = layouters.remove(pe);
		if (layouter != null)
			layouter.setUnregisterAfterNextLayout(true);
	}

	private void assertDiagramHltColor(final Diagram diagram) {
		if (diagramHltColor == null) {
			IColorConstant clr = deco.getBackgroundColor();
			diagramHltColor = StylesFactory.eINSTANCE.createColor();
			diagramHltColor.eSet(StylesPackage.eINSTANCE.getColor_Red(), clr.getRed());
			diagramHltColor.eSet(StylesPackage.eINSTANCE.getColor_Green(), clr.getGreen());
			diagramHltColor.eSet(StylesPackage.eINSTANCE.getColor_Blue(), clr.getBlue());
		}
	}
	
	private Highlight changed() {
		if (isOn()) on(false);
		return this;
	}
		
}
