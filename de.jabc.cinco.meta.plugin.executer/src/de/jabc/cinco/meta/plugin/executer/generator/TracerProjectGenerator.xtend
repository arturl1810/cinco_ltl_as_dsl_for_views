package de.jabc.cinco.meta.plugin.executer.generator

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import de.jabc.cinco.meta.plugin.executer.generator.tracer.AbstractContextTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.AbstractRunnerTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.AbstractSemanticTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ActivatorTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.BorderMatchTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.BuildTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.CardinalityCheckerTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ContainerSimulationTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ContentViewTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ContextsTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.EdgeSimulatorTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.EvaluationContributionsHandlerTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ExceptionRunLogTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ExecutionTupelTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.GraphSimulatorTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.HighlighterTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.JointTracerExceptionTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.LTSMatchTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.LevelTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ManifestTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.MatchTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.MessageRunLogTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.NextTransitionTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.NodeSimulatorTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.PluginTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.RunCallbackTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.RunLogTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.RunResultTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.RunStepperTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.RunTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.RunnerSchemaTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.SamplePropertyPageTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.StateMatchTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.StepResultTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.StepTypeTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.StepperTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ThreadStepResultTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ThreadTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ThreadViewTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.TracerExceptionTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.TracerSchemaTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.TransitionMatchTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.TypeCheckerTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.UnexpectedTerminationException
import de.jabc.cinco.meta.plugin.executer.generator.tracer.ViewTemplate
import de.jabc.cinco.meta.plugin.executer.generator.tracer.WaitingExceptionTemplate
import java.util.Collections
import java.util.HashSet
import java.util.LinkedList
import org.eclipse.core.runtime.NullProgressMonitor

class TracerProjectGenerator {
	
	
	def create(ExecutableGraphmodel graphmodel)
	{
		var projectFQN = MainTemplate.getTracerPackage(graphmodel)
		var projectName = projectFQN;
		
		var srcPath ="src/"
		var tracerFQN  = (srcPath+projectFQN)
		var extensionFQN = srcPath+projectFQN+".extension";
		var handlerFQN = srcPath+projectFQN+".handler"
		var matchModelFQN = srcPath+projectFQN+".match.model"
		var matchSimulationFQN = srcPath+projectFQN+".match.simulation"
		var propertiesFQN = srcPath+projectFQN+".properties"
		var runnerModelFQN = srcPath+projectFQN+".runner.model"
		var stepperModelFQN = srcPath+projectFQN+".stepper.model"
		var stepperUtilsFQN = srcPath+projectFQN+".stepper.utils"
		var viewsFQN = srcPath+projectFQN+".views"
		
		var srcForlders = new LinkedList<String>();
		srcForlders.add("src")
		

		var requiredBundles	= new HashSet<String>();
		
		var exportetPackages = new LinkedList<String>();
		
		var additionalNatures = new LinkedList<String>();
		
		var tracerProject = ProjectCreator.createProject(
			projectName,
			srcForlders,
			Collections.emptyList,
			requiredBundles,
			exportetPackages,
			additionalNatures,
			new NullProgressMonitor(),
			srcForlders,
			false
		)
		
		
		
		var schemaFQN = "schema";
		var metaInfFQN = "META-INF/"
		
		/**
		 * Generate Files for src folders
		 */
		 //tracer
		MainTemplate.generateFile(new ActivatorTemplate(graphmodel),tracerFQN,tracerProject)
		//extension
		MainTemplate.generateFile(new AbstractContextTemplate(graphmodel),extensionFQN,tracerProject)
		MainTemplate.generateFile(new AbstractRunnerTemplate(graphmodel),extensionFQN,tracerProject)
		MainTemplate.generateFile(new AbstractSemanticTemplate(graphmodel),extensionFQN,tracerProject)
		//tracer handler
		MainTemplate.generateFile(new EvaluationContributionsHandlerTemplate(graphmodel),handlerFQN,tracerProject)
		MainTemplate.generateFile(new ExecutionTupelTemplate(graphmodel),handlerFQN,tracerProject)
		//match model
		MainTemplate.generateFile(new LTSMatchTemplate(graphmodel),matchModelFQN,tracerProject)
		MainTemplate.generateFile(new MatchTemplate(graphmodel),matchModelFQN,tracerProject)
		MainTemplate.generateFile(new StateMatchTemplate(graphmodel),matchModelFQN,tracerProject)
		MainTemplate.generateFile(new TransitionMatchTemplate(graphmodel),matchModelFQN,tracerProject)
		//match simulation
		MainTemplate.generateFile(new BorderMatchTemplate(graphmodel),matchSimulationFQN,tracerProject)
		MainTemplate.generateFile(new CardinalityCheckerTemplate(graphmodel),matchSimulationFQN,tracerProject)
		MainTemplate.generateFile(new ContainerSimulationTemplate(graphmodel),matchSimulationFQN,tracerProject)
		MainTemplate.generateFile(new EdgeSimulatorTemplate(graphmodel),matchSimulationFQN,tracerProject)
		MainTemplate.generateFile(new GraphSimulatorTemplate(graphmodel),matchSimulationFQN,tracerProject)
		MainTemplate.generateFile(new NodeSimulatorTemplate(graphmodel),matchSimulationFQN,tracerProject)
		MainTemplate.generateFile(new TypeCheckerTemplate(graphmodel),matchSimulationFQN,tracerProject)
		//properties
		MainTemplate.generateFile(new SamplePropertyPageTemplate(graphmodel),propertiesFQN,tracerProject)
		//runner model
		MainTemplate.generateFile(new ExceptionRunLogTemplate(graphmodel),runnerModelFQN,tracerProject)
		MainTemplate.generateFile(new MessageRunLogTemplate(graphmodel),runnerModelFQN,tracerProject)
		MainTemplate.generateFile(new RunTemplate(graphmodel),runnerModelFQN,tracerProject)
		MainTemplate.generateFile(new RunCallbackTemplate(graphmodel),runnerModelFQN,tracerProject)
		MainTemplate.generateFile(new RunLogTemplate(graphmodel),runnerModelFQN,tracerProject)
		MainTemplate.generateFile(new RunResultTemplate(graphmodel),runnerModelFQN,tracerProject)
		MainTemplate.generateFile(new RunStepperTemplate(graphmodel),runnerModelFQN,tracerProject)
		//stepper model
		MainTemplate.generateFile(new LevelTemplate(graphmodel),stepperModelFQN,tracerProject)
		MainTemplate.generateFile(new NextTransitionTemplate(graphmodel),stepperModelFQN,tracerProject)
		MainTemplate.generateFile(new StepperTemplate(graphmodel),stepperModelFQN,tracerProject)
		MainTemplate.generateFile(new StepTypeTemplate(graphmodel),stepperModelFQN,tracerProject)
		MainTemplate.generateFile(new StepResultTemplate(graphmodel),stepperModelFQN,tracerProject)
		MainTemplate.generateFile(new ThreadTemplate(graphmodel),stepperModelFQN,tracerProject)
		MainTemplate.generateFile(new ThreadStepResultTemplate(graphmodel),stepperModelFQN,tracerProject)
		//stepper utils
		MainTemplate.generateFile(new ContentViewTemplate(graphmodel),stepperUtilsFQN,tracerProject)
		MainTemplate.generateFile(new HighlighterTemplate(graphmodel),stepperUtilsFQN,tracerProject)
		MainTemplate.generateFile(new JointTracerExceptionTemplate(graphmodel),stepperUtilsFQN,tracerProject)
		MainTemplate.generateFile(new TracerExceptionTemplate(graphmodel),stepperUtilsFQN,tracerProject)
		MainTemplate.generateFile(new UnexpectedTerminationException(graphmodel),stepperUtilsFQN,tracerProject)
		MainTemplate.generateFile(new WaitingExceptionTemplate(graphmodel),stepperUtilsFQN,tracerProject)
		//views
		MainTemplate.generateFile(new ThreadViewTemplate(graphmodel),viewsFQN,tracerProject)
		MainTemplate.generateFile(new ViewTemplate(graphmodel),viewsFQN,tracerProject)
		//META-INF
		MainTemplate.generateFile(new ManifestTemplate(graphmodel),metaInfFQN,tracerProject)
		//schema
		MainTemplate.generateFile(new RunnerSchemaTemplate(graphmodel),schemaFQN,tracerProject)
		MainTemplate.generateFile(new TracerSchemaTemplate(graphmodel),schemaFQN,tracerProject)
		//.
		MainTemplate.generateFile(new BuildTemplate(graphmodel),"",tracerProject)
		MainTemplate.generateFile(new ContextsTemplate(graphmodel),"",tracerProject)
		MainTemplate.generateFile(new PluginTemplate(graphmodel),"",tracerProject)
	}
	
	
}