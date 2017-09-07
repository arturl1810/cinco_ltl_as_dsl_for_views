package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.gef.requests.GroupRequest

class EdgeLayoutRequest extends GroupRequest {
	
	final EdgeLayoutMode mode
	
	new(EdgeLayoutMode mode) {
		this.mode = mode
	}
	
}