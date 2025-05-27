
import '../models/user_registration_data.dart';

class UserRegistrationMemento {
  final UserRegistrationData _state;

  UserRegistrationMemento(this._state);

  UserRegistrationData get state => _state;
}

class UserRegistrationOriginator {
  late UserRegistrationData _currentState;

  void setState(UserRegistrationData state) {
    _currentState = state;
  }

  UserRegistrationData getState() => _currentState;

  UserRegistrationMemento saveToMemento() {
    return UserRegistrationMemento(UserRegistrationData.clone(_currentState));
  }

  void restoreFromMemento(UserRegistrationMemento memento) {
    _currentState = memento.state;
  }
}

class UserRegistrationCaretaker {
  final List<UserRegistrationMemento> _history = [];

  void save(UserRegistrationMemento memento) {
    _history.add(memento);
  }

  UserRegistrationMemento? undo() {
    if (_history.isNotEmpty) {
      return _history.removeLast();
    }
    return null;
  }
}

class RegisterFlowManager {
  final UserRegistrationData userData = UserRegistrationData();
  final UserRegistrationOriginator originator = UserRegistrationOriginator();
  final UserRegistrationCaretaker caretaker = UserRegistrationCaretaker();

  RegisterFlowManager() {
    originator.setState(UserRegistrationData.clone(userData));
    caretaker.save(originator.saveToMemento());
  }

  void saveStep() {
    originator.setState(UserRegistrationData.clone(userData));
    caretaker.save(originator.saveToMemento());
  }

  void restorePreviousStep() {
    final memento = caretaker.undo();
    if (memento != null) {
      originator.restoreFromMemento(memento);
      _applyRestoredData(originator.getState());
    }
  }

  void _applyRestoredData(UserRegistrationData restored) {
    userData.email = restored.email;
    userData.password = restored.password;
    userData.name = restored.name;
    userData.surname = restored.surname;
    userData.birthDate = restored.birthDate;
    userData.phone = restored.phone;
    userData.role = restored.role;
    userData.address = restored.address;
    userData.schedule = restored.schedule;
    userData.preferences = restored.preferences;
    userData.needs = restored.needs;
    userData.prefix = restored.prefix;
    userData.identification = restored.identification;
  }
}
