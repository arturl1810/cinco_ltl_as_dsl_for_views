package de.jabc.cinco.meta.core.referenceregistry

import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject

package class UriRequest extends Request<URI,Map<String,EObject>> {
	
	new(URI key) {
		super(key)
	}
		
}