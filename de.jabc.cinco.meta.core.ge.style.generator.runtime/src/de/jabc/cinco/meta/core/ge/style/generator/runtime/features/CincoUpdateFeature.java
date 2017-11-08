package de.jabc.cinco.meta.core.ge.style.generator.runtime.features;

import javax.el.ELException;
import javax.el.PropertyNotFoundException;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.edit.command.SetCommand;
import org.eclipse.emf.transaction.Transaction;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
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
import graphmodel.IdentifiableElement;
import graphmodel.internal.InternalModelElement;

abstract public class CincoUpdateFeature extends AbstractUpdateFeature {

	private static ExpressionFactoryImpl factory = new ExpressionFactoryImpl();
	private static ExpressionLanguageContext elContext;

	public CincoUpdateFeature(IFeatureProvider fp) {
		super(fp);
	}

	@Override
	public boolean canUpdate(IUpdateContext context) {
		PictogramElement pe = context.getPictogramElement();
		EObject bo = getBusinessObjectForLinkedPictogramElement(pe);
		return (bo instanceof InternalModelElement);
	}

	@Override
	public IReason updateNeeded(IUpdateContext context) {
		PictogramElement pe = context.getPictogramElement();
		EObject bo = getBusinessObjectForLinkedPictogramElement(pe);

		if (checkUpdateNeeded(bo, pe))
			return Reason.createTrueReason();
		return Reason.createFalseReason();
	}

	@Override
	public boolean update(IUpdateContext context) {
		PictogramElement pe = context.getPictogramElement();
		EObject bo = getBusinessObjectForLinkedPictogramElement(pe);
		updateText(bo, pe);
		if (pe instanceof Connection)
			updateStyle(bo, (Connection) pe);
		if (pe instanceof ConnectionDecorator) {
			updateStyle(bo, ((ConnectionDecorator) pe).getConnection());
		} else if (pe instanceof Shape) {
			updateStyle(bo, (Shape) pe);
		}
		LayoutContext lContext = new LayoutContext(context.getPictogramElement());
		ILayoutFeature lf = getFeatureProvider().getLayoutFeature(lContext);
		if (lf.canLayout(lContext))
			return lf.layout(lContext);
		return false;
	}
	
	public EObject getBusinessObjectForLinkedPictogramElement(PictogramElement pe) {
		EObject bo = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
		if (bo instanceof IdentifiableElement) {
			bo = ((IdentifiableElement)bo).getInternalElement();
		}
		return bo;
	}

	/**
	 * Updates the text of the object
	 * 
	 * @param bo
	 *            : Current object
	 * @param pe
	 *            : PictroGramElement
	 */
	private void updateText(EObject bo, PictogramElement pe) {
		if (pe instanceof ContainerShape) {
			PictogramElement tmp = pe;
			Object o = getBusinessObjectForLinkedPictogramElement(tmp);
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
				String formatString = "";
				try {
					Thread.currentThread().setContextClassLoader(CincoUpdateFeature.class.getClassLoader());

					String value = Graphiti.getPeService().getPropertyValue(t, "Params");
					formatString = Graphiti.getPeService().getPropertyValue(t, "formatString");
					elContext = new ExpressionLanguageContext(bo);
					
					java.lang.Object _values[] = new java.lang.Object[value.split(";").length];
					for (int i=0; i < _values.length; i++)
						_values[i] = "";
						
					for (int i=0; i < value.split(";").length;i++) {
						_values[i] = factory.createValueExpression(elContext, value.split(";")[i], java.lang.Object.class).getValue(elContext);
					}
					
//					TransactionalEditingDomain dom = TransactionUtil.getEditingDomain(t);
//					if (dom == null)
//						TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(this.getFeatureProvider().getDiagramTypeProvider().getDiagram().eResource().getResourceSet());
//					dom.getCommandStack().execute(new SetCommand(dom, t, t.eClass().getEStructuralFeature("value"),String.format(formatString,_values)));
					t.setValue(String.format(formatString,_values));
					
				} catch (java.util.IllegalFormatException ife) {
					t.setValue("STRING FORMAT ERROR");
				} catch (PropertyNotFoundException pne) {
					t.setValue("PROPERTY NOT FOUND: " + formatString);
				} catch (NullPointerException npe) {
					t.setValue("NULL");
				} catch (ELException ele) {
					ele.printStackTrace();
					t.setValue("null");
				} finally {
					Thread.currentThread().setContextClassLoader(contextClassLoader);
				}
			}
		}
	}

	/**
	 * Checks if the text needs to be updated
	 * 
	 * @param bo
	 *            : Current object
	 * @param pe
	 *            : PictogramElement
	 * @return Returns true if an update is needed
	 */
	public <EObject> boolean checkUpdateNeeded(EObject bo, PictogramElement pe) {
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
			java.lang.Object o = getBusinessObjectForLinkedPictogramElement(pe);
//			System.err.println(String.format("Object bo:\n %s \nand linked object o:\n %s", bo, o));
			if (pe.getGraphicsAlgorithm() instanceof AbstractText && bo.equals(o)) {
				ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
				String formatString = "";
				try {
					Thread.currentThread().setContextClassLoader(o.getClass().getClassLoader());
					AbstractText t = (AbstractText) pe.getGraphicsAlgorithm();

					String value = Graphiti.getPeService().getPropertyValue(t, "Params");
					formatString = Graphiti.getPeService().getPropertyValue(t, "formatString");
					elContext = new ExpressionLanguageContext(bo);
					
					java.lang.Object _values[] = new java.lang.Object[value.split(";").length];
					for (int i=0; i < _values.length; i++)
						_values[i] = "";
					String elex = value.split(";")[0];
					factory.createValueExpression(elContext, elex, java.lang.Object.class).getValue(elContext);
					for (int i=0; i < value.split(";").length;i++) {
						_values[i] = factory.createValueExpression(elContext, value.split(";")[i], java.lang.Object.class).getValue(elContext);
					}
					
					String oldVal = "";
					oldVal = String.format(formatString,_values);
					String newVal = t.getValue();
					return (!newVal.equals(oldVal));
				} catch (java.util.IllegalFormatException ife) {
					return true;
				} catch (PropertyNotFoundException pne) {
					return true;
				} catch (NullPointerException npe) {
					return true;
				} catch (ELException ele) {
					ele.printStackTrace();
					return true;
				}

				finally {
					Thread.currentThread().setContextClassLoader(contextClassLoader);
				}
			}
		}
		return false;
	}

	abstract protected void updateStyle(EObject me, Connection s);

	abstract protected void updateStyle(EObject me, Shape s);
}
