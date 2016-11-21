package de.jabc.cinco.meta.core.ui.highlight.animation;

import de.jabc.cinco.meta.core.ui.highlight.Highlight;

public class HighlightFade extends HighlightAnimation {
	
	public HighlightFade(Highlight hl, double effectTimeInSeconds) {
		super(hl, effectTimeInSeconds);
		step = steps;
	}
	
	@Override
	protected void prepare() {
		if (!hl.isOn()) hl.on();
	}
	
	@Override
	protected void work() {
		super.work();
		
		if (step-- <= 0) {
			quit();
		}
	}
	
	
}
