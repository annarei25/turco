# Turco

Aplicación Flutter para Android que gestiona los turnos de una peluquería mixta. La usa el personal de recepción para registrar clientes, programar turnos con un estilista y llevar la agenda diaria.

Primer examen parcial · Programación para Dispositivos Móviles · Ingeniería Informática, 3.er año.
Autora: Ana Laura Reinoso Fernandez.

## Datos del proyecto

| Dato | Valor |
|---|---|
| Nombre visible | Turco |
| Application id | `com.anareinoso.turco` |
| Versión de Flutter | 3.47.7 |
| Plataforma | Android |
| Gestor de estado | `ChangeNotifier` (MVVM), sin paquetes externos |
| Navegación | `go_router` con `StatefulShellRoute.indexedStack` |
| Fuente | Poppins |
| Iconos | Lucide (fuente `lucide.ttf`, licencia ISC en `assets/fonts/`) |

La aplicación no usa servidor, base de datos, almacenamiento local ni autenticación. Los datos viven en memoria y se cargan desde datos de prueba al iniciar. Las fechas de los turnos de prueba se calculan con `DateTime.now()`.

## Cómo ejecutar el proyecto

1. Instalar Flutter y tener un emulador o un teléfono Android conectado.
2. Clonar el repositorio:
   ```
   git clone https://github.com/annarei25/turco.git
   cd turco
   ```
3. Descargar las dependencias:
   ```
   flutter pub get
   ```
4. Ejecutar la app:
   ```
   flutter run
   ```
5. (Opcional) Ejecutar las pruebas de las reglas de negocio:
   ```
   flutter test
   ```

## Cómo generar el APK release

```
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. Como `build/` no se sube al repositorio, el APK se copia a `entrega/turco.apk` y se publica en la sección **Releases** de GitHub.

## Estructura de carpetas

```
lib/
  main.dart                  MaterialApp.router, temas y modo de tema
  theme/                     Tema claro y oscuro
    app_colors.dart            paletas (único archivo con valores de color)
    app_theme.dart             estilos de los componentes
    app_text_styles.dart       tamaños y pesos de texto (Poppins)
    app_dimensions.dart        espacios, radios y tamaños
    app_icons.dart             iconos Lucide
  models/                    Servicio, Estilista, Cliente, Turno, HorarioSalon
  data/                      datos de prueba en memoria
  viewmodels/                ChangeNotifier con las reglas de negocio
    salon_viewmodel.dart       datos, solapes, franjas libres, altas y bajas
    agenda_ / clientes_ / servicios_ / estilistas_ / turno_form_ / tema_viewmodel.dart
    app_viewmodels.dart        crea todos los ViewModels una sola vez
  routes/                    go_router y rutas
  screens/                   Agenda, Detalle de turno, Formulario de turno,
                             Clientes, Servicios, Estilistas y la barra inferior
  widgets/                   componentes reutilizables
  utils/                     formatos, fechas y validadores
assets/fonts/                Poppins y Lucide
test/                        pruebas de las reglas de negocio
capturas/                    capturas reales de la app
entrega/                     APK release
```

## Rutas

| Ruta | Pantalla |
|---|---|
| `/agenda` (inicial) | Agenda. Acepta `?estilista=3` |
| `/clientes` | Clientes |
| `/servicios` | Servicios |
| `/estilistas` | Estilistas |
| `/turno/nuevo` | Formulario de turno (recibe datos iniciales con `extra`) |
| `/turno/:id` | Detalle de turno (parámetro de ruta) |
| `/turno/:id/editar` | Formulario de turno en edición |

Detalle y Formulario se abren por encima de la barra inferior. El turno guardado vuelve a la pantalla anterior con `context.pop(turno)`.

## Reglas de negocio

- El salón atiende de lunes a sábado, de 9:00 a 19:00. Los domingos está cerrado.
- Los turnos empiezan en franjas de 30 minutos y terminan a las 19:00 como máximo.
- Un estilista solo recibe servicios que realiza.
- Un estilista no puede tener dos turnos solapados, ni un cliente tampoco. Los cancelados no ocupan horario.
- No se crean ni reprograman turnos en fechas u horas pasadas.
- Solo los turnos programados se editan, completan o cancelan. Los turnos no se eliminan, se cancelan.
- El teléfono del cliente es único y tiene 8 dígitos.
- No se puede eliminar un cliente con turnos programados.
- La duración, la hora de fin y el precio de un turno se calculan con sus servicios.

Estas reglas están en `salon_viewmodel.dart` y `turno_form_viewmodel.dart`, nunca dentro de los widgets.
