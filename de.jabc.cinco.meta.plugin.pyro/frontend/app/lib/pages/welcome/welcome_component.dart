import 'package:angular2/core.dart';

@Component(
  selector: 'welcome',
  styleUrls: const ['welcome_component.css'],
  templateUrl: 'welcome_component.html',
)
class WelcomeComponent {
  @Output()
  EventEmitter signin;

  WelcomeComponent()
  {
    signin = new EventEmitter();
    print("welcome");
  }

  void login(dynamic e)
  {
    e.preventDefault();
    signin.emit(new Map());
  }
}
