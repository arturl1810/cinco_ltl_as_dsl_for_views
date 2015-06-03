package de.jabc.cinco.meta.plugin.ocl.templates

class StartUpActionTemplate {
	def create(String packageName)'''
package «packageName»;

import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IExecutionListener;
import org.eclipse.core.commands.NotHandledException;
import org.eclipse.ui.IStartup;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;


public class StartUpAction implements IStartup {

	@Override
	public void earlyStartup() {
		String commandId = "org.eclipse.ui.file.save";
		ICommandService service = (ICommandService) PlatformUI.getWorkbench().getService(ICommandService.class);
		Command command = service.getCommand(commandId);
		command.addExecutionListener(new IExecutionListener() {

			@Override
			public void notHandled(String commandId,
					NotHandledException exception) {
				
			}

			@Override
			public void postExecuteFailure(String commandId,
					ExecutionException exception) {
				
			}

			@Override
			public void postExecuteSuccess(String commandId, Object returnValue) {
				ValidateAction va = new ValidateAction();
				va.setActivePart(null, PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActivePart());
				va.run(null,true);
				
			}

			@Override
			public void preExecute(String commandId, ExecutionEvent event) {
				
			}
		});
	}

}
	'''
}