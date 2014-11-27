package de.jabc.cinco.meta.core.mgl.scoping;

import java.util.LinkedHashSet;

import mgl.GraphModel;
import mgl.Import;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider;

import com.google.common.base.Predicate;

import de.jabc.cinco.meta.core.utils.PathValidator;

public class MGLImportUriGlobalScopeProvider extends ImportUriGlobalScopeProvider {

	@Override
	protected IScope getScope(Resource resource, boolean ignoreCase,
			EClass type, Predicate<IEObjectDescription> filter) {
		IScope scope = super.getScope(resource, ignoreCase, type, filter);
		return scope;
	}
	
	@Override
	protected LinkedHashSet<URI> getImportedUris(Resource resource) {
		LinkedHashSet<URI> uris = super.getImportedUris(resource);
		
		for (EObject o : resource.getContents()) {
			if (o instanceof GraphModel) {
				GraphModel gm = (GraphModel) o;
				for (Import i : gm.getImports()) {
					String retVal = PathValidator.checkPath(gm, i.getImportURI());
					if (retVal != null && !retVal.isEmpty())
						continue;
					URI uri = PathValidator.getURIForString(gm, i.getImportURI());
					uris.add(uri);
				}
			}
		}
		
		return uris;
	}
	
}
