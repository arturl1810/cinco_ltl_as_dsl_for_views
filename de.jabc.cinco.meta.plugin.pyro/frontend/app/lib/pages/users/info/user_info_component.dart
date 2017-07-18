import 'package:angular2/core.dart';

import '../../../model/core.dart';


@Component(
    selector: 'user-info',
    templateUrl: 'user_info_component.html'
)
class UserInfoComponent implements OnInit {

  @Output()
  EventEmitter close;

  @Input()
  PyroUser user;

  UserInfoComponent()
  {
    close = new EventEmitter();
  }

  @override
  void ngOnInit()
  {

  }

}

