package de.jabc.cinco.meta.core.ui.highlight.animation;

import java.util.HashSet;
import java.util.Set;

import java.util.Stack;

import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IColorDecorator;
import org.eclipse.graphiti.tb.IDecorator;
import org.eclipse.graphiti.util.IColorConstant;

import de.jabc.cinco.meta.core.ui.highlight.ColorProvider;
import de.jabc.cinco.meta.core.ui.highlight.DecoratorRegistry;
import de.jabc.cinco.meta.core.ui.highlight.Highlight;
import de.jabc.cinco.meta.core.utils.job.ReiteratingThread;

public abstract class HighlightAnimation extends ReiteratingThread {

	final static Set<HighlightAnimation> ANIMATIONS = new HashSet<>();
	
	public static void quitAll() {
		for (HighlightAnimation anim : ANIMATIONS) {
			anim.quit();
		}
	}
	
	final static int EffectIntervalInMs = 30;
	
	private Highlight hl;
	private int step = 0;
	private int steps = 30;
	
	public HighlightAnimation(Highlight hl, double effectTimeInSeconds) {
		super(EffectIntervalInMs);
		ANIMATIONS.add(this);
		onDone(() -> ANIMATIONS.remove(this));
		steps = (int) (effectTimeInSeconds * 1000 / HighlightAnimation.EffectIntervalInMs);
		this.hl = hl;
	}
	
	@Override
	protected void prepare() {
		mixColors((double) step / (double) steps);
		hl.on();
	}
	
	@Override
	protected void work() {
		mixColors((double) step / (double) steps);
		step = nextStep(step, steps);
	}
	
	abstract int nextStep(int step, int steps);
	
	@Override
	public void cleanup() {
		hl.off();
		
	}
	
	public Highlight getHighlight() {
		return hl;
	}
	
	public int getStep() {
		return step;
	}
	
	public void setStep(int step) {
		this.step = step;
	}
	
	public int getSteps() {
		return steps;
	}
	
	public void setSteps(int steps) {
		this.steps = steps;
	}
	
	void mixColors(double ratio) {
		for (PictogramElement pe : hl.getPictogramElements()) {
			mixColors(pe, hl, ratio);
		}
	}

	void mixColors(PictogramElement pe, Highlight hl, double ratio) {
		hl.setBackgroundColor(pe,
			ColorProvider.mix(
				getBackgroundColor(pe),
				hl.getBackgroundColor(),
				ratio));
		hl.setForegroundColor(pe,
			ColorProvider.mix(
				getForegroundColor(pe),
				hl.getForegroundColor(),
				ratio));
	}
	
	IColorConstant getBackgroundColor(PictogramElement pe) {
		IDecorator deco = getDecorator(pe);
		if (deco != null && deco instanceof IColorDecorator) {
			return ((IColorDecorator) deco).getBackgroundColor();
		}
		return ColorProvider.toColorConstant(
				pe.getGraphicsAlgorithm().getBackground());
	}
	
	IColorConstant getForegroundColor(PictogramElement pe) {
		IDecorator deco = getDecorator(pe);
		if (deco != null && deco instanceof IColorDecorator) {
			return ((IColorDecorator) deco).getForegroundColor();
		}
		return ColorProvider.toColorConstant(
				pe.getGraphicsAlgorithm().getForeground());
	}
	
	IDecorator getDecorator(PictogramElement pe) {
		Stack<IDecorator> reg = DecoratorRegistry.INSTANCE.get().get(pe);
		if (hl.isOn()) {
			if (reg.size() > 1) {
				return reg.get(reg.size() - 2);
			}
		} else if (!reg.isEmpty()) {
			return reg.lastElement();
		}
		return null;
	}
}
