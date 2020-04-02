final float CONSTRUCTION_LOWER_LIMIT = 0.33;
final float CONSTRUCTION_UPPER_LIMIT = 0.46;

void generateA_Island(Zone zone) {
  randomSeed(zone.seed);
  noiseSeed(zone.seed);
  Zone[][] subZones = zone.subZones;  
  boolean[][] landMap = new boolean[16][16]; 
  String[][] typeMap = new String[16][16];

  // Initialize elevationMap and typeMap
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      // Set value in elevationMap
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));  
      if (getIslandElevation(zone, centerX, centerY) > CONSTRUCTION_LOWER_LIMIT
          && getIslandElevation(zone, centerX, centerY) < CONSTRUCTION_UPPER_LIMIT) {
        landMap[i][j] = true;
      }
      // Initialize value in typeMap
      typeMap[i][j] = "B_ISLAND";
    }
  }
  
  // Try placing some cities in spots that are higher than sand and not next to a previously placed city
  int cityCount = 0;
  int maxNumCities = (int) random(1, 3);
  int cityI = 0;
  int cityJ = 0;
  for (int tryIndex = 0; tryIndex < 600 && cityCount < maxNumCities; tryIndex++) {
    int i = (int) random(3, 12);
    int j = (int) random(3, 12);
    if (landMap[i][j]
        && landMap[i - 1][j - 1]
        && landMap[i][j - 1]
        && landMap[i + 1][j - 1]
        && landMap[i - 1][j]
        && landMap[i + 1][j]
        && landMap[i - 1][j + 1]
        && landMap[i][j + 1]
        && landMap[i + 1][j + 1]
        && landMap[i - 1][j - 1]
        && !typeMap[i][j - 1].equals("B_TOWN")
        && !typeMap[i + 1][j - 1].equals("B_TOWN")
        && !typeMap[i - 1][j].equals("B_TOWN")
        && !typeMap[i + 1][j].equals("B_TOWN")
        && !typeMap[i - 1][j + 1].equals("B_TOWN")
        && !typeMap[i][j + 1].equals("B_TOWN")
        && !typeMap[i + 1][j + 1].equals("B_TOWN")) {
      typeMap[i][j] = "B_TOWN";
      cityI = i;
      cityJ = j;
      cityCount++;
    }
  }
  
  // Create road system
  OutletsMatrix outletsMatrix = new OutletsMatrix();
  if (cityCount > 0) {
    createRoadSystem(landMap, cityI, cityJ, outletsMatrix);
  }
  
  // Instantiate subZones
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation = getIslandElevation(zone, centerX, centerY); 
      String type = typeMap[i][j];
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), type,
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
      subZones[i][j].elevation = elevation;
      subZones[i][j].outlets = outletsMatrix.matrix[i][j].outlets;
    }
  }
}

void generateA_Ocean(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "B_OCEAN",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
      subZones[i][j].elevation = 0;
    }
  }
}

void generateA_Space(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "B_SPACE",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
    }
  }
}
