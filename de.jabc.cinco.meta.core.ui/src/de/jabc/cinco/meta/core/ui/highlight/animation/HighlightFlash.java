package de.jabc.cinco.meta.core.ui.highlight.animation;

import de.jabc.cinco.meta.core.ui.highlight.Highlight;

public class HighlightFlash extends HighlightAnimation {
	
	private boolean swelling = true;

	public HighlightFlash(Highlight hl, double effectTimeInSeconds) {
		super(hl, effectTimeInSeconds);
		steps = (int) (steps * 0.5);
	}
	
	@Override
	protected void work() {
		super.work();
		if (swelling) {
			if (step++ >= steps) {
				swelling = false;
				step = steps;
			}
		} else if (step-- <= 0) {
			quit();
		}
	}
}
