void generateC_Island(Zone zone) {
  randomSeed(zone.seed);  
  Zone[][] subZones = zone.subZones;  
  
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      float centerX = zone.x + (i) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation = getIslandElevation(zone.superZone.superZone, centerX, centerY);    
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "D_ISLAND",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);   
      subZones[i][j].elevation = elevation;
      subZones[i][j].biome = zone.biome;
    }
  }
}

void generateC_Road(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  String[][] typeMap = new String[16][16];

  int innerMargin = 6;
  int outerMargin = 9;
  // Initialize as no-way-through clover
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      if ((i < innerMargin || i > outerMargin) && (j < innerMargin || j > outerMargin)) {
        typeMap[i][j] = "D_ASPHALT";
      } else {
        typeMap[i][j] = "D_ISLAND";       
      }
    }
  }
    
  // Fill back midlines based on outlets (guarantee roads aren't broken in the middle)
  int totalCount;
  totalCount = (zone.outlets[0] ? 1 : 0) + (zone.outlets[1] ? 1 : 0) + (zone.outlets[2] ? 1 : 0) + (zone.outlets[3] ? 1 : 0);
  int count;
  // Left
  count = (zone.outlets[1] ? 1 : 0) + (zone.outlets[2] ? 1 : 0) + (zone.outlets[3] ? 1 : 0);
  if (count > 1 || (totalCount == 1 && !zone.outlets[0])) {
    for (int i = 0; i < innerMargin; i++) {
      for (int j = innerMargin; j < outerMargin + 1; j++) {
        typeMap[i][j] = "D_ASPHALT";        
      }
    }  
  }
  // Right
  count = (zone.outlets[0] ? 1 : 0) + (zone.outlets[2] ? 1 : 0) + (zone.outlets[3] ? 1 : 0);
  if (count > 1 || (totalCount == 1 && !zone.outlets[1])) {
    for (int i = outerMargin + 1; i < 16; i++) {
      for (int j = innerMargin; j < outerMargin + 1; j++) {
        typeMap[i][j] = "D_ASPHALT";        
      }
    }  
  }
  // Up
  count = (zone.outlets[0] ? 1 : 0) + (zone.outlets[1] ? 1 : 0) + (zone.outlets[3] ? 1 : 0);
  if (count > 1 || (totalCount == 1 && !zone.outlets[2])) {
    for (int i = innerMargin; i < outerMargin + 1; i++) {
      for (int j = 0; j < innerMargin; j++) {
        typeMap[i][j] = "D_ASPHALT";        
      }
    }  
  }
  
  // Down
  count = (zone.outlets[0] ? 1 : 0) + (zone.outlets[1] ? 1 : 0) + (zone.outlets[2] ? 1 : 0);
  if (count > 1 || (totalCount == 1 && !zone.outlets[3])) {
    for (int i = innerMargin; i < outerMargin + 1; i++) {
      for (int j = outerMargin + 1; j < 16; j++) {
        typeMap[i][j] = "D_ASPHALT";        
      }
    }  
  }
  
  // Finally, instantiate
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation = getIslandElevation(zone.superZone.superZone, centerX, centerY);    
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), typeMap[i][j],
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);   
      subZones[i][j].elevation = elevation;
      subZones[i][j].biome = zone.biome;
    }
  }  
}

void generateC_Building(Zone zone) {
  randomSeed(zone.seed);  
  Zone[][] subZones = zone.subZones;  
  String[][] typeMap = new String[16][16];

  // Initialize all to island
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {   
      typeMap[i][j] = "D_ISLAND";
    }
  }

  // Start by creating entrance road (will largely get drawn over)
  // Left
  if (zone.outlets[0]) {
    for (int i = 0; i < 8; i++) {
      typeMap[i][7] = "D_ASPHALT";   
      typeMap[i][8] = "D_ASPHALT"; 
    }
  }
  // Right
  if (zone.outlets[1]) {
    for (int i = 8; i < 16; i++) {
      typeMap[i][7] =  "D_ASPHALT";   
      typeMap[i][8] =  "D_ASPHALT"; 
    }
  }  
  // Up
  if (zone.outlets[2]) {
    for (int j = 0; j < 8; j++) {
      typeMap[7][j] = "D_ASPHALT";   
      typeMap[8][j] = "D_ASPHALT"; 
    }
  }
  // Down
  if (zone.outlets[3]) {
    for (int j = 8; j < 16; j++) {
      typeMap[7][j] = "D_ASPHALT";   
      typeMap[8][j] = "D_ASPHALT"; 
    }
  }

  // Create basic building structure
  if (random(1) < 0.9) {
    // Basic rectangular building
    int nearI = (int) random(1, 5);
    int farI = (int) random(12, 15);
    int nearJ = (int) random(1, 5);
    int farJ = (int) random(12, 15);
    for (int i = nearI; i <= farI; i++) {
      for (int j = nearJ; j <= farJ; j++) { 
        if (i == nearI || i == farI || j == nearJ || j == farJ) {
          typeMap[i][j] = "D_STONE";        
        } else {
          typeMap[i][j] = "D_WOOD";        
        }
      }
    }
  } else {
    // Basic circular building  
    // Start by placing floor
    int radius = 7;
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 16; j++) { 
        if (sqrt(pow(i - 8, 2) + pow(j - 8, 2)) < radius) {
          typeMap[i][j] = "D_WOOD";       
        }
      }
    } 
    // All peripheral wood turns to stone wall
    for (int i = 1; i < 15; i++) {
      for (int j = 1; j < 15; j++) {
        if (typeMap[i][j].equals("D_WOOD")) {
          boolean isWall = false;
          for (int subI = -1; subI <= 1 && !isWall; subI ++) {
            for (int subJ = -1; subJ <= 1 && !isWall; subJ++) {
              if (typeMap[i + subI][j + subJ].equals("D_ISLAND")) {
                isWall = true;
              }
            }
          }
          if (isWall) {
            typeMap[i][j] = "D_STONE";             
          }
        }
      }
    }        
  }
  
  // Finally, instantiate
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation = getIslandElevation(zone.superZone.superZone, centerX, centerY);    
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), typeMap[i][j],
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);   
      subZones[i][j].elevation = elevation;
      subZones[i][j].biome = zone.biome;
    }
  } 
  
  // Create 1 - 2 agents in this building
  ArrayList<PVector> openPositions = new ArrayList<PVector>();
  for (int i = 2; i < 14; i++) {
    for (int j = 2; j < 14; j++) { 
      if (typeMap[i][j].equals("D_WOOD")) {
        openPositions.add(new PVector(i, j));
      }
    }
  }
  int numAgents = (int) random(1, 3);
  for (int agentIndex = 0; agentIndex < numAgents; agentIndex++) {
    PVector pos = openPositions.get((int) random(0, openPositions.size()));
    agents.add(new Agent((int) random(MAX_INT), zone.x + (int) pos.x, zone.y + (int) pos.y));
    // Area within radius of newly placed agent not an option for new agents
    int radius = 2;
    for (int i = -radius; i <= radius; i++) {
      for (int j = -radius; j <= radius; j++) {
        for (int neighborOptionIndex = 0; neighborOptionIndex < openPositions.size(); neighborOptionIndex++) {
          PVector openPosition = openPositions.get(neighborOptionIndex);
          if (openPosition.x == pos.x + i && openPosition.y == pos.y + j) {
            openPositions.remove(openPosition);
          }
        }
      }  
    }    
  }
}

void generateC_Field(Zone zone) {
  randomSeed(zone.seed);  
  Zone[][] subZones = zone.subZones;  
  String[][] typeMap = new String[16][16];

  // Initialize to soil
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) { 
      typeMap[i][j] = "D_SOIL";
    }
  }
  // Cutout a margin on edges with no neighboring field
  // Left margin
  if (!zone.outlets[0]) {
    int i = 0;
    for (int j = 0; j < 16; j++) {
      typeMap[i][j] = "D_ISLAND";      
    }
  }
  // Right margin
  if (!zone.outlets[1]) {
    int i = 15;
    for (int j = 0; j < 16; j++) {
      typeMap[i][j] = "D_ISLAND";      
    }
  }  
  // Upper margin
  if (!zone.outlets[2]) {
    int j = 0;
    for (int i = 0; i < 16; i++) {
      typeMap[i][j] = "D_ISLAND";      
    }
  }  
  // Lower margin - two thick to satisfy crop spacing
  if (!zone.outlets[3]) {
    for (int i = 0; i < 16; i++) {
      for (int j = 14; j < 16; j++) {
        typeMap[i][j] = "D_ISLAND";      
      }
    }
  }
  // Plant crops
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) { 
      // Check that neighbors are not grass (soil buffer) and is not corner
      // Also, randomly disallow a few plants
      boolean goodToPlant = (j % 2 == 0) && (random(1) < 0.95)
        && !(i == 0 && j == 0)
        && !(i == 15 && j == 0) 
        && !(i == 0 && j == 14)
        && !(i == 0 && j == 15)
        && !(i == 15 && j == 14)
        && !(i == 15 && j == 15);
      for (int subI = -1; subI <= 1 && goodToPlant; subI ++) {
        for (int subJ = -1; subJ <= 1 && goodToPlant; subJ++) {
          // Neighbor out of bounds -> this block on edge
          // Plants can grow up to edge, expecting matching neighbor
          if (i + subI < 0 || i + subI > 15 || j + subJ < 0 || j + subJ > 15) {
            continue;
          }                   
          if (typeMap[i + subI][j + subJ].equals("D_ISLAND")) {
            goodToPlant = false;
          }
        }
      }
      if (goodToPlant) {
        typeMap[i][j] = "D_FLOWER";           
      }
    }
  }
  
  // Finally, instantiate
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation = getIslandElevation(zone.superZone.superZone, centerX, centerY);    
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), typeMap[i][j],
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);   
      subZones[i][j].elevation = elevation;
      subZones[i][j].biome = zone.biome;
    }
  }
}

void generateC_Ocean(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "D_OCEAN",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
    }
  } 
}

void generateC_Space(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "D_SPACE",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
    }
  }
}
