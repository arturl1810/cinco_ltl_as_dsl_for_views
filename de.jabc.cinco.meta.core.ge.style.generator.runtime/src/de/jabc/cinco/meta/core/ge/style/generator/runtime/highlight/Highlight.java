package de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.concurrent.ConcurrentHashMap;

import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.styles.Color;
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory;
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IDecorator;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.util.ColorConstant;
import org.eclipse.graphiti.util.IColorConstant;
import org.eclipse.swt.SWTException;

import com.google.common.collect.Sets;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.editor.LazyDiagram;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.animation.HighlightAnimation;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.animation.HighlightBlink;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.animation.HighlightFade;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.animation.HighlightFlash;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.animation.HighlightSwell;
import de.jabc.cinco.meta.core.utils.registry.InstanceRegistry;
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension;
import graphmodel.ModelElement;

public class Highlight {

	public static InstanceRegistry<Highlight> INSTANCE = new InstanceRegistry<>(() -> new Highlight());

	private Set<PictogramElement> pes = new HashSet<>();
	private Set<PictogramElement> affected = ConcurrentHashMap.newKeySet();
	private Map<PictogramElement, ConnectionDecoratorLayouter> layouters = new HashMap<>();
	private Map<PictogramElement, HighlightDecorator> decos = new HashMap<>();

	private HighlightDecorator deco;
	private Color diagramHltColor;
	private Color diagramOrgColor;
	private HighlightAnimation animation;

	private boolean on = false;
	private boolean refresh = true;
	
	private WorkbenchExtension workbenchX = new WorkbenchExtension();

	public Highlight() {
		ColorConstant c = ColorProvider.INSTANCE.get().next();
		deco = new HighlightDecorator(ColorProvider.amend(c, 0.7), ColorProvider.amend(c, 1.3));
	}

	public Highlight(IColorConstant fgColor, IColorConstant bgColor) {
		deco = new HighlightDecorator(fgColor, bgColor);
	}

	public Highlight(Highlight archetype) {
		this(archetype.deco.getForegroundColor(), archetype.deco.getBackgroundColor());
		pes = archetype.pes;
	}

	public Highlight add(PictogramElement pe) {
		if (pes.add(pe) && isOn()) {
			on(pe, true);
		}
		return this;
	}

	public Highlight add(ModelElement me) {
		add(workbenchX.getPictogramElement(me));
		return this;
	}

	public Highlight remove(PictogramElement pe) {
		if (pes.remove(pe) && isOn()) {
			off(pe, true);
		}
		return this;
	}

	public Highlight remove(ModelElement me) {
		remove(workbenchX.getPictogramElement(me));
		return this;
	}

	public Highlight clear() {
		if (isOn()) {
			off();
		}
		pes.clear();
		return this;
	}

	public boolean isActive(PictogramElement pe) {
		Stack<IDecorator> reg = DecoratorRegistry.INSTANCE.get().get(pe);
		return !reg.isEmpty() && (getDeco(pe) == reg.lastElement());
	}

	public boolean isOn() {
		return on;
	}

	public IColorConstant getForegroundColor() {
		return deco.getForegroundColor();
	}

	public IColorConstant getForegroundColor(PictogramElement pe) {
		return getDeco(pe).getForegroundColor();
	}

	public IColorConstant getBackgroundColor() {
		return deco.getBackgroundColor();
	}

	public IColorConstant getBackgroundColor(PictogramElement pe) {
		return getDeco(pe).getBackgroundColor();
	}

	public Highlight setForegroundColor(IColorConstant fgColor) {
		deco.setForegroundColor(fgColor);
		refreshAll();
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setForegroundColor(int red, int green, int blue) {
		deco.setForegroundColor(new ColorConstant(red, green, blue));
		refreshAll();
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setForegroundColor(String hexRGBString) {
		deco.setForegroundColor(new ColorConstant(hexRGBString));
		refreshAll();
		return this;
	}

	public Highlight setForegroundColor(PictogramElement pe, IColorConstant fgColor) {
		getDeco(pe).setForegroundColor(fgColor);
		refresh(pe);
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setForegroundColor(PictogramElement pe, int red, int green, int blue) {
		getDeco(pe).setForegroundColor(new ColorConstant(red, green, blue));
		refresh(pe);
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setForegroundColor(PictogramElement pe, String hexRGBString) {
		getDeco(pe).setForegroundColor(new ColorConstant(hexRGBString));
		refresh(pe);
		return this;
	}

	public Highlight setBackgroundColor(IColorConstant bgColor) {
		deco.setBackgroundColor(bgColor);
		refreshAll();
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setBackgroundColor(int red, int green, int blue) {
		deco.setBackgroundColor(new ColorConstant(red, green, blue));
		refreshAll();
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setBackgroundColor(String hexRGBString) {
		deco.setBackgroundColor(new ColorConstant(hexRGBString));
		refreshAll();
		return this;
	}

	public Highlight setBackgroundColor(PictogramElement pe, IColorConstant bgColor) {
		getDeco(pe).setBackgroundColor(bgColor);
		refresh(pe);
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setBackgroundColor(PictogramElement pe, int red, int green, int blue) {
		getDeco(pe).setBackgroundColor(new ColorConstant(red, green, blue));
		refresh(pe);
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setBackgroundColor(PictogramElement pe, String hexRGBString) {
		getDeco(pe).setBackgroundColor(new ColorConstant(hexRGBString));
		refresh(pe);
		return this;
	}
	
	public Highlight setColors(PictogramElement pe, IColorConstant fgColor, IColorConstant bgColor) {
		HighlightDecorator deco = getDeco(pe);
		deco.setForegroundColor(fgColor);
		deco.setBackgroundColor(bgColor);
		refresh(pe);
		return this;
	}

	public ArrayList<PictogramElement> getPictogramElements() {
		return new ArrayList<>(pes);
	}

	public Highlight setPictogramElements(PictogramElement... pes) {
		return setPictogramElements((Iterable<PictogramElement>) Arrays.asList(pes));
	}

	public Highlight setPictogramElements(Iterable<PictogramElement> pes) {
		Set<PictogramElement> current = new HashSet<>(this.pes);
		Set<PictogramElement> newone = Sets.newHashSet(pes);
		Set<PictogramElement> result = new HashSet<>();
		for (PictogramElement pe : current) {
			if (newone.contains(pe)) {
				result.add(pe);
				newone.remove(pe);
			} else if (isOn()) {
				off(pe, false);
			}
		}
		for (PictogramElement pe : newone) {
			result.add(pe);
			if (isOn()) {
				on(pe, false);
			}
		}
		this.pes = result;
		refreshAll();
		return this;
	}
	
	public Highlight on() {
		for (final PictogramElement pe : pes) {
			on(pe, false);
		}
		on = true;
		refreshAll();
		return this;
	}

	protected Highlight on(PictogramElement pe, boolean triggerDiagramRefresh) {
		if (pe instanceof Diagram) {
			diagramOn((Diagram) pe);
		} else {
			DecoratorRegistry.INSTANCE.get().get(pe).push(getDeco(pe));
		}
		affected.add(pe);
		registerConnectionDecoratorLayouter(pe);
		if (triggerDiagramRefresh)
			refresh(pe);
		return this;
	}

	public Highlight flash() {
		flash(1.0);
		return this;
	}

	public Highlight flash(double effectTimeInSeconds) {
		startAnimation(new HighlightFlash(this, effectTimeInSeconds));
		return this;
	}

	public Highlight blink() {
		blink(1.0);
		return this;
	}

	public Highlight blink(double effectTimeInSeconds) {
		startAnimation(new HighlightBlink(this, effectTimeInSeconds));
		return this;
	}

	public Highlight swell() {
		swell(0.5);
		return this;
	}

	public Highlight swell(double effectTimeInSeconds) {
		startAnimation(new HighlightSwell(this, effectTimeInSeconds));
		return this;
	}

	public Highlight fade() {
		fade(0.5);
		return this;
	}

	public Highlight fade(double effectTimeInSeconds) {
		startAnimation(new HighlightFade(this, effectTimeInSeconds));
		return this;
	}

	public Highlight setAnimation(HighlightAnimation animation) {
		if (this.animation != null) {
			this.animation.quit();
		}
		this.animation = animation;
		return this;
	}
	
	protected Highlight startAnimation(HighlightAnimation animation) {
		if (this.animation != null) {
			this.animation.onDone(() -> {
				this.animation = animation;
				animation.start();
			});
			this.animation.quit();
			this.animation = null;
		} else {
			this.animation = animation;
			animation.start();
		}
		return this;
	}

	public Highlight off() {
		if (animation != null) {
			animation.quit();
		}
		removeDecos();
		return this;
	}

	protected Highlight off(PictogramElement pe, boolean triggerDiagramRefresh) {
		if (pe instanceof Diagram) {
			diagramOff((Diagram) pe);
		} else {
			DecoratorRegistry.INSTANCE.get().get(pe).remove(getDeco(pe));
		}
		unregisterConnectionDecoratorLayouter(pe);
		if (triggerDiagramRefresh) {
			refresh(pe, () -> affected.remove(pe));
		}
		return this;
	}

	protected void removeDecos() {
		for (PictogramElement pe : new HashSet<>(affected)) {
			off(pe, false);
		}
		List<PictogramElement> orgAffected = new ArrayList<>(this.affected);
		affected.clear();
		on = false;
		refreshAll(orgAffected);
	}

	protected Highlight diagramOn(Diagram diagram) {
		final GraphicsAlgorithm ga = diagram.getGraphicsAlgorithm();
		assertDiagramHltColor(diagram);
		diagramOrgColor = ga.getBackground();
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramHltColor);
		} catch (IllegalStateException expected) {
			// expected and ok as we want a non-permanent diagram color
		}
		return this;
	}

	protected Highlight diagramOff(Diagram diagram) {
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramOrgColor);
		} catch (IllegalStateException expected) {
			// expected and ok as we want to reset the diagram color
		}
		return this;
	}

	private void registerConnectionDecoratorLayouter(PictogramElement pe) {
		if (pe instanceof Connection) workbenchX.sync(() -> 
			layouters.put(pe, ConnectionDecoratorLayouter.applyTo(pe))
		);
	}

	private void unregisterConnectionDecoratorLayouter(PictogramElement pe) {
		ConnectionDecoratorLayouter layouter = layouters.remove(pe);
		if (layouter != null)
			layouter.setUnregisterAfterNextLayout(true);
	}

	private HighlightDecorator getDeco(PictogramElement pe) {
		HighlightDecorator deco = decos.get(pe);
		if (deco == null) {
			deco = new HighlightDecorator(this.deco);
			decos.put(pe, deco);
		}
		return deco;
	}
	
	private void refresh(PictogramElement pe) {
		refresh(pe, null);
	}
	
	private void refresh(final PictogramElement pe, final Runnable onDone) {
		workbenchX.async(() -> {
			DiagramBehavior db = getDiagramBehavior(pe);
			if (db != null)
				refreshRenderingDecorators(db, pe);
			else System.err.println("[Highlight] No DiagramBehavior found for pictogram: " + pe);
			if (onDone != null)
				onDone.run();
		});
	}
	
	public void refreshAll() {
		refreshAll(new ArrayList<>(this.affected));
	}
	
	public void refreshAll(List<PictogramElement> affected) {
		workbenchX.async(() -> {
			if (!affected.isEmpty()) {
				PictogramElement pe = affected.iterator().next();
				DiagramBehavior db = getDiagramBehavior(pe);
				if (db != null)
					for (PictogramElement p : affected)
						refreshRenderingDecorators(db, p);
				else System.err.println("[Highlight] No DiagramBehavior found for pictogram: " + pe);
			}
		});
	}
	
	private void refreshRenderingDecorators(DiagramBehavior db, PictogramElement p) {
		try {
			db.refreshRenderingDecorators(p);
		} catch(SWTException | IllegalArgumentException e) {
			// Sometimes problems occur inside Graphiti while
			// handling SWT colors; eat that silently
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	private DiagramBehavior getDiagramBehavior(PictogramElement pe) {
		Diagram diagram = workbenchX.getDiagram(pe);
		if (diagram instanceof LazyDiagram) {
			DiagramBehavior db = ((LazyDiagram) diagram).getDiagramBehavior();
			if (db != null)
				return db;
		}
		return workbenchX.getDiagramBehavior(pe);
	}
	
	public boolean isRefresh() {
		return refresh;
	}
	
	public void setRefresh(boolean refresh) {
		this.refresh = refresh;
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
}
