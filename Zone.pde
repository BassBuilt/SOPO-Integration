class Zone {
  Zone superZone;
  int seed;
  String type;
  Zone[][] subZones;
  boolean isGenerated; 
  int x, y, depth;
 
  boolean[] outlets;
  float elevation;
  
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
      if (islandMap[i][j]) {
        type = "A_ISLAND";
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

int typeToColor(String type, float elevation) {
  switch (type) {
    case "A_SPACE":
    case "B_SPACE":
    case "C_SPACE":
    case "D_SPACE":
      return color(20);  
    case "A_ISLAND":
      return #bfab77;  
    case "B_ISLAND":
    case "C_ISLAND":
    case "D_ISLAND":
      if (elevation < 0.09) {
        return #5f9da0;
      } else if (elevation < 0.15) {
        return #7fbdc0;
      } else if (elevation < 0.255) {
        return #9fdde0;
      }
      float waterLevel = map(cos(frameCount / 40.0), -1, 1, 0.255, 0.26);
      if (elevation < waterLevel) {
        return #9fdde0;
      }
      float wetSandLevel = max(waterLevel, map(frameCount % (TWO_PI * 40), TWO_PI * 40, 0, 0.257, 0.26));      
      if (elevation < wetSandLevel) {
        return #efeebd;
      } else if (elevation < 0.3) {
        return #fffecd;
      } else if (elevation < 0.36) {
        return #cab782;   
      } else if (elevation < 0.41) {
        return #bfab77;
      } else if (elevation < 0.5) {
        return #baa772; 
      } else {
        return #f7fae2;       
      }        
        /**
      } else if (elevation < 0.27) {
        return #fff59d;
      } else if (elevation < 0.36) {
        return #b7ca82;   
      } else if (elevation < 0.41) {
        return #abbf77;
      } else if (elevation < 0.5) {
        return #a7ba72;      
      } else {
        return #f7fae2;        
      }*/
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
      return #ffccbc;
    case "D_ASPHALT":
      return #cdcdcd;
      //return #bdbdbd;
    case "D_STONE":
      return #424242;
    case "D_WOOD":
      return #b0997d;
    case "D_SOIL":
      return #857464;
    case "D_FLOWER":
      return #ffccbc;
    default:
      return #000000;
  }
}
