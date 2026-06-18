/// Base de conocimientos de alérgenos comunes y sus productos asociados.
/// Fuente: alimentos.md + Palta y Cacao.
///
/// Se usa para:
/// - Mostrar alérgenos seleccionables en el onboarding y configuración
/// - Detectar alérgenos en comidas registradas (matching flexible)
const List<String> allergenCategories = [
  'Apio',
  'Cacao',
  'Trigo',
  'Huevo',
  'Leche',
  'Mani',
  'Mariscos',
  'Mostaza',
  'Nuez',
  'Palta',
  'Pescado',
  'Sesamo',
  'Soya',
  'Sulfitos',
];

const Map<String, List<String>> allergenKnowledgeBase = {
  'Apio': [
    'apio', 'cazuela', 'caldo de pollo', 'caldo de vacuno',
    'caldo de verduras', 'sopa', 'sopas deshidratadas', 'sopa deshidratada',
    'cubo de caldo', 'cubo de caldo concentrado', 'cubos de caldo',
    'ensalada', 'pasta de curry', 'condimento', 'condimentos',
    'salsa de apio', 'pure de apio', 'puré de apio',
  ],
  'Cacao': [
    'cacao', 'cacaos', 'cocoa', 'chocolate', 'chocolates',
    'chocolate amargo', 'chocolate blanco', 'chocolate con leche',
    'chocolate en polvo', 'chocolate rallado', 'chocolate caliente',
    'chocolate a la taza', 'pasta de cacao', 'manteca de cacao',
    'nibs de cacao', 'nibs', 'cobertura de chocolate', 'cobertura',
    'bombon', 'bombón', 'bombones', 'trufa', 'trufas',
    'brownie', 'brownies', 'torta de chocolate', 'queque de chocolate',
    'pan de chocolate', 'galleta de chocolate', 'galletas de chocolate',
    'muffin de chocolate', 'croissant de chocolate', 'brazo de reina',
    'brazo de gin', 'calzones rotos', 'milkshake de chocolate',
    'mousse de chocolate', 'fondant', 'volcan de chocolate', 'volcán',
    'souffle de chocolate', 'salsa de chocolate', 'nutella',
    'helado de chocolate', 'milo', 'nesquik', 'toddy', 'cola cao',
    'chocolate en barra', 'tableta de chocolate',
  ],
  'Trigo': [
    'pan', 'marraqueta', 'hallulla', 'molde', 'pasta', 'fideos',
    'sopaipilla', 'sopaipillas', 'mote', 'harina de trigo', 'harina',
    'cuscus', 'cuscús', 'galleta', 'galletas', 'pastel', 'pasteles',
    'cerveza', 'empanada de pino', 'empanadas de pino', 'pizza',
    'rebozado', 'rebozados', 'pescado frito', 'salsa de soya',
    'cubo de caldo', 'cubos de caldo', 'avena', 'cebada', 'centeno',
    'espelta', 'masa de pizza', 'trigo', 'gluten', 'cereal', 'cereales',
    'pan rallado', 'tortilla de trigo', 'tostada', 'tostadas',
    'baguette', 'croissant', 'empanada', 'empanadas',
  ],
  'Huevo': [
    'merengue', 'mayonesa', 'flan', 'leche asada', 'albondiga',
    'albóndiga', 'albondigas', 'albóndigas', 'pastel de carne',
    'empanizado', 'empanizados', 'pan de huevo', 'pino de empanada',
    'pino', 'producto horneado', 'productos horneados', 'aderezo cesar',
    'aderezo', 'huevo entero', 'huevo', 'huevos', 'clara', 'claras',
    'yema', 'yemas', 'souffle', 'soufflé', 'batido', 'batidos',
    'reposteria', 'repostería', 'queque', 'torta', 'panqueque',
  ],
  'Leche': [
    'queso', 'mantequilla', 'yogurt', 'yogur', 'crema de leche',
    'leche condensada', 'caseina', 'caseína', 'caseinato', 'caseinatos',
    'suero de leche', 'suero', 'pastel de choclo', 'humita', 'humitas',
    'chupe de jaiba', 'helado', 'helados de crema', 'postre lacteo',
    'postres lacteos', 'vienesa', 'vienesas', 'pate', 'paté',
    'lactosa', 'leche', 'quesillo', 'queso crema', 'crema',
    'requeson', 'requesón', 'ricotta', 'mozzarella', 'parmesano',
    'cheddar', 'manteca', 'leche descremada', 'leche entera',
    'leche evaporada', 'leche en polvo',
  ],
  'Mani': [
    'mantequilla de mani', 'mantequilla de maní', 'harina de mani',
    'harina de maní', 'aceite de mani', 'aceite de maní', 'mani',
    'maní', 'cacahuate', 'cacahuates', 'cacahuete', 'cacahuetes',
    'frutos secos', 'mezcla de frutos secos', 'snack', 'snacks',
    'salsa de mole', 'mole', 'rollito primavera', 'rollitos primavera',
    'chili', 'mazapan', 'mazapán', 'turron', 'turrón',
  ],
  'Mariscos': [
    'camaron', 'camarón', 'camarones', 'jaiba', 'centolla', 'langosta',
    'chorito', 'choritos', 'almeja', 'almejas', 'ostion', 'ostión',
    'ostiones', 'ostra', 'ostras', 'macha', 'machas', 'pulpo',
    'calamar', 'calamares', 'chupe de mariscos', 'chupe',
    'ceviche', 'curanto', 'pulmay', 'paella', 'langostino',
    'langostinos', 'caldo concentrado', 'marisco', 'mariscos',
    'crustaceo', 'crustáceo', 'crustaceos', 'crustáceos', 'molusco',
    'moluscos', 'gamba', 'gambas',
  ],
  'Mostaza': [
    'mostaza', 'semilla de mostaza', 'semillas de mostaza',
    'mostaza preparada', 'mayonesa industrial', 'aderezo de ensalada',
    'aderezo', 'marinado', 'marinados', 'pasta de curry',
    'pan especial', 'curry',
  ],
  'Nuez': [
    'nuez', 'nueces', 'almendra', 'almendras', 'avellana', 'avellanas',
    'pistacho', 'pistachos', 'castana', 'castaña', 'castanas', 'castañas',
    'anacardo', 'anacardos', 'pesto', 'gianduja', 'prieta nogada',
    'nogada', 'aceite de nuez', 'mazapan', 'mazapán',
    'pan integral', 'panes integrales', 'semillas', 'mantequilla de mani',
    'mantequilla de maní', 'mezcla de frutos secos', 'fruto seco',
    'frutos secos', 'nueces de macadamia', 'macadamia', 'pecan', 'pecán',
    'pecanas', 'pecanas',
  ],
  'Palta': [
    'palta', 'paltas', 'aguacate', 'avocado', 'avocados',
    'guacamole', 'completo', 'completo italiano', 'completo hot dog',
    'italiana', 'hot dog', 'sushi', 'rolls de palta', 'ceviche',
    'palta a la chilena', 'palta rellena', 'pasta de palta',
    'dip de palta', 'mayonesa de palta', 'aceite de palta',
    'helado de palta', 'mousse de palta', 'torta de palta',
    'cheesecake de palta', 'smoothie de palta', 'pulpa de palta',
    'palta congelada',
  ],
  'Pescado': [
    'merluza', 'salmon', 'salmón', 'congrio', 'congrio', 'atun', 'atún',
    'anchoa', 'anchoas', 'salsa worcestershire', 'salsa inglesa',
    'salsa cesar', 'salsa césar', 'surimi', 'caldo de pescado', 'sushi',
    'pescado', 'pescado fresco', 'pescado frito', 'enlatado', 'enlatados',
    'jurel', 'sardina', 'sardinas', 'trucha', 'atun en conserva',
    'atún en conserva', 'bacalao', 'corvina', 'lenguado', 'pejerey',
    'rollitos de pescado', 'filete de pescado',
  ],
  'Sesamo': [
    'sesamo', 'sésamo', 'ajonjoli', 'ajonjolí', 'semilla de sesamo',
    'semillas de sesamo', 'semillas de sésamo', 'tahini', 'tahine',
    'halva', 'gomasio', 'pan con sesamo', 'colines', 'comida oriental',
    'aceite de sesamo', 'aceite de sésamo', 'pasta de sesamo',
    'pasta de sésamo', 'gomashi', 'gomashio',
  ],
  'Soya': [
    'salsa de soya', 'tofu', 'tempeh', 'edamame', 'miso', 'lecitina de soya',
    'lecitina', 'proteina vegetal texturizada', 'proteina vegetal',
    'leche de soya', 'leche de soja', 'yogurt de soya', 'yogurt de soja',
    'embutido', 'embutidos', 'cecina', 'cecinas', 'poroto de soya',
    'porotos de soya', 'poroto de soja', 'aceite de soya', 'aceite de soja',
    'soya', 'soja', 'poroto', 'natto', 'edamame',
  ],
  'Sulfitos': [
    'vino', 'cerveza', 'vinagre', 'chancaca', 'almibar', 'almíbar',
    'huesillo', 'huesillos', 'durazno deshidratado', 'jugo de limon',
    'jugo de limón', 'embutido procesado', 'papa deshidratada',
    'fruta seca', 'frutas secas', 'conserva', 'conservas', 'sulfito',
    'sulfitos', 'aditivo', 'aditivos', 'mosto', 'sidra',
  ],
};

/// Normaliza un texto: lowercase y sin acentos.
String normalizeAllergenText(String s) {
  return s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');
}

/// Verifica si una categoría de la base de conocimientos coincide
/// con el alérgeno del perfil (matching flexible bidireccional).
bool categoryMatchesProfileAllergen(String categoryKey, String profileAllergen) {
  final catNorm = normalizeAllergenText(categoryKey);
  final allergenNorm = normalizeAllergenText(profileAllergen);
  if (catNorm.isEmpty || allergenNorm.isEmpty) return false;
  return catNorm.contains(allergenNorm) || allergenNorm.contains(catNorm);
}

/// Retorna la lista de categorías de la base que coinciden con el
/// alérgeno del perfil (matching flexible).
List<String> findMatchingCategories(String profileAllergen) {
  return allergenCategories
      .where((cat) => categoryMatchesProfileAllergen(cat, profileAllergen))
      .toList();
}

/// Retorna la lista de productos asociados a las categorías
/// que coinciden con el alérgeno del perfil.
List<String> productsForProfileAllergen(String profileAllergen) {
  final cats = findMatchingCategories(profileAllergen);
  final products = <String>{};
  for (final cat in cats) {
    products.addAll(allergenKnowledgeBase[cat] ?? const []);
  }
  return products.toList();
}

/// Normaliza un nombre de alérgeno al nombre canónico de las 14 categorías.
/// Si no coincide con ninguna, devuelve el nombre original.
String normalizeAllergenName(String name) {
  final lower = normalizeAllergenText(name);
  for (final cat in allergenCategories) {
    if (categoryMatchesProfileAllergen(cat, lower)) {
      return cat;
    }
  }
  return name;
}
