import 'package:angular2/core.dart';
import 'dart:async';

@Component(
    selector: 'notification',
    templateUrl: 'notification_component.html',
    styleUrls: const ['notification_component.css'],
    directives: const []
)
class NotificationComponent implements OnInit {

  String message;

  String type = "";

  String animation = "pyro-alter-show";

  Timer timer;

  bool visible = false;

  NotificationComponent()
  {
    message = "";
  }

  @override
  void ngOnInit()
  {

  }

  void displayMessage(String m,AlertType type)
  {
    message = m;
    animation = "pyro-alter-show";
    this.type = type.toString().toLowerCase().substring(10);
    visible = true;
    timer = new Timer(new Duration(seconds: 4), close);
  }

  String getClass()
  {
    return "alert alert-${type} ${animation}";
  }

  void close()
  {
    animation = "pyro-alter-hidden";
    new Timer(new Duration(seconds: 1),hide);
  }

  void hide()
  {
    visible = false;
  }

}

enum AlertType {
  SUCCESS, WARNING, INFO, DANGER
}
