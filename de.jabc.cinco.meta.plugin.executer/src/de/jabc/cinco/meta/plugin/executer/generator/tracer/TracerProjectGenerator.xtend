package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
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