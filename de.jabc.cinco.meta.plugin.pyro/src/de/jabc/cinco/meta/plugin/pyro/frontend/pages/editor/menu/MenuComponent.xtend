package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.menu

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class MenuComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameMenuComponent()
	'''menu_component.dart'''
	
	def contentMenuComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/pages/projects/new_project/new_project_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/users/info/user_info_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/users/shared/shared_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/projects/delete_project/delete_project_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/projects/settings/settings_component.dart';
	
	@Component(
	    selector: 'menu',
	    templateUrl: 'menu_component.html',
	    directives: const [NewProjectComponent,UserInfoComponent,SharedComponent,DeleteProjectComponent,SettingsComponent],
	    styleUrls: const ['menu_component.css']
	)
	class MenuComponent implements OnInit {
	
	  @Output()
	  EventEmitter back;
	  @Output()
	  EventEmitter logout;
	  @Output()
	  EventEmitter changeLayout;
	  @Output()
	  EventEmitter changeScale;
	  @Output()
	  EventEmitter openProject;
	
	  @Input()
	  PyroUser user;
	  @Input()
	  PyroProject project;
	  @Input()
	  GraphModel currentGraphModel;
	
	  bool showNewProjectModal = false;
	  bool showUserInfoModal = false;
	  bool showDeleteProjectModal = false;
	  bool showSettingsModal = false;
	  bool showSharedModal = false;
	
	  MenuComponent()
	  {
	    print("menu");
	    back = new EventEmitter();
	    logout = new EventEmitter();
	    changeLayout = new EventEmitter();
	    openProject = new EventEmitter();
	    changeScale = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	    print("menuoninit");
	    print(project);
	  }
	
	  void saveProject(dynamic e)
	  {
	    //todo save project
	    e.preventDefault();
	  }
	
	  void openModalShowNewProjectModal(dynamic e)
	  {
	    e.preventDefault();
	    showNewProjectModal=true;
	  }
	
	  void openModalShowUserInfoModal(dynamic e)
	  {
	    e.preventDefault();
	    showUserInfoModal=true;
	  }
	
	  void openModalShowDeleteProjectModal(dynamic e)
	  {
	    e.preventDefault();
	    showDeleteProjectModal=true;
	  }
	
	  void openModalShowSettingsModal(dynamic e)
	  {
	    e.preventDefault();
	    showSettingsModal=true;
	  }
	
	  void openModalShowSharedModal(dynamic e)
	  {
	    e.preventDefault();
	    showSharedModal=true;
	  }
	
	
	  void deleteProject(dynamic e)
	  {
	    e.preventDefault();
	    showDeleteProjectModal=false;
	    back.emit(e);
	  }
	
	  void scaleGraph(bool direction,dynamic e)
	  {
	    e.preventDefault();
	    changeScale.emit(direction);
	  }
	
	  void showView(dynamic e)
	  {
	    e.preventDefault();
	  }
	
	  void showInfo(dynamic e)
	  {
	    e.preventDefault();
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
	  void changeRouteLayout(String type,dynamic e)
	  {
	    e.preventDefault();
	    changeLayout.emit(type);
	  }
	
	}
	
	'''
	
	def fileNameMenuComponentTemplate()
	'''menu_component.html'''
	
	def contentMenuComponentTemplate()
	'''
	<header class="navbar navbar-static-top" style="border-radius: 5px;margin-left: 5px;margin-right: 5px;padding-right: 5px;background-color: rgb(82, 82, 82);color: #cacaca;">
	        <div class="navbar-header">
	            <a class="navbar-brand" href (click)="back.emit($event)">
	                <img alt="Brand" src="assets/img/pyro_flame_white.svg" style="height: 40px;margin-top: -10px;">
	            </a>
	            <button aria-expanded="false" class="collapsed navbar-toggle" data-target="#bs-navbar" data-toggle="collapse" type="button">
	                <span class="sr-only">Toggle navigation</span>
	                <span class="icon-bar"></span>
	                <span class="icon-bar"></span>
	                <span class="icon-bar"></span>
	            </button> <a href (click)="back.emit($event)" style="color: white;" class="navbar-brand">Pyro</a>
	        </div>
	        <nav class="collapse navbar-collapse" id="bs-navbar">
	            <ul class="nav navbar-nav">
	                <li class="dropdown">
	                    <a href="#" class="dropdown-toggle" style="color: white;" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Project <span class="caret"></span></a>
	                    <ul class="dropdown-menu">
	                        <li><a href (click)="openModalShowNewProjectModal($event)">New...</a></li>
	                        <li><a href (click)="saveProject($event)">Save</a></li>
	                        <li><a href (click)="openModalShowUserInfoModal($event)">User Info...</a></li>
	                        <li><a href (click)="openModalShowSharedModal($event)">Sharing...</a></li>
	                        <li><a href (click)="openModalShowDeleteProjectModal($event)">Delete</a></li>
	                        <li role="separator" class="divider"></li>
	                        <li><a href (click)="back.emit($event)">Projects</a></li>
	                        <li><a href (click)="logout.emit($event)">Quit</a></li>
	                    </ul>
	                </li>
	                <li class="dropdown">
	                    <a href="#" class="dropdown-toggle" style="color: white;" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">View <span class="caret"></span></a>
	                    <ul class="dropdown-menu">
	                        <li><a href (click)="scaleGraph(true,$event)">+ Scale</a></li>
	                        <li><a href (click)="scaleGraph(false,$event)">- Scale</a></li>
	                        <li><a href (click)="showView($event)">Show View...</a></li>
	                    </ul>
	                </li>
	                <li class="dropdown">
	                    <a href="#" class="dropdown-toggle" style="color: white;" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Routing <span class="caret"></span></a>
	                    <ul class="dropdown-menu">
	                        <li><a href (click)="changeRouteLayout('Default',$event)">Default</a></li>
	                        <li><a href (click)="changeRouteLayout('Rounded',$event)">Rounded</a></li>
	                        <li><a href (click)="changeRouteLayout('Manhatten',$event)">Manhatten</a></li>
	                    </ul>
	                </li>
	                <li><p class="navbar-text">{{project.name}}</p></li>
	            </ul>
	            <ul class="nav navbar-nav navbar-right" style="padding-right: 10px;">
	                <li><a href (click)="openModalShowSettingsModal($event)" style="color: white;">Settings</a></li>
	                <li><a href (click)="showInfo($event)" style="color: white;">Info</a></li>
	                <li><p class="navbar-text">Signed in as {{user.username}}</p></li>
	                <li><a href (click)="logout.emit($event)" style="color: white;" >Logout</a></li>
	            </ul>
	        </nav>
	</header>
	<user-info
	        *ngIf="showUserInfoModal"
	        [user]="user"
	        (close)="showUserInfoModal=false"
	>
	</user-info>
	<new-project
	        *ngIf="showNewProjectModal"
	        [user]="user"
	        (newProject)="openCurrentProject($event)"
	        (close)="showNewProjectModal=false"
	>
	</new-project>
	<shared
	        *ngIf="showSharedModal"
	        [user]="user"
	        [project]="project"
	        (close)="showSharedModal=false"
	>
	</shared>
	<delete-project
	        *ngIf="showDeleteProjectModal"
	        [user]="user"
	        [project]="project"
	        (close)="showDeleteProjectModal=false"
	        (delete)="deleteProject($event)"
	>
	</delete-project>
	<settings
	        *ngIf="showSettingsModal"
	        [user]="user"
	        [project]="project"
	        [graphModel]="currentGraphModel"
	        (close)="showSettingsModal=false"
	>
	</settings>
	'''
}