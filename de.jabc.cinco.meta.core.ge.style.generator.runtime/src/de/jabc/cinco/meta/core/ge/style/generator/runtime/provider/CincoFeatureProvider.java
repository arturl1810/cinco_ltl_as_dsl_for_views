package de.jabc.cinco.meta.core.ge.style.generator.runtime.provider;

import org.eclipse.graphiti.features.IAddFeature;
import org.eclipse.graphiti.features.IFeature;
import org.eclipse.graphiti.features.context.IAddContext;
import org.eclipse.graphiti.features.context.IContext;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.context.ICreateContext;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAddFeaturePrime;

public interface CincoFeatureProvider {

	public IAddFeature[] getAllLibComponentAddFeatures();
//	public Object[] executeFeature(IFeature f, IContext c);
	
	@SuppressWarnings("restriction")
	public default java.lang.Object[] executeFeature(final org.eclipse.graphiti.features.IFeature f, final org.eclipse.graphiti.features.context.IContext c) {
		final java.lang.Object[] created = new Object[2];
		
		new de.jabc.cinco.meta.runtime.xapi.ResourceExtension().transact(f.getFeatureProvider().getDiagramTypeProvider().getDiagram().eResource(), new Runnable() {
			@Override
			public void run() {
				if (f instanceof de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateFeature) {
					
					de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateFeature cf = (de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateFeature) f;
					if (cf.canCreate((org.eclipse.graphiti.features.context.ICreateContext) c, true)) {
						java.lang.Object[] result = cf.create((org.eclipse.graphiti.features.context.ICreateContext) c);
						if (result.length == 2) {
							created[0] = result[0];
							created[1] = result[1];
						}
					} else cf.throwException((ICreateContext) c);
					
					
				} else if (f instanceof de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateEdgeFeature) {
					de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateEdgeFeature cf = (de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateEdgeFeature) f;
					if (cf.canCreate((org.eclipse.graphiti.features.context.ICreateConnectionContext) c, true)) {
						org.eclipse.graphiti.mm.pictograms.Connection conn = cf.create((org.eclipse.graphiti.features.context.ICreateConnectionContext) c);
						if (conn != null) {
							org.eclipse.emf.ecore.EObject bo = conn.getLink().getBusinessObjects().get(0);
							if (bo instanceof graphmodel.IdentifiableElement) {
								bo = ((graphmodel.IdentifiableElement)bo).getInternalElement();
							}
							created[0] = ((graphmodel.internal.InternalModelElement) bo).getElement();
							created[1] = conn;
						}
					} else cf.throwException((ICreateConnectionContext) c);
				} else if (f instanceof org.eclipse.graphiti.features.IAddFeature) {
					org.eclipse.graphiti.features.IAddFeature af = (org.eclipse.graphiti.features.IAddFeature) f;
					if (af.canAdd((org.eclipse.graphiti.features.context.IAddContext) c)) {
						org.eclipse.graphiti.mm.pictograms.PictogramElement pe = af.add((org.eclipse.graphiti.features.context.IAddContext) c);
						if (pe != null) {
							org.eclipse.emf.ecore.EObject bo = pe.getLink().getBusinessObjects().get(0);
							if (bo instanceof graphmodel.IdentifiableElement) {
								bo = ((graphmodel.IdentifiableElement)bo).getInternalElement();
							}
							created[0] = ((graphmodel.internal.InternalModelElement) bo).getElement();
							created[1] = pe;
						}
					} else {
						if (f instanceof CincoAddFeaturePrime)
							((CincoAddFeaturePrime) f).throwException((IAddContext) c);
					}
				} else {
					f.execute(c);
				}
			}
		});
		return created;
	}
	
}
