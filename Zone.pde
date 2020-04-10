class Zone {
  Zone superZone;
  int seed;
  String type;
  Zone[][] subZones;
  boolean isGenerated; 
  int x, y, depth;
 
  boolean[] outlets;
  float elevation;
  String biome;
  
  Zone(Zone superZone, int seed, String type, int x, int y, int depth) {
    this.superZone = superZone;
    this.seed = seed;
    this.type = type;
    this.x = x;
    this.y = y;
    this.depth = depth;
    
    subZones = new Zone[16][16];
    isGenerated = false;
  }
  
  void generate() {
    switch(type) {
      case "WORLD":
        generateWorld(this);
        break;
      case "A_SPACE":
        generateA_Space(this);
        break;
      case "B_SPACE":
        generateB_Space(this);
        break;
      case "C_SPACE":
        generateC_Space(this);
        break;
      case "A_ISLAND":
        generateA_Island(this);
        break;
      case "A_OCEAN":
        generateA_Ocean(this);
        break;
      case "B_ISLAND":
        generateB_Island(this);
        break;
      case "B_TOWN":
        generateB_Town(this);
        break;
      case "B_OCEAN":
        generateB_Ocean(this);
        break;
      case "C_ISLAND":
        generateC_Island(this);
        break;
      case "C_ROAD":
        generateC_Road(this);
        break;
      case "C_BUILDING":
        generateC_Building(this);
        break;
      case "C_FIELD":
        generateC_Field(this);
        break;
      case "C_OCEAN":
        generateC_Ocean(this);
        break;
    }
    isGenerated = true;
  }
}

void generateWorld(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  boolean[][] islandMap = new boolean[16][16];
  int attempts = (int) random(16, 24);
  for (int i = 0; i < attempts; i++) {
    int x = (int) random(3, 13);
    int y = (int) random(3, 13);
    if (random(1) < .5
        && !islandMap[x - 1][y - 1]
        && !islandMap[x][y - 1]
        && !islandMap[x + 1][y - 1]
        && !islandMap[x - 1][y]
        && !islandMap[x + 1][y]
        && !islandMap[x - 1][y + 1]
        && !islandMap[x][y + 1]
        && !islandMap[x + 1][y + 1])
      islandMap[x][y] = true;
  }
  
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      String type;
      String biome = null;
      if (islandMap[i][j]) {
        type = "A_ISLAND";
        noiseSeed(zone.seed * 473);
        float biomeValue = noise(i / 8.0, j / 8.0);
        if (biomeValue < 0.3) {
          biome = "REDLAND";
        } else if (biomeValue < 0.5) {
          biome = "SAVANNA";
        } else {
          biome = "GRASSLAND";
        }
      } else {
        type = "A_OCEAN";
      }
      if (sqrt(pow(i - 8, 2) + pow(j - 8, 2)) >= 7) {
        type = "A_OCEAN";        
      }
      if (sqrt(pow(i - 8, 2) + pow(j - 8, 2)) >= 8) {
        type = "A_SPACE";        
      }
      
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), type,
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
      subZones[i][j].biome = biome;
      subZones[i][j].generate();
    }
  }
}

Zone findZone(int x, int y, int depth) {
  if (x < 0 || x >= pow(16, MAX_DEPTH) || y < 0 || y >= pow(16, MAX_DEPTH) || depth < 0 || depth > MAX_DEPTH) {
    return null;
  }
  return recursiveFindZone(world, x, y, depth);
}

Zone recursiveFindZone(Zone zone, int x, int y, int depth) {
  // Base case
  if (zone.x == x && zone.y == y && zone.depth == depth) {
    return zone;
  }
  if (zone.depth >= MAX_DEPTH) {
    return null;
  }
  // Recursive step
  int i = (x - zone.x) / (int) pow(16, MAX_DEPTH - (zone.depth + 1));
  int j = (y - zone.y) / (int) pow(16, MAX_DEPTH - (zone.depth + 1));
  if (!zone.isGenerated) {
    zone.generate();
  }
  return recursiveFindZone(zone.subZones[i][j], x, y, depth);
}

int getZoneColor(Zone zone) {
  String type = zone.type;
  float elevation = zone.elevation;
  String biome = zone.biome;
  switch (type) {
    case "A_SPACE":
    case "B_SPACE":
    case "C_SPACE":
    case "D_SPACE":
      return color(20);  
    case "A_ISLAND":
      if (biome.equals("REDLAND"))
        return #db987a;  
      if (biome.equals("SAVANNA"))
        return #bfab77;  
      if (biome.equals("GRASSLAND"))
        return #688660;
    case "B_ISLAND":
    case "C_ISLAND":
    case "D_ISLAND":
      if (elevation < 0.09)
        return #5f9da0;
      if (elevation < 0.15)
        return #7fbdc0;
      if (elevation < 0.255)
        return #9fdde0;
      float waterLevel = map(cos(frameCount / 40.0), -1, 1, 0.255, 0.26);
      if (elevation < waterLevel)
        return #9fdde0;
      float wetSandLevel = max(waterLevel, map(frameCount % (TWO_PI * 40), TWO_PI * 40, 0, 0.257, 0.26)); 
      if (biome.equals("REDLAND")) {   
        // Wet sand
        if (elevation < wetSandLevel)
          return #efce9d;
        // Dry sand
        if (elevation < 0.27)
          return #ffdead;
        // Low ground
        if (elevation < 0.36)
          return #f29b80;   
        // Middle ground
        if (elevation < 0.41)
          return #db987a;
        // High ground
        if (elevation < 0.5) 
          return #c49474; 
        // Snow
        return #f7fae2;    
      }
      if (biome.equals("SAVANNA")) {  
        // Wet sand
        if (elevation < wetSandLevel)
          return #efeebd;
        // Dry sand
        if (elevation < 0.28)
          return #fffecd;
        // Low ground
        if (elevation < 0.36)
          return #cab782;
        // Middle ground
        if (elevation < 0.41)
          return #bfab77;
        // High ground
        if (elevation < 0.5) 
          return #baa772;
        // Snow
        return #f7fae4;    
      }
      if (biome.equals("GRASSLAND")) {
        // Wet sand
        if (elevation < wetSandLevel)
          return #efdead;
        // Dry sand
        if (elevation < 0.28)
          return #ffeebd;
        // Low ground
        if (elevation < 0.36)
          return #81a674;  
        // Middle ground
        if (elevation < 0.41)
          return #799d6c;
        // High ground
        if (elevation < 0.5) 
          return #688660;
        // Snow
        return #f7fae4;    
      }
    case "A_OCEAN":
    case "B_OCEAN":
    case "C_OCEAN":
    case "D_OCEAN":
      return #5f9da0;
    case "B_TOWN":
      return #666666;
    case "C_ROAD":
      return #bdbdbd;
    case "C_BUILDING":
      return #757575;
    case "C_FIELD":
      if (biome.equals("REDLAND"))
        return #ffffe0;
      if (biome.equals("SAVANNA"))
        return #ffccbc;
      if (biome.equals("GRASSLAND"))
        return #ecf29b;
    case "D_ASPHALT":
      return #cdcdcd;
      //return #bdbdbd;
    case "D_STONE":
      return #424242;
    case "D_WOOD":
      return #b0997d;
    case "D_SOIL":
      if (biome.equals("REDLAND"))
        return #a86b59;
      if (biome.equals("SAVANNA"))
        return #857464;
      if (biome.equals("GRASSLAND"))
        return #5e5445;      
    case "D_FLOWER":
      if (biome.equals("REDLAND"))
        return #ffffe0;
      if (biome.equals("SAVANNA"))
        return #ffccbc;
      if (biome.equals("GRASSLAND"))
        return #ecf29b;  
    default:
      return #000000;
  }
}
