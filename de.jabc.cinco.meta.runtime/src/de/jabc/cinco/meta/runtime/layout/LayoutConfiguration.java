package de.jabc.cinco.meta.runtime.layout;

import java.util.Map;

public enum LayoutConfiguration {

	DISABLE_RESIZE (0),
	
	MIN_WIDTH (120),
	MAX_WIDTH (-1),
	FIXED_WIDTH (-1),
	DISABLE_RESIZE_WIDTH (0),
	SHRINK_TO_CHILDREN_WIDTH (1),
	
	MIN_HEIGHT (24),
	MAX_HEIGHT (-1),
	FIXED_HEIGHT (-1),
	DISABLE_RESIZE_HEIGHT (0),
	SHRINK_TO_CHILDREN_HEIGHT (1),
	
	PADDING_X (5),
	PADDING_Y (5),
	PADDING_LEFT (5),
	PADDING_RIGHT (5),
	PADDING_TOP (5),
	PADDING_BOTTOM (5);
	
	public int defaultValue = 0;
	
	private LayoutConfiguration(int defaultValue) {
		this.defaultValue = defaultValue;
	}
	
	public int from(Map<LayoutConfiguration,?> config) {
		Object value = config.get(this);
		if (value == null) {
			return this.defaultValue;
		}
		return
			(value instanceof Integer)
			? (Integer) value
			: (value instanceof Boolean)
				? ((Boolean) value)
					? 1
					: 0
				: Integer.parseInt(value.toString());
	}
}
