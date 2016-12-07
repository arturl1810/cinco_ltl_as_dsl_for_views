package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class RunStepperTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "RunStepper.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	import java.util.LinkedList;
	import java.util.List;
	
	import «graphmodel.tracerPackage».stepper.model.Stepper;
	
	/**
	 * The run stepper combines the information
	 * for one run of the current runner.
	 * 
	 * The run stepper contains information of the
	 * run status, all log entries, the run itself with their
	 * context and semantics and the stepper, which executes
	 * the run.
	 * @author zweihoff
	 *
	 */
	public final class RunStepper {
		
		public static final int STATUS_ACTIVE = 1;
		public static final int STATUS_INACTIVE = 2;
		
		private Run run;
		private Stepper stepper;
		private List<RunLog> logging;
		private int status;
		
		public RunStepper(Run run,Stepper stepper)
		{
			this.status = STATUS_ACTIVE;
			this.run = run;
			this.stepper = stepper;
			this.logging = new LinkedList<RunLog>();
		}
		
		public final Run getRun() {
			return run;
		}
		public final void setRun(Run run) {
			this.run = run;
		}
		public final Stepper getStepper() {
			return stepper;
		}
		public final void setStepper(Stepper stepper) {
			this.stepper = stepper;
		}
	
		public final List<RunLog> getLogging() {
			return logging;
		}
	
		public final void setLogging(List<RunLog> logging) {
			this.logging = logging;
		}
	
		public final int getStatus() {
			return status;
		}
	
		public final void setStatus(int status) {
			this.status = status;
		}
		
		public final boolean isActive()
		{
			return this.status == STATUS_ACTIVE;
		}
		
		
	}
	
	'''
	
}