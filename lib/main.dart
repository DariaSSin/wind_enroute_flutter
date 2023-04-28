import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jeodezi/jeodezi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExampleHomeScreen(),
    );
  }
}

class ExampleHomeScreen extends StatefulWidget {
  const ExampleHomeScreen({Key? key}) : super(key: key);

  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  //из модуля jeodezi
  final greatCircle = GreatCircle();

  // пример маршрута из 4х точек,
  // координаты подставлены в класс из модуля jeodezi
  final uutsCoordinates = Coordinate(56.513, 34.972); // The coordinates of UUTS
  final uueyCoordinates = Coordinate(56.779, 36.281); // The coordinates of UUEY
  final uubiCoordinates = Coordinate(56.943, 40.932); // The coordinates of UUBI
  final uudgCoordinates = Coordinate(54.786, 37.647); // The coordinates of UUDG
  
  @override
  Widget build(BuildContext context) {

    // точки маршрута собраны в list
    final route = [uutsCoordinates, uueyCoordinates, uubiCoordinates, uudgCoordinates];

    // создаем рабочий list для сбора всех точек включая промежуточные
    final serviceRouteCoords = [];
    
    // создаем list для обьединения широты и долготы каждой конкретной точки
    List firstElement = [];

    // добавляем первую точку маршрута в рабочий list
    firstElement.add(route[0]);
    serviceRouteCoords.add(firstElement);

    // проходим по очереди по каждой точке маршрута
    for (int i=1; i<route.length; i++) {

      //фиксируем координаты текущей точки
      Coordinate firstPoint = route[i-1];

      //фиксируем координаты второй точки после текущей
      Coordinate secondPoint = route[i];

      // вычисляем расстояние между точками
      var distance = greatCircle.distance(firstPoint, secondPoint);

      // если расстояние меньше 100км - сразу добавляем координаты второй точки в рабочий list
      if (distance <= 100) {
        List nextElement = [];
        nextElement.add(secondPoint);
        serviceRouteCoords.add(nextElement);
      }
      // если расстояние больше 100км:
      else {
        // пока удаление более 100км:
        while (distance>100) { 
          // вычисляем азимут на вторую точку
          double ibearing = greatCircle.bearing(firstPoint, secondPoint);
          // вычисляем промежуточную точку на данном азимуте на расстоянии 100км
          Coordinate destination = greatCircle.destination(
            startPoint: firstPoint,
            bearing: ibearing,
            distance: 100,
          );
          // добавляем промежуточную точку в рабочий list
          List nextElement = [];
          nextElement.add(destination);
          serviceRouteCoords.add(nextElement);

          // назначаем промежуточную точку на место firstPoint
          firstPoint = destination;
          // вычисляем новое расстояние между промежуточной точкой и второй точкой исходного маршрута,
          //повторяем проверку расстояния в цикле while
          distance = greatCircle.distance(firstPoint, secondPoint);
        }
        // после завершения цикла когда расстояние от последней промежуточной точки
        // до второй точки исходного маршрута стало менее 100км, 
        // добавляем координаты второй точки исходного маршрута в рабочий list
        List nextElement = [];
        nextElement.add(secondPoint);
        serviceRouteCoords.add(nextElement);
      } // затем повторяем процедуру цикла for для всех остальных точек исходного маршрута
    }
    print(serviceRouteCoords);
    print('\n');

    // на основе рабочего list создаем новый list, содержащий для каждой рабочей точки
    //азимут и расстояние до следующей (нужно для расчета поправки по ветру):
    List bearingDistanceAllPoints = [];

    // проходим по каждому элементу в list "serviceRouteCoords"
    for (int i=1; i<serviceRouteCoords.length; i++) {
      // создаем map для записи азимута и расстояния по ключам для каждой конкретной точки
      Map bearingDistanceOnePoint = {};
      bearingDistanceOnePoint['bearing'] = greatCircle.bearing(serviceRouteCoords[i-1][0], serviceRouteCoords[i][0]);
      bearingDistanceOnePoint['distance'] = greatCircle.distance(serviceRouteCoords[i-1][0], serviceRouteCoords[i][0]);
      // вносим данные для всех точек в list
      bearingDistanceAllPoints.add(bearingDistanceOnePoint);
    }
    print(bearingDistanceAllPoints);
    print('\n');

    // пример данных по ветру для каждой рабочей точки 
    Map uuts = {"Lat":"56.5","Lon":"35.0","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":140,"wind_sp_mps_int":8,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uuey = {"Lat":"56.8","Lon":"36.3","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":150,"wind_sp_mps_int":7,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uuey2 = {"Lat":"56.9","Lon":"37.9","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uuey3 = {"Lat":"56.9","Lon":"39.6","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":160,"wind_sp_mps_int":5,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uubi = {"Lat":"56.9","Lon":"40.9","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":165,"wind_sp_mps_int":6,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uubi2 = {"Lat":"56.2","Lon":"39.8","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":150,"wind_sp_mps_int":7,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uubi3 = {"Lat":"55.7","Lon":"38.7","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":140,"wind_sp_mps_int":8,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uubi4 = {"Lat":"54.9","Lon":"37.7","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":130,"wind_sp_mps_int":9,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};
    Map uudg = {"Lat":"54.8","Lon":"37.6","DATETIME":"2023040515Z","WIND\/T":{"FL10":{"wind_dir_deg_int":120,"wind_sp_mps_int":10,"air_temp_deg_C_int":13,"wind_and_temp_str":"140\/08MPS PS13"},"FL20":{"wind_dir_deg_int":150,"wind_sp_mps_int":6,"air_temp_deg_C_int":11,"wind_and_temp_str":"150\/06MPS PS11"},"FL30":{"wind_dir_deg_int":170,"wind_sp_mps_int":6,"air_temp_deg_C_int":7,"wind_and_temp_str":"170\/06MPS PS07"},"FL50":{"wind_dir_deg_int":190,"wind_sp_mps_int":8,"air_temp_deg_C_int":3,"wind_and_temp_str":"190\/08MPS PS03"}}};

    // объединяем в list для обработки
    List windsAllData = [uuts, uuey, uuey2, uuey3, uubi, uubi2, uubi3, uubi4, uudg]; 

    // создаем list для хранения только направления и скорости ветра в нужной точке на нужной высоте
    List onlyNeededWinds = [];
    
    // проходим по всем элементам list "windsAllData", извлекаем по ключам нужные данные о ветре
    for (Map i in windsAllData) {
      // пока предполагаем расчет для высоты FL10 (впоследствии подставлять из флайтплана)
      int meteo_wind_dir_deg = i["WIND\/T"]["FL10"]["wind_dir_deg_int"];
      int wind_sp_mps = i["WIND\/T"]["FL10"]["wind_sp_mps_int"];

      // создаем переменную для хранения навигационного ветра 
      // (отличается на 180 градусов от метеорогогического)
      int nav_wind_dir_deg = 0;

      // вычисляем навигационный ветер в зависимости от направления
      if (meteo_wind_dir_deg < 180) {
        nav_wind_dir_deg = meteo_wind_dir_deg + 180;
      }
      else if (meteo_wind_dir_deg >= 180) {
        nav_wind_dir_deg = meteo_wind_dir_deg - 180;
      }
      else {
        nav_wind_dir_deg = 0;
      }

      // создаем map для записи направления и скорости навигационного ветра 
      //по ключам (для конкретной точки)
      Map <String, int> windAtPoint = {};
      windAtPoint['direction'] = nav_wind_dir_deg;
      windAtPoint['speed'] = wind_sp_mps;

      // собираем данные о навигационном ветре по всем точкам в list
      onlyNeededWinds.add(windAtPoint);
    }
    print(onlyNeededWinds);
    print('\n');

    // создаем list который будет хранить для каждого рабочего участка поправку к скорости и 
    //поправку ко времени относительно штилевого расчета 
    List windTimeCorrections = [];

    // возьмем для расчета скорость ВС 220км/ч (впоследствии подставлять из флайтплана)
    double aircraftSpeedKMH = 220;

    // вычисляем угол ветра по отношению к азимуту участка:
    // проходим по индексам list "bearingDistanceAllPoints",
    //тк количество элементов в этом list соответствует количеству лэгов между рабочими точками 
    for (int i=0; i<bearingDistanceAllPoints.length; i++) {
      // переменная windAngle хранит угол ветра
      double windAngleDegrees = 0;
      if (bearingDistanceAllPoints[i]['bearing'] >= onlyNeededWinds[i]['direction']) {
        windAngleDegrees = bearingDistanceAllPoints[i]['bearing'] - onlyNeededWinds[i]['direction'];
      }
      else if (bearingDistanceAllPoints[i]['bearing'] < onlyNeededWinds[i]['direction']) {
        windAngleDegrees = onlyNeededWinds[i]['direction'] - bearingDistanceAllPoints[i]['bearing'];
      }
      else {
        windAngleDegrees = 0;
      }
      
      // вычисляем угол ветра в радианах
      var windAngleRadians = (windAngleDegrees*pi)/180;

      // вычисляем косинус угла ветра:
      //положительный косинус - попутный ветер, отрицательный - встречный ветер
      double cosOfAngle = cos(windAngleRadians);

      // вычисляем поправку к скорости в м/сек: 
      double speedCorrectionMPS = cosOfAngle*(onlyNeededWinds[i]['speed']);

      // вычисляем поправку к скорости в км/ч:
      double speedCorrectionKMH = speedCorrectionMPS*3.6;

      // вычисляем путевую скорость ВС (т.е. с учетом ветра):
      double actualAircraftSpeed = aircraftSpeedKMH + speedCorrectionKMH;

      // вычисляем штилевое время в часах
      double baseFlightTime = (bearingDistanceAllPoints[i]['distance'])/aircraftSpeedKMH;

      // вычисляем время в часах на рабочем участке с учетом ветра
      double actualFlightTime = (bearingDistanceAllPoints[i]['distance'])/actualAircraftSpeed;

      // вычисляем поправку ко времени полета по рабочему участку в минутах
      double timeCorrectionMIN = (actualFlightTime - baseFlightTime)*60;

      // собираем поправки для конкретной точки в рабочий map
      Map speedTimeCorrectionsOnePoint = {};
      speedTimeCorrectionsOnePoint['speedCorrectionKMH'] = speedCorrectionKMH;
      speedTimeCorrectionsOnePoint['timeCorrectionMIN'] = timeCorrectionMIN;

      // добавляем рабочий map в общий list 
      windTimeCorrections.add(speedTimeCorrectionsOnePoint);
    }
    print(windTimeCorrections);
    print('\n');

    // создаем map для хранения общей поправки по всему маршруту
    Map meanWindTimeCorrections = {};

    // переменная meanTimeCorrection хранит общую поправку ко времени для всего маршрута
    double meanTimeCorrection = 0;

    // суммируем все временные поправки
    for (int i=0; i<windTimeCorrections.length; i++) {
      meanTimeCorrection = meanTimeCorrection + windTimeCorrections[i]['timeCorrectionMIN'];
    }
    
    //сохраняем в map значение общей поправки по ключу
    meanWindTimeCorrections['meanTimeCorrectionMIN'] = meanTimeCorrection;
    print(meanWindTimeCorrections);
    

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jeodezi Functions"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Поправка по времени ${meanWindTimeCorrections['meanTimeCorrectionMIN']} минут'),
          ]
        ),
      ),
    );
  }
}