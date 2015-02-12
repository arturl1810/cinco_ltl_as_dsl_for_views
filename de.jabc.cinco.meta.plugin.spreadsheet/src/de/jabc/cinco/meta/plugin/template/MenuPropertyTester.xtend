package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode

class MenuPropertyTester {
	def  create(String projectPath,String packageName,ArrayList<ResultNode> nodes)'''
package «packageName»;

import java.io.IOException;
import java.util.HashMap;

import graphmodel.Node;
«FOR n :nodes»
import «projectPath».«n.nodeName.toFirstUpper»;
«ENDFOR»

import org.eclipse.core.expressions.PropertyTester;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart;

@SuppressWarnings("restriction")
public class MenuPropertyTester extends PropertyTester {

	public static final String PROPERTY_GENERATE= "canGenerate";
	public static final String PROPERTY_EDIT= "canEdit";
	public static final String PROPERTY_CALCULATE= "canCalculate";

	@Override
	public boolean test(Object receiver, String property, Object[] args,
			Object expectedValue) {
		//Check matching resulting class
		ContainerShapeEditPart csep = (ContainerShapeEditPart) receiver;
		EObject eobject=Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(csep.getPictogramElement());
		if(«FOR n : nodes»eobject instanceof «n.nodeName.toFirstUpper»  || «ENDFOR»false)
		{
			Node node = (Node) eobject;
			//Check whether a sheet has been generated before
			if(property.equals(PROPERTY_EDIT) || property.equals(PROPERTY_CALCULATE)) {
				try {
					HashMap<String,String> sheets = SheetHandler.loadSheetMap(NodeUtil.getId(node));
					if(!sheets.isEmpty()){
						return true;
					}
				} catch (ClassNotFoundException | ClassCastException
						| IOException e) {
				}
			}
			else {
				return true;
			}
		}
		return false;
	}

}
	'''
}