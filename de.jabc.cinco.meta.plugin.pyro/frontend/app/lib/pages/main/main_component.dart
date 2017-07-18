import 'package:angular2/core.dart';


@Component(
  selector: 'main-component',
  styleUrls: const ['main_component.css'],
  templateUrl: 'main_component.html',
)
class MainComponent implements OnInit{

  @Output()
  EventEmitter changeMinorState;

  @Input()
  String minorState;

  MainComponent()
  {
    changeMinorState = new EventEmitter();
    print("main");
  }

  void ngOnInit()
  {
    print("mainOnInit");
    print(minorState);
  }

  void changeState(String s,dynamic e)
  {
    e.preventDefault();
    changeMinorState.emit(s);
  }

  bool minorStateClass(String state)
  {
    if(state!=null&&minorState!=null){
      if(minorState == state){
        return true;
      }
    }

    return false;
  }
}
