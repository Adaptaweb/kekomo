# PLAN DE MIGRACIÓN: KeComo Android → Flutter

## 1. Descripción General

**App:** KeComo — Aplicación para almacenar y guardar todos los alimentos consumidos en el día con el fin de detectar posibles alérgenos.

**Origen:** Android Kotlin con Jetpack Compose (~3030 líneas)
**Destino:** Flutter con Dart
**Stack destino:** `sqflite` + `Riverpod` + `Material 3` + `pdf`

---

## 2. Arquitectura Propuesta

```
kecomo_flutter/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # KeComoApp widget con ProviderScope
│   │
│   ├── theme/
│   │   ├── app_colors.dart                # Constantes de color light/dark
│   │   └── app_theme.dart                 # ThemeData light + dark
│   │
│   ├── data/
│   │   ├── database_helper.dart           # Singleton sqflite, creación tablas, migraciones
│   │   ├── models/
│   │   │   ├── profile.dart               # Profile model con toMap() / fromMap()
│   │   │   ├── meal_log.dart              # MealLog model
│   │   │   ├── allergen.dart              # Allergen model
│   │   │   ├── reaction.dart              # Reaction model
│   │   │   └── setting.dart               # Setting model
│   │   └── kecomo_repository.dart         # Wrapper CRUD sobre DatabaseHelper
│   │
│   ├── providers/
│   │   ├── navigation_provider.dart       # CurrentScreen state
│   │   ├── profile_provider.dart          # Perfiles, activeProfileId, switchProfile, createProfile
│   │   ├── meal_log_provider.dart         # MealLogs, activeInputText, save/delete
│   │   ├── reaction_provider.dart         # Reactions, diálogo reacción
│   │   ├── allergen_provider.dart         # Allergens, add/remove
│   │   ├── settings_provider.dart         # mealConfig, darkMode, reminders, safetyAlerts
│   │   └── pdf_provider.dart              # PDF date range + options
│   │
│   ├── widgets/
│   │   ├── liquid_glass_card.dart         # BackdropFilter + blur (efecto glass)
│   │   ├── animated_dialog_content.dart   # AnimatedScale + AnimatedOpacity
│   │   ├── bottom_nav_bar.dart            # Barra navegación inferior glass
│   │   ├── profile_switcher.dart          # Dropdown cambio de perfil
│   │   ├── key_chip.dart                  # Chip tipo badge
│   │   ├── settings_toggle_row.dart       # Fila switch ajustes
│   │   ├── settings_action_row.dart       # Fila accionable ajustes
│   │   ├── option_toggle_row.dart         # Fila switch opciones PDF
│   │   └── allergen_insight_item.dart     # Item de insight de alérgeno
│   │
│   ├── screens/
│   │   ├── onboarding_screen.dart         # Creación primer perfil
│   │   ├── today_screen.dart              # Pantalla principal Hoy
│   │   ├── calendar_screen.dart           # Calendario mensual
│   │   ├── summary_screen.dart            # Resumen semanal
│   │   ├── settings_screen.dart           # Ajustes y configuración
│   │   └── export_pdf_screen.dart         # Exportar PDF
│   │
│   └── utils/
│       ├── date_utils.dart                # Formateo y manipulación de fechas
│       ├── pdf_generator.dart             # Generación de PDF
│       └── custom_icons.dart              # Iconos custom (cámara, micrófono, upload)
│
├── test/                                  # Tests unitarios y de widgets
├── pubspec.yaml                           # Dependencias del proyecto
└── PLAN_MIGRACION_FLUTTER.md              # Este archivo
```

---

## 3. Stack Tecnológico Detallado

| Capa | Android (original) | Flutter (destino) | Paquete Flutter |
|---|---|---|---|
| Base de datos local | Room + SQLite | sqflite | `sqflite: ^2.4.2` |
| State management | ViewModel + StateFlow | Riverpod | `flutter_riverpod: ^2.6.1` |
| UI Framework | Jetpack Compose | Flutter Widgets | SDK nativo |
| Tema | Material 3 ColorScheme | ThemeData con colores exactos | SDK nativo |
| Navegación | State-based manual | State-based con Riverpod | — |
| Efecto glass | kyant.backdrop | BackdropFilter + ImageFilter.blur | SDK nativo |
| PDF | android.graphics.pdf | pdf (Dart) | `pdf: ^3.11.3` |
| Reconocimiento voz | RecognizerIntent | speech_to_text | `speech_to_text: ^7.0.0` |
| Cámara/Galería | ActivityResultContracts | image_picker | `image_picker: ^1.1.2` |
| Iconos extendidos | Material Icons Extended | material_design_icons_flutter | `material_design_icons_flutter: ^7.0.7296` |
| Fechas | SimpleDateFormat/Calendar | intl (DateFormat) | `intl: ^0.20.2` |
| Compartir archivos | Intent | share_plus | `share_plus: ^10.1.4` |
| Paths archivos | Environment | path_provider | `path_provider: ^2.1.5` |

---

## 4. Esquema de Base de Datos (5 tablas)

Las mismas 5 tablas que en Room, migradas a sqflite:

### 4.1. Tabla: `profiles`
```sql
CREATE TABLE profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  age INTEGER DEFAULT 0,
  category TEXT NOT NULL,
  photoUri TEXT
);
```

### 4.2. Tabla: `meal_logs`
```sql
CREATE TABLE meal_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  date TEXT NOT NULL,
  mealType TEXT NOT NULL,
  foodItemsText TEXT NOT NULL,
  hasReaction INTEGER DEFAULT 0,
  reactionSymptoms TEXT DEFAULT '',
  reactionSeverity TEXT DEFAULT '',
  FOREIGN KEY (profileId) REFERENCES profiles(id)
);
```

### 4.3. Tabla: `allergens`
```sql
CREATE TABLE allergens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  name TEXT NOT NULL,
  FOREIGN KEY (profileId) REFERENCES profiles(id)
);
```

### 4.4. Tabla: `settings`
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

### 4.5. Tabla: `reactions`
```sql
CREATE TABLE reactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  date TEXT NOT NULL,
  mealType TEXT NOT NULL,
  description TEXT DEFAULT '',
  symptoms TEXT DEFAULT '',
  FOREIGN KEY (profileId) REFERENCES profiles(id)
);
```

### 4.6. Defaults a insertar en settings
```sql
INSERT OR IGNORE INTO settings (key, value) VALUES ('meal_config', 'Ambos');
INSERT OR IGNORE INTO settings (key, value) VALUES ('dark_mode', 'false');
INSERT OR IGNORE INTO settings (key, value) VALUES ('reminders_enabled', 'true');
INSERT OR IGNORE INTO settings (key, value) VALUES ('safety_alerts_enabled', 'true');
```

---

## 5. Modelos Dart (con sqflite)

Cada modelo tendá:
- `fromMap(Map<String, dynamic> map)` → factory constructor
- `toMap()` → método de instancia
- `copyWith()` → método para copia inmutable

Ejemplo:
```dart
class Profile {
  final int? id;
  final String firstName;
  final String lastName;
  final int age;
  final String category;
  final String? photoUri;

  Profile({this.id, required this.firstName, required this.lastName,
    this.age = 0, required this.category, this.photoUri});

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'] as int?,
    firstName: map['firstName'] as String,
    lastName: map['lastName'] as String,
    age: map['age'] as int? ?? 0,
    category: map['category'] as String,
    photoUri: map['photoUri'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'age': age,
    'category': category,
    'photoUri': photoUri,
  };

  Profile copyWith({int? id, String? firstName, String? lastName,
    int? age, String? category, String? photoUri}) => Profile(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    age: age ?? this.age,
    category: category ?? this.category,
    photoUri: photoUri ?? this.photoUri,
  );
}
```

---

## 6. DatabaseHelper (sqflite Singleton)

Archivo: `lib/data/database_helper.dart`

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kecomo-db.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE profiles (...)''');
    await db.execute('''CREATE TABLE meal_logs (...)''');
    await db.execute('''CREATE TABLE allergens (...)''');
    await db.execute('''CREATE TABLE settings (...)''');
    await db.execute('''CREATE TABLE reactions (...)''');
    // Insert defaults
    await db.execute("INSERT OR IGNORE INTO settings ...");
  }
}
```

---

## 7. Mapeo de Providers Riverpod

Cada agrupación lógica del ViewModel original se convierte en un provider atómico:

| Provider | Tipo | State | Función |
|---|---|---|---|
| `currentScreenProvider` | `StateProvider<KeComoScreen>` | enum | Navegación |
| `selectedDateProvider` | `StateProvider<String>` | "yyyy-MM-dd" | Fecha seleccionada |
| `activeProfileIdProvider` | `StateProvider<int?>` | int\|null | Perfil activo |
| `allProfilesProvider` | `FutureProvider<List<Profile>>` | List | Todos los perfiles |
| `mealLogsProvider` | `FutureProvider.family<List<MealLog>, int>` | List | Logs por profileId |
| `activeInputTextProvider` | `StateNotifierProvider` | Map<String, String> | Inputs por tipo comida |
| `reactionsProvider` | `FutureProvider.family` | List | Reacciones por fecha |
| `allergensProvider` | `FutureProvider.family` | List | Alérgenos por perfil |
| `mealConfigProvider` | `StateProvider<String>` | String | Config comidas |
| `darkModeProvider` | `StateProvider<bool>` | bool | Dark mode |
| `remindersProvider` | `StateProvider<bool>` | bool | Recordatorios |
| `safetyAlertsProvider` | `StateProvider<bool>` | bool | Alertas |
| `pdfFromDateProvider` / `pdfToDateProvider` | `StateProvider<String>` | String | Rango PDF |
| `pdfIncludeMeals/Reactions/Anals/NotesProvider` | `StateProvider<bool>` | bool | Opciones PDF |
| `showAllergenDialogProvider` | `StateProvider<bool>` | bool | Diálogo alérgeno |
| `allergenInputProvider` | `StateProvider<String>` | String | Input alérgeno |
| `reactionDialogMealTypeProvider` | `StateProvider<String?>` | String\|null | Diálogo reacción |
| `reactionDialogSymptomsProvider` | `StateProvider<String>` | String | Síntomas reacción |
| `reactionDialogDescriptionProvider` | `StateProvider<String>` | String | Descripción reacción |

**Enumeración de pantallas:**
```dart
enum KeComoScreen {
  onboarding,
  today,
  calendar,
  summary,
  settings,
  exportPdf,
}
```

---

## 8. Mapeo 1:1 de Pantallas Android → Flutter

### 8.1. OnboardingScreen
| Elemento Android | Equivalente Flutter |
|---|---|
| Columna con scroll | `SingleChildScrollView` + `Column` |
| Icono Person grande | `Icon(Icons.person, size: 64)` |
| Text cabecera | `Text` con estilo headlineMedium |
| OutlinedTextField nombre | `TextField` con `InputDecoration` borde redondeado |
| OutlinedTextField apellido | Ídem |
| Categorías (Padre/Madre/Hijo/Hija) | Row de Box clickables con background condicional |
| FlowRow alérgenos comunes | `Wrap` de chips seleccionables |
| Button "Empezar" | `ElevatedButton` con borderRadius 16 |
| `viewModel.createProfile(...)` | `ref.read(profileProvider.notifier).createProfile(...)` |

**Categorías fijas:** "Padre", "Madre", "Hijo", "Hija"
**Alérgenos comunes:** "Maní", "Mariscos", "Leche", "Huevos", "Frutos Secos", "Soya", "Trigo"

---

### 8.2. TodayScreen (Hoy)

**Scroll principal con:**
1. **Cabecera:** "Tu Bienestar" / "Editando: fecha" + Título + ProfileSwitcher
2. **Cards de comidas** (3 según config: Desayuno, Almuerzo, Once/Cena)

**Cada card de comida contiene:**
- Icono tipo comida + nombre + rango horario
- Al expandirse:
  - `OutlinedTextField` con placeholder
  - Botones: Galería, Cámara, Micrófono
  - Botón "Guardar" + Botón "Reacción Alérgica"
- Lista de logs guardados (con DropdownMenu editar/eliminar)

**Dialogs simulados:**
- **VoiceDialog:** Selección de sugerencias de voz (tocar ejemplo escribe el texto)
- **CameraDialog:** Simulador con viewfinder + sugerencias de platos
- **GalleryDialog:** Lista de fotos simuladas con nombres de comidas

**Progress card:** Barra de progreso diaria con porcentaje

**Modal de edición/eliminación:** Dialog para modificar texto o confirmar eliminación

---

### 8.3. CalendarScreen

| Elemento Android | Flutter |
|---|---|
| Grid calendario 31 días | `GridView` o `Column` con `Row`s de 7 días |
| Mes y año en cabecera | `Text` con `DateFormat('MMMM yyyy', 'es')` |
| Día seleccionado (background primaryContainer) | `Container` con color condicional |
| Día hoy (borde primary) | `Container` con `BoxDecoration` border |
| Indicador reacción (dot pequeño) | `Container` circular 4px tertiary |
| Leyenda (Posible reacción / Hoy) | Row con dots + texto |
| Detalles del día seleccionado | Lista de LiquidGlassCard por mealType |
| Chips de ingredientes | `Wrap` de `KeyChip` widgets |

---

### 8.4. SummaryScreen

| Elemento Android | Flutter |
|---|---|
| Bar chart semanal (L M X J V S D) | 7 `Container`s con altura variable |
| % de registro semanal | Texto grande con primaryContainer |
| Reacciones detectadas | Card con ícono Warning + número |
| Análisis Inteligente | Card con icono Psychology + texto descriptivo |
| AllergenInsightItems | 2 filas (Huevo Entero: Riesgo Alto, Leche de Soya: Riesgo Medio) |
| Botón Exportar Reporte | ElevatedButton a pantalla PDF |
| Tip card | Card con icono Lightbulb + texto cita |

**Datos hardcodeados (como en Android):**
- "Huevo Entero - Registrado 4 veces antes de reacción - Riesgo Alto"
- "Leche de Soya - Registrado 2 veces antes de reacción - Riesgo Medio"
- Texto tip: "La contaminación cruzada es común en panaderías..."

---

### 8.5. SettingsScreen

| Elemento Android | Flutter |
|---|---|
| Foto perfil (clic para cambiar) | `CircleAvatar` + `image_picker` |
| Nombre y categoría | Text widgets |
| Botón editar perfil | IconButton -> Dialog edición |
| FlowRow alérgenos activos | `Wrap` de chips con X para eliminar |
| Botón "Añadir Nuevo" alérgeno | Chip + -> Abre AddAllergenDialog |
| Meal config (Once/Cena/Ambos) | Row de 3 botones toggle |
| Recordatorios de Comidas | Switch |
| Alertas de Seguridad | Switch |
| Modo Oscuro | Switch |
| Exportar mis Datos | SettingsActionRow -> ExportPdfScreen |
| Política de Privacidad | SettingsActionRow -> Toast |
| Cerrar Sesión | SettingsActionRow (destructive) -> Toast |
| Versión "KECOMO V2.4.0" | Text centrado |

**EditProfileDialog:**
- Foto circular clickable
- TextField Nombre + Apellido
- Botones Cancelar / Guardar

---

### 8.6. ExportPdfScreen

| Elemento Android | Flutter |
|---|---|
| Botón Back + Título | Back button + Text |
| Descripción informativa | Text secundario |
| Card Rango de Fecha | 2 TextFields (Desde / Hasta) + 3 presets |
| Presets: Últimos 7 días, Este Mes, Últimos 3 Meses | Row de 3 botones |
| Card Opciones de Reporte | 4 OptionToggleRows (Comidas, Síntomas, Nutrientes, Notas) |
| Botón "Generar PDF de Reporte" | ElevatedButton grande con icono PDF |

**PDF Generation (`pdf_generator.dart`):**
- Usa `package:pdf/pdf.dart` y `package:pdf/widgets.dart` (pw)
- Mismo layout que el original: título, subtítulo, línea separadora, datos del paciente
- Lista de comidas filtradas por rango de fechas
- Indicadores de reacción alérgica por cada comida

```dart
final pdf = pw.Document();
pdf.addPage(pw.Page(
  pageFormat: PdfPageFormat.a4,
  build: (context) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('REPORTE DE ALÉRGENOS - KECOMO', style: ...),
      pw.Text('Rango: $from hasta $to'),
      pw.Text('Paciente: $nombre $apellido ($categoria)'),
      pw.Divider(),
      pw.Text('Historial de Consumo:'),
      ...logs.map((l) => pw.Text('[${l.date}] ${l.mealType}: ${l.foodItemsText}')),
      if (reaction != null) pw.Text('! REACCIÓN: ${reaction.symptoms}', style: ...),
    ],
  ),
));
final file = File('$dir/KeComo_Reporte_${timestamp}.pdf');
await file.writeAsBytes(await pdf.save());
await Share.shareXFiles([XFile(file.path)], text: 'Reporte KeComo');
```

---

## 9. Widgets Compartidos

### 9.1. LiquidGlassCard (efecto glass morphism)

```dart
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final Color? borderColor;
  final double? tintAlpha;

  // BackdropFilter + ImageFilter.blur(sigmaX: 4, sigmaY: 4)
  // Container con color semi-transparente + borde
  // shape: RoundedCornerBorder radius 24
}
```

### 9.2. BottomNavBar

```dart
class KeComoNavigationBar extends ConsumerWidget {
  // 4 ítems: Hoy, Calendario, Resumen, Ajustes
  // Cada ítem: Icon + Text, glass effect background
  // Animación de opacidad al seleccionar
}
```

### 9.3. ProfileSwitcher

```dart
class ProfileSwitcher extends ConsumerWidget {
  // DropdownButton con perfiles, ícono persona/círculo con inicial
  // Opción "+ Añadir Familiar"
}
```

---

## 10. Tema / Colores

### Colores Light
```dart
Color(0xFF006D35),  // primary
Color(0xFF33BB67),  // primaryContainer
Color(0xFF3B6845),  // secondary
Color(0xFFC8E6C9),  // secondaryContainer
Color(0xFFA53843),  // tertiary
Color(0xFFFF7C84),  // tertiaryContainer
Color(0xFFFFFFFF),  // background
Color(0xFFFFFFFF),  // surface
Color(0xFFDCE5DA),  // surfaceVariant
Color(0xFF3D4A3E),  // onSurfaceVariant
Color(0xFFE8E8E8),  // outline
Color(0xFFC2C2C2),  // outlineVariant
```

### Colores Dark
```dart
Color(0xFF4ADE80),  // primary
Color(0xFF4ADE80),  // primaryContainer
Color(0xFF6B9B76),  // secondary
Color(0xFF1B3E24),  // secondaryContainer
Color(0xFFFF6B74),  // tertiary
Color(0xFF5C1D22),  // tertiaryContainer
Color(0xFF000000),  // background
Color(0xFF121212),  // surface
Color(0xFF1E1E1E),  // surfaceVariant
Color(0xFFE0E0E0),  // onSurface
Color(0xFFE0E0E0),  // onBackground
Color(0xFF9E9E9E),  // onSurfaceVariant
Color(0xFFFFFFFF),  // onPrimary
Color(0xFF2A2A2A),  // outline
Color(0xFF333333),  // outlineVariant
```

### Glass colors (calculados dinámicamente según brillo del fondo)
```dart
Color get glassTint => isLight ? Colors.white.withValues(alpha: 0.4) : Color(0xFF050505).withValues(alpha: 0.85);
Color get glassBorder => isLight ? Colors.white.withValues(alpha: 0.5) : Color(0xFF2A2A2A);
Color get chipBg => isLight ? Colors.white.withValues(alpha: 0.4) : Color(0xFF1A1A1A);
Color get chipBorder => isLight ? Colors.white.withValues(alpha: 0.6) : Color(0xFF3A3A3A);
Color get buttonBg => isLight ? Colors.white.withValues(alpha: 0.4) : Color(0xFF222222);
```

---

## 11. Gradiente de Fondo

```dart
final backgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: isDarkMode
    ? [Color(0xFF000000), Color(0xFF080808), Color(0xFF121212)]
    : [Color(0xFFFCFCFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
);
```

---

## 12. Transición de Pantallas

Equivalente Flutter del `AnimatedContent` de Compose:
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 400),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(scale: animation, child: child),
  ),
  child: KeyedSubtree(
    key: ValueKey(currentScreen),
    child: _buildScreen(currentScreen),
  ),
)
```

---

## 13. Iconos Custom (cámara, micrófono, upload)

El código Android usa `ImageVector.Builder` para crear 3 iconos SVG personalizados. En Flutter se implementan con `CustomPainter`:

```dart
class CameraIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Icon(Icons.camera_alt, size: 24);
}
```

Simplificación: usar iconos Material existentes que más se aproximen:
- `Icons.camera_alt` → PhotoCamera
- `Icons.mic` → Mic
- `Icons.upload_file` → FileUpload

---

## 14. Navegación State-based

```dart
// navigation_provider.dart
final currentScreenProvider = StateProvider<KeComoScreen>((ref) {
  return KeComoScreen.today;
});

// Función goToToday
ref.read(currentScreenProvider.notifier).state = KeComoScreen.today;
ref.read(selectedDateProvider.notifier).state = getTodayDateString();
```

En `app.dart`:
```dart
final screen = ref.watch(currentScreenProvider);
switch (screen) {
  case KeComoScreen.onboarding: return OnboardingScreen();
  case KeComoScreen.today: return TodayScreen();
  case KeComoScreen.calendar: return CalendarScreen();
  case KeComoScreen.summary: return SummaryScreen();
  case KeComoScreen.settings: return SettingsScreen();
  case KeComoScreen.exportPdf: return ExportPdfScreen();
}
```

---

## 15. Plan de Trabajo por Fases

### Fase 1: Proyecto Base + Dependencias
- [x] Crear proyecto Flutter `kekomo_flutter`
- [x] Configurar `pubspec.yaml` con dependencias
- [x] `flutter pub get` exitoso
- [ ] Verificar compilación base `flutter run`

### Fase 2: Data Layer (3 archivos nuevos)
- [ ] `lib/data/models/profile.dart`
- [ ] `lib/data/models/meal_log.dart`
- [ ] `lib/data/models/allergen.dart`
- [ ] `lib/data/models/reaction.dart`
- [ ] `lib/data/models/setting.dart`
- [ ] `lib/data/database_helper.dart` (singleton sqflite, create tables, defaults)
- [ ] `lib/data/kecomo_repository.dart` (todos los CRUD)

### Fase 3: Theme (2 archivos nuevos)
- [ ] `lib/theme/app_colors.dart` (constantes light/dark)
- [ ] `lib/theme/app_theme.dart` (ThemeData light + dark, typography)

### Fase 4: State Management (Providers)
- [ ] `lib/providers/navigation_provider.dart`
- [ ] `lib/providers/profile_provider.dart`
- [ ] `lib/providers/meal_log_provider.dart`
- [ ] `lib/providers/reaction_provider.dart`
- [ ] `lib/providers/allergen_provider.dart`
- [ ] `lib/providers/settings_provider.dart`
- [ ] `lib/providers/pdf_provider.dart`

### Fase 5: Widgets Compartidos (9 archivos)
- [ ] `lib/widgets/liquid_glass_card.dart`
- [ ] `lib/widgets/animated_dialog_content.dart`
- [ ] `lib/widgets/bottom_nav_bar.dart`
- [ ] `lib/widgets/profile_switcher.dart`
- [ ] `lib/widgets/key_chip.dart`
- [ ] `lib/widgets/settings_toggle_row.dart`
- [ ] `lib/widgets/settings_action_row.dart`
- [ ] `lib/widgets/option_toggle_row.dart`
- [ ] `lib/widgets/allergen_insight_item.dart`

### Fase 6: Screens (6 archivos)
- [ ] `lib/screens/onboarding_screen.dart`
- [ ] `lib/screens/today_screen.dart`
- [ ] `lib/screens/calendar_screen.dart`
- [ ] `lib/screens/summary_screen.dart`
- [ ] `lib/screens/settings_screen.dart`
- [ ] `lib/screens/export_pdf_screen.dart`

### Fase 7: Utilidades (3 archivos)
- [ ] `lib/utils/date_utils.dart`
- [ ] `lib/utils/pdf_generator.dart`
- [ ] `lib/utils/custom_icons.dart`

### Fase 8: Entry Points + Integración
- [ ] `lib/main.dart` (ProviderScope + runApp)
- [ ] `lib/app.dart` (MaterialApp con tema, navegación, scaffold)
- [ ] Prueba completa de compilación

### Fase 9: Testing
- [ ] Tests unitarios de modelos y base de datos
- [ ] Tests de providers
- [ ] Tests de widgets principales
- [ ] Prueba manual en dispositivo/emulador

---

## 16. Resumen del Esfuerzo

| Categoría | Cantidad de Archivos | Líneas Estimadas |
|---|---|---|
| Modelos | 5 | ~150 |
| Base de datos | 1 | ~200 |
| Repositorio | 1 | ~120 |
| Providers | 7 | ~350 |
| Theme | 2 | ~100 |
| Widgets | 9 | ~500 |
| Screens | 6 | ~1800 |
| Utils | 3 | ~200 |
| Entry points | 2 | ~80 |
| **Total** | **~36 archivos** | **~3500-4000 líneas** |

---

## 17. Notas Importantes

### Comportamiento offline
La app original es 100% offline (base de datos local). Flutter mantiene el mismo comportamiento con sqflite.

### Gradientes y efectos visuales
El efecto glass morphism de la app original usa la librería `kyant.backdrop`. En Flutter se logra con `BackdropFilter` + `ImageFilter.blur`, que funciona en Android e iOS sin dependencias externas.

### PDF Generation
La app original usa `android.graphics.pdf` (PDF nativo de Android). En Flutter se usa `dart:typed_data` + `package:pdf` que es cross-platform.

### Speech Recognition
Android usa `RecognizerIntent`. Flutter usa `speech_to_text` package que funciona en Android y iOS.

### Camera / Gallery
Android usa `ActivityResultContracts.GetContent()` / `TakePicture()`. Flutter usa `image_picker` package con `pickImage(source: ImageSource.camera/gallery)`.

---

## 18. Dependencias en pubspec.yaml (ya instaladas)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod: ^2.6.1
  sqflite: ^2.4.2
  path: ^1.9.1
  intl: ^0.20.2
  pdf: ^3.11.3
  image_picker: ^1.1.2
  speech_to_text: ^7.0.0
  path_provider: ^2.1.5
  share_plus: ^10.1.4
  cupertino_icons: ^1.0.8
  material_design_icons_flutter: ^7.0.7296
```

---

## 19. Referencia: Mapeo de Funciones Android → Dart

| Android (Kotlin) | Dart/Flutter |
|---|---|
| `SimpleDateFormat("yyyy-MM-dd")` | `DateFormat('yyyy-MM-dd')` |
| `Calendar.getInstance()` | `DateTime.now()` |
| `calendar.add(Calendar.DAY_OF_YEAR, -7)` | `DateTime.now().subtract(Duration(days: 7))` |
| `Toast.makeText(context, msg, length).show()` | `ScaffoldMessenger.of(context).showSnackBar()` |
| `BitmapFactory.decodeStream(inputStream)` | `Image.file(File(uri))` |
| `Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)` | `SpeechToText().listen(onResult: ...)` |
| `rememberLauncherForActivityResult(GetContent())` | `ImagePicker().pickImage(source: ImageSource.gallery)` |
| `PdfDocument()` + `Canvas` | `pw.Document()` + `pw.Page()` |
| `MaterialTheme.typography.titleMedium` | `Theme.of(context).textTheme.titleMedium` |
| `Modifier.fillMaxWidth().padding(16.dp)` | `SizedBox(width: double.infinity, child: Padding(...))` |
| `FlowRow` | `Wrap` |
| `AnimatedContent` | `AnimatedSwitcher` |
| `animateFloatAsState` | `AnimationController` + `Tween` |
| `derivedStateOf` | `ref.computed` o `useMemoized` |
| `RoundedCornerShape(24.dp)` | `BorderRadius.circular(24)` |
| `Spacer(modifier = Modifier.height(16.dp))` | `SizedBox(height: 16)` |

---

## 20. Conclusión

Este plan cubre la migración completa del 100% de la funcionalidad y diseño de la aplicación KeComo desde su versión Android nativa (Kotlin/Compose) a Flutter/Dart.

Cada fase está diseñada para ser implementada secuencialmente, comenzando por los cimientos (data layer) y avanzando hasta la interfaz de usuario y utilidades.

**Tiempo estimado:** 8-12 horas de desarrollo efectivo en Flutter.

**Próximo paso:** Comenzar con **Fase 2 - Data Layer**, creando modelos y base de datos.
