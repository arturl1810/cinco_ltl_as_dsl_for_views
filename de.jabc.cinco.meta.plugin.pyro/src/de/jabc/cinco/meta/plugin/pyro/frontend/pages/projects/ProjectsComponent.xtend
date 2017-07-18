package de.jabc.cinco.meta.plugin.pyro.frontend.pages.projects

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class ProjectsComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameProjectsComponent()'''projects_component.dart'''
	
	def contentProjectsComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/pages/projects/new_project/new_project_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/users/find_user/find_user_component.dart';
	
	@Component(
	  selector: 'projects',
	  templateUrl: 'projects_component.html',
	  directives: const [NewProjectComponent, FindUserComponent],
	  styleUrls: const ['projects_component.css']
	)
	class ProjectsComponent implements OnInit {
	
	  String tabState;
	
	  String editProjectHeader;
	
	  bool showNewProjectModal = false;
	  bool showFindUserModal = false;
	
	  @Output()
	  EventEmitter openProject;
	
	  @Output()
	  EventEmitter logout;
	
	  @Input()
	  PyroUser user;
	  List<PyroProject> currentProjects;
	
	  ProjectsComponent()
	  {
	    editProjectHeader = '';
	    currentProjects = new List<PyroProject>();
	    openProject = new EventEmitter();
	    logout = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	    tabState = 'owned';
	    showProjects(user.ownedProjects,'owned',null);
	  }
	
	  bool isActive(String s)
	  {
	    if(s==tabState) {
	      return true;
	    }
	    return false;
	  }
	
	  void showProjects(List<PyroProject> projects,String s,dynamic e)
	  {
	    currentProjects = projects;
	    tabState = s;
	    if(e!=null) {
	      e.preventDefault();
	    }
	
	  }
	
	  void openCurrentProject(PyroProject project)
	  {
	    openProject.emit(project);
	  }
	
	  void findUser(Map map)
	  {
	    //todo send request
	    if(map.containsKey("username")&&map.containsKey("email")) {
	      PyroUser newUser = new PyroUser();
	      newUser.username = map["username"];
	      newUser.email = map["email"];
	      //todo add to list and persist
	      user.knownUsers.add(newUser);
	    }
	
	  }
	
	}
	
	'''
	
}