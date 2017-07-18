import 'package:angular2/core.dart';
	
	import '../../../model/core.dart';
	
	
	@Component(
	    selector: 'settings',
	    templateUrl: 'settings_component.html'
	)
	class SettingsComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroUser user;
	
	  @Input()
	  PyroProject project;
	
	  @Input()
	  GraphModel graphModel;
	
	  SettingsComponent()
	  {
	    close = new EventEmitter();
	    print("settings component");
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void saveSettings(dynamic e)
	  {
	
	    e.preventDefault();
	  }
	
	}