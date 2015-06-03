package de.jabc.cinco.meta.plugin.ocl.service;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.PlatformUI;

public class ServiceLoader {
	public static boolean oclValidation(IStructuredSelection isl) {
		
		OCLValidateAction va = new OCLValidateAction();
		va.setActiveWorkbenchPart(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActivePart());
		va.setDescription("OCL Validation");
		boolean trigger = va.updateSelection(isl);
		if(trigger) {
			va.setChecked(true);
			va.run();
			return true;
		}
		return false;	
	}
}
