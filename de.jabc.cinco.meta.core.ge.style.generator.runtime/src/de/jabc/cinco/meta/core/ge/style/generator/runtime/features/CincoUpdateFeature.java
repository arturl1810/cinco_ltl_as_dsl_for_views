package de.jabc.cinco.meta.core.ge.style.generator.runtime.features;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.ILayoutFeature;
import org.eclipse.graphiti.features.IReason;
import org.eclipse.graphiti.features.context.IUpdateContext;
import org.eclipse.graphiti.features.context.impl.LayoutContext;
import org.eclipse.graphiti.features.impl.AbstractUpdateFeature;
import org.eclipse.graphiti.features.impl.Reason;
import org.eclipse.graphiti.mm.algorithms.AbstractText;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.services.Graphiti;

import com.sun.el.ExpressionFactoryImpl;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.expressionlanguage.ExpressionLanguageContext;
import graphmodel.ModelElement;
import graphmodel.internal.InternalModelElement;

public class CincoUpdateFeature extends AbstractUpdateFeature {

	private static ExpressionFactoryImpl factory = new ExpressionFactoryImpl();
	private static ExpressionLanguageContext elContext;
		
	
	public CincoUpdateFeature(IFeatureProvider fp) {
		super(fp);
	}

	@Override
	public boolean canUpdate(IUpdateContext context) {
		PictogramElement pe = context.getPictogramElement();
		EObject bo = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
		return (bo instanceof InternalModelElement);
	}

	@Override
	public IReason updateNeeded(IUpdateContext context) {
		PictogramElement pe = context.getPictogramElement();
		EObject bo = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
		if (checkUpdateNeeded(bo, pe))
			return Reason.createTrueReason();
		return Reason.createFalseReason();
	}

	@Override
	public boolean update(IUpdateContext context) {
		PictogramElement pe = context.getPictogramElement();
		EObject bo = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
		updateText(bo, pe);
		LayoutContext lContext = new LayoutContext(context.getPictogramElement());
		ILayoutFeature lf = getFeatureProvider().getLayoutFeature(lContext);
		if (lf.canLayout(lContext))
			return lf.layout(lContext);	
		return false;
	}
	
	/**
	 * Updates the text of the object
	 * @param bo : Current object
	 * @param pe : PictroGramElement
	 */
	private void updateText(EObject bo, PictogramElement pe) {
		if (pe instanceof ContainerShape) {
			PictogramElement tmp = pe;
			Object o = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(tmp);
			if (bo.equals(o) || o == null)
			for (Shape _s : ((ContainerShape) pe).getChildren()) {
				updateText(bo, _s);
			}
		} 
		if (pe instanceof Connection) {
			Connection connection = (Connection) pe;
			for (ConnectionDecorator cd : connection.getConnectionDecorators()) {
				updateText(bo, cd); 
			} 
		} else {
			if (pe.getGraphicsAlgorithm() instanceof AbstractText) {
				ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
				AbstractText t = (AbstractText) pe.getGraphicsAlgorithm();
				try {
					Thread.currentThread().setContextClassLoader(CincoUpdateFeature.class.getClassLoader());
					
					String value = Graphiti.getPeService().getPropertyValue(t, "Params");
					String formatString = Graphiti.getPeService().getPropertyValue(t, "formatString");
					
					elContext = new ExpressionLanguageContext(bo);
					Object tmp2Value = factory.createValueExpression(elContext, value, Object.class).getValue(elContext); 
					
					t.setValue(String.format(formatString , tmp2Value));
				} 
				catch (java.util.IllegalFormatException ife) {
					t.setValue("STRING FORMAT ERROR");
				} 
				finally {
					Thread.currentThread().setContextClassLoader(contextClassLoader);
				}
			}
		}
	}

	/**
	 * Checks if the text needs to be updated
	 * @param bo : Current object
	 * @param pe : PictogramElement
	 * @return Returns true if an update is needed
	 */
	public static <EObject> boolean checkUpdateNeeded(EObject bo, PictogramElement pe) {
		boolean updateNeeded;
		if (pe instanceof ContainerShape) {
			for (Shape _s : ((ContainerShape) pe).getChildren()) {
				return checkUpdateNeeded(bo, _s);
			}
		} 
		if (pe instanceof Connection) {
			Connection connection = (Connection) pe;
			for (ConnectionDecorator cd : connection.getConnectionDecorators()) {
				updateNeeded = checkUpdateNeeded(bo, cd);
				if (updateNeeded)
					return true;
			}
		} else {
			java.lang.Object o = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
			if (pe.getGraphicsAlgorithm() instanceof AbstractText && bo.equals(o)) {
				ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
				try {
					Thread.currentThread().setContextClassLoader(o.getClass().getClassLoader());
					AbstractText t = (AbstractText) pe.getGraphicsAlgorithm();
					
					String value = Graphiti.getPeService().getPropertyValue(t, "Params");  //zb. ${name}
					String formatString = Graphiti.getPeService().getPropertyValue(t, "formatString");  //zb. %s
					
					elContext = new ExpressionLanguageContext(bo);
					Object tmp2Value = factory.createValueExpression(elContext, value, Object.class).getValue(elContext); 
					
					
					String oldVal = String.format(formatString, tmp2Value);
					String newVal = t.getValue();
					return (!newVal.equals(oldVal));
				} 
				finally {
					Thread.currentThread().setContextClassLoader(contextClassLoader);
				}
			}
		}
		return false;
	}
}

