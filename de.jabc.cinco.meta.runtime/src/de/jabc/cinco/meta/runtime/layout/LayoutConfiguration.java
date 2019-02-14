package de.jabc.cinco.meta.runtime.layout;

import java.util.Map;

public enum LayoutConfiguration {
	
	MIN_WIDTH (120),
	MIN_HEIGHT (24),
	PADDING_X (5),
	PADDING_Y (1),
	PADDING_TOP (5),
	PADDING_BOTTOM (5);
	
	public int defaultValue = 0;
	
	private LayoutConfiguration(int defaultValue) {
		this.defaultValue = defaultValue;
	}
	
	public int from(Map<LayoutConfiguration,Integer> config) {
		Integer value = config.get(this);
		return value != null ? value : this.defaultValue;
	}
}
