//  flutter_bloc для работы с BLoC 
import 'package:flutter_bloc/flutter_bloc.dart';

// файл,  состояний приложения (InitialState, InputState, ResultState)
import 'energy_state.dart';

// Определяем класс EnergyCalculatorCubit, который наследуется от Cubit.
// Cubit — это  версия BLoC, которая работает без Event, только с emit состояниями.
class EnergyCalculatorCubit extends Cubit<EnergyCalculatorState> {
  // Конструктор по умолчанию. При создании кубита изначально выдаётся InitialState.
  EnergyCalculatorCubit() : super(InitialState());

  // отправляет состояние InputState.
  // Используется, чтобы инициализировать форму при запуске.
  void initForm() {
    emit(InputState());
  }

  // обновляет значения полей формы в состоянии InputState.
  // Принимает необязательные параметры: mass, velocity, agreementChecked, unitSystem.
  void updateValues({
    String? mass,
    String? velocity,
    bool? agreementChecked,
    String? unitSystem,
  }) {
    // Получаем текущее состояние, приводя его к типу InputState.
    final currentState = state as InputState;

    // Отправляем новое состояние InputState с обновлёнными значениями.
    emit(InputState(
      mass: mass ?? currentState.mass,
      velocity: velocity ?? currentState.velocity,
      agreementChecked: agreementChecked ?? currentState.agreementChecked,
      unitSystem: unitSystem ?? currentState.unitSystem,
    ));
  }

  // Метод производит расчёт кинетической энергии.
  void calculateEnergy() {
    // Получаем текущее состояние, приводя его к InputState.
    final state = this.state as InputState;

    // Проверяем, согласен ли пользователь на обработку данных.
    if (!state.agreementChecked) {
      return; // Если нет согласия — останавливаем выполнение.
    }

    // Получаем значения массы и скорости из строки.
    final massStr = state.mass;
    final velocityStr = state.velocity;

    // Проверяем, не пустые ли поля.
    if (massStr.isEmpty || velocityStr.isEmpty) return;

    // Преобразуем строки в числа.
    final mass = double.tryParse(massStr);
    final velocity = double.tryParse(velocityStr);

    // Проверяем, корректны ли значения: должны быть числами и > 0.
    if (mass == null || velocity == null || mass <= 0 || velocity < 0) return;

    /* 
     * Константы для конвертации:
     * poundsToKg — фунты в килограммы
     * mphToMs — мили/час в метры/секунду
     * kmhToMs — км/ч в метры/секунду
     */
    const poundsToKg = 0.453592;
    const mphToMs = 0.44704;
    const kmhToMs = 0.277778;

    // Переменные для хранения значений в системе СИ
    double convertedMass = mass;
    double convertedVelocity = velocity;

    // Если выбрана английская система — конвертируем массу и скорость
    if (state.unitSystem == 'imperial') {
      convertedMass *= poundsToKg;
      convertedVelocity *= mphToMs;
    } else {
      // В противном случае — конвертируем только скорость (км/ч → м/с)
      convertedVelocity *= kmhToMs;
    }

    // Рассчитываем кинетическую энергию по формуле: E = ½mv²
    final energy = 0.5 * convertedMass * convertedVelocity * convertedVelocity;

    // Отправляем результат в виде нового состояния ResultState.
    emit(ResultState(
      mass: convertedMass,
      velocity: convertedVelocity,
      energy: energy,
      unitSystem: state.unitSystem,
      originalMass: mass,
      originalVelocity: velocity,
    ));
  }

  // Метод goBack: возвращает пользователя обратно к форме ввода.
  void goBack() {
    emit(InputState()); // Выдаём начальное состояние InputState
  }
}