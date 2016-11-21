package de.jabc.cinco.meta.core.ui.highlight.animation;

import de.jabc.cinco.meta.core.ui.highlight.Highlight;

public class HighlightSwell extends HighlightAnimation {
	
	public HighlightSwell(Highlight hl, double effectTimeInSeconds) {
		super(hl, effectTimeInSeconds);
		System.out.println("[SWELL] steps: " + steps);
	}
	
	@Override
	protected void work() {
		System.out.println("[SWELL] work: " + step + " of " + steps);
		super.work();
		
		if (step++ >= steps) {
			quit();
		}
	}
	
	@Override
	public void afterwork() {
		// do nothing
	}
}
