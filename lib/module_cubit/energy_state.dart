//  абстрактный класс EnergyCalculatorState — базовый класс для всех состояний приложения.
abstract class EnergyCalculatorState {}

// Состояние InitialState — начальное состояние при запуске приложения.
class InitialState extends EnergyCalculatorState {}

// Состояние InputState — отвечает за хранение данных формы ввода пользователя.
class InputState extends EnergyCalculatorState {
  // Масса тела, введённая пользователем (в виде строки)
  final String mass;

  // Скорость тела, введённая пользователем (в виде строки)
  final String velocity;

  // Флаг согласия на обработку данных
  final bool agreementChecked;

  // Выбранная система единиц: 'si' — метрическая (кг, км/ч), 'imperial' — английская (фунты, миль/ч)
  final String unitSystem;

  // Конструктор InputState с возможностью установки начальных значений.
  // По умолчанию:
  // масса 
  // скорость 
  // согласие = false
  // система единиц = 'si'
  InputState({
    this.mass = '',
    this.velocity = '',
    this.agreementChecked = false,
    this.unitSystem = 'si',
  });
}

// Состояние ResultState — отвечает за хранение результата вычислений.
class ResultState extends EnergyCalculatorState {
  // Масса в системе СИ (килограммы) после конвертации
  final double mass;

  // Скорость в системе СИ (метры в секунду) после конвертации
  final double velocity;

  // Рассчитанное значение кинетической энергии в джоулях
  final double energy;

  // Использованная система единиц 
  final String unitSystem;

  // Оригинальное значение массы, введённое пользователем (до конвертации)
  final double originalMass;

  // Оригинальное значение скорости, введённое пользователем (до конвертации)
  final double originalVelocity;

  // Конструктор ResultState — требует все параметры для создания объекта состояния.
  ResultState({
    required this.mass,
    required this.velocity,
    required this.energy,
    required this.unitSystem,
    required this.originalMass,
    required this.originalVelocity,
  });
}