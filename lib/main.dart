// Импортируем основную библиотеку Flutter
import 'package:flutter/material.dart';

// Импортируем пакет flutter_bloc для работы с BLoC архитектурой
import 'package:flutter_bloc/flutter_bloc.dart';

// Импортируем файл, в котором определены классы состояний (InitialState, InputState, ResultState)
import 'module_cubit/energy_state.dart';

// Импортируем Cubit — бизнес-логику приложения
import 'module_cubit/energy_cubit.dart';

// Главная функция приложения — точка входа
void main() {
  // Запуск приложения с корневым виджетом MyApp
  runApp(const MyApp());
}

// Корневой виджет приложения — наследуется от StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Метод build — строит дерево виджетов
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Создаём экземпляр EnergyCalculatorCubit и вызываем initForm()
      create: (context) => EnergyCalculatorCubit()..initForm(),
      child: MaterialApp(
        title: 'Калькулятор кинетической энергии',
        theme: ThemeData(
          // Настройка цветовой схемы приложения
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true, // Использование Material 3
        ),
        home: const HomeScreen(), // Начальный экран приложения
      ),
    );
  }
}

// Главный экран приложения — управляет отображением разных состояний
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnergyCalculatorCubit, EnergyCalculatorState>(
      builder: (context, state) {
        if (state is InputState) {
          // Если состояние InputState — показываем форму ввода
          return InputScreen(state: state);
        } else if (state is ResultState) {
          // Если состояние ResultState — показываем результат
          return ResultScreen(state: state);
        }
        // По умолчанию — пустое пространство
        return const SizedBox();
      },
    );
  }
}

// Экран ввода данных пользователя
class InputScreen extends StatelessWidget {
  final InputState state;

  const InputScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EnergyCalculatorCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор кинетической энергии'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Гаврилов Д.А.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                initialValue: state.mass,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Масса тела',
                  border: const OutlineInputBorder(),
                  suffixText: state.unitSystem == 'si' ? 'кг' : 'фунты',
                ),
                onChanged: (value) => cubit.updateValues(mass: value),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: state.velocity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Скорость',
                  border: const OutlineInputBorder(),
                  suffixText: state.unitSystem == 'si' ? 'км/ч' : 'миль/ч',
                ),
                onChanged: (value) => cubit.updateValues(velocity: value),
              ),
              const SizedBox(height: 20),
              const Text('Система единиц:'),
              RadioListTile(
                title: const Text('СИ (кг, км/ч)'),
                value: 'si',
                groupValue: state.unitSystem,
                onChanged: (value) => cubit.updateValues(unitSystem: value),
              ),
              RadioListTile(
                title: const Text('Английская (фунты, миль/ч)'),
                value: 'imperial',
                groupValue: state.unitSystem,
                onChanged: (value) => cubit.updateValues(unitSystem: value),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Согласен на обработку данных'),
                value: state.agreementChecked,
                onChanged: (value) => cubit.updateValues(agreementChecked: value),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => cubit.calculateEnergy(),
                child: const Text('Рассчитать'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран отображения результата вычислений
class ResultScreen extends StatelessWidget {
  final ResultState state;

  const ResultScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат расчета'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Гаврилов Д.А.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Масса: ${state.originalMass.toStringAsFixed(2)} ${state.unitSystem == 'si' ? 'кг' : 'фунтов'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Скорость: ${state.originalVelocity.toStringAsFixed(2)} ${state.unitSystem == 'si' ? 'км/ч' : 'миль/ч'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Text('Кинетическая энергия:', style: TextStyle(fontSize: 20)),
              Text(
                '${state.energy.toStringAsFixed(2)} Дж',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              if (state.unitSystem == 'imperial') ...[
                const SizedBox(height: 20),
                const Text('(Конвертировано в СИ)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('${state.originalMass.toStringAsFixed(2)} фунтов = ${state.mass.toStringAsFixed(2)} кг', style: const TextStyle(fontSize: 14)),
                Text('${state.originalVelocity.toStringAsFixed(2)} миль/ч = ${state.velocity.toStringAsFixed(2)} м/с', style: const TextStyle(fontSize: 14)),
              ],
              if (state.unitSystem == 'si') ...[
                const SizedBox(height: 20),
                const Text('(Конвертировано в м/с)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('${state.originalVelocity.toStringAsFixed(2)} км/ч = ${state.velocity.toStringAsFixed(2)} м/с', style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.read<EnergyCalculatorCubit>().goBack(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}