package de.jabc.cinco.meta.plugin.pyro.frontend.pages.projects.deleteproject

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class DeleteProjectComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameDeleteProjectComponent()'''delete_project_component.dart'''
	
	def contentDeleteProjectComponent()'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	
	@Component(
	    selector: 'delete-project',
	    templateUrl: 'delete_project_component.html'
	)
	class DeleteProjectComponent implements OnInit {
	
	
	
	  @Output()
	  EventEmitter close;
	
	  @Output()
	  EventEmitter delete;
	
	  @Input()
	  PyroUser user;
	
	  @Input()
	  PyroProject project;
	
	  DeleteProjectComponent()
	  {
	    close = new EventEmitter();
	    delete = new EventEmitter();
	    print("delete project");
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void closeModal(dynamic e)
	  {
	    e.preventDefault();
	    close.emit(e);
	  }
	
	  void deleteProject(dynamic e)
	  {
	    e.preventDefault();
	    delete.emit(e);
	  }
	
	}
	
	'''
	
}