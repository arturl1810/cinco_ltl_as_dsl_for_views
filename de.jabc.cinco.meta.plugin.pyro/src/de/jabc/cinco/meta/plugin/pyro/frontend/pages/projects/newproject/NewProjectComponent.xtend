package de.jabc.cinco.meta.plugin.pyro.frontend.pages.projects.newproject

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class NewProjectComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameNewProjectComponent()'''new_project_component.dart'''
	
	def contentNewProjectComponent()'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	
	@Component(
	    selector: 'new-project',
	    templateUrl: 'new_project_component.html'
	)
	class NewProjectComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter newProject;
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroUser user;
	
	  NewProjectComponent()
	  {
	    newProject = new EventEmitter();
	    close = new EventEmitter();
	    print("new project");
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void createNewProject(String name,String description,List<PyroUser> users)
	  {
	    PyroProject project = new PyroProject();
	    project.name = name;
	    project.description = description;
	    project.owner = user;
	    project.shared = users;
	    this.newProject.emit(project);
	  }
	
	}
	
	'''
	
}