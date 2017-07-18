package de.jabc.cinco.meta.plugin.pyro.frontend.pages.users.shared

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class SharedComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameSharedComponent()'''shared_component.dart'''
	
	def contentSharedComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/pages/users/find_user/find_user_component.dart';
	
	@Component(
	    selector: 'shared',
	    templateUrl: 'shared_component.html',
	    directives: const [FindUserComponent]
	)
	class SharedComponent implements OnInit {
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroUser user;
	
	
	  @Input()
	  PyroProject project;
	
	  bool showFindUserModal = false;
	  bool isOwner = false;
	
	  SharedComponent()
	  {
	    close = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	    isOwner= project.owner.dywaId==user.dywaId;
	  }
	
	  void findUser(Map map)
	  {
	
	  }
	
	  void removeUserFromProject(PyroUser user)
	  {
	    project.shared.remove(user);
	  }
	
	  void addUserToProject(PyroUser user)
	  {
	    project.shared.add(user);
	  }
	
	  List<PyroUser> notIncludedUsers()
	  {
	    return user.knownUsers.where((n) => !project.shared.contains(n)).toList();
	  }
	
	}
	
	'''
	
}