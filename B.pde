void generateB_Island(Zone zone) {
  randomSeed(zone.seed);  
  Zone[][] subZones = zone.subZones;  
  String[][] typeMap = new String[16][16];
  OutletsMatrix outletsMatrix = new OutletsMatrix();
  float[][] elevationsMap = new float[16][16];
  
  // Initialize elevationsMap
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      elevationsMap[i][j] = getIslandElevation(zone.superZone, centerX, centerY);
    }    
  }  
  
  // Initialize to island
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      typeMap[i][j] = "C_ISLAND";
    }    
  }
 
  // Create roads if roads flows in / through this zone
  boolean hasOutlet = false;
  for (boolean outlet : zone.outlets) {
    if (outlet) {
      hasOutlet = true;
    }
  }  
  if (hasOutlet) {
    // Outlet to the left
    if (zone.outlets[0]) {
      int j = 8;
      for (int i = 0; i < 9; i++) {
        if (elevationsMap[i][j] > CONSTRUCTION_LOWER_LIMIT && elevationsMap[i][j] < CONSTRUCTION_UPPER_LIMIT) {
          typeMap[i][j] = "C_ROAD";   
        }      
      }
    }
    // Outlet to the right
    if (zone.outlets[1]) {
      int j = 8;
      for (int i = 15; i >= 8; i--) {
        if (elevationsMap[i][j] > CONSTRUCTION_LOWER_LIMIT && elevationsMap[i][j] < CONSTRUCTION_UPPER_LIMIT) {
          typeMap[i][j] = "C_ROAD";   
        }       
      }      
    }
    // Outlet above
    if (zone.outlets[2]) {
      int i = 8;
      for (int j = 0; j < 9; j++) {
        if (elevationsMap[i][j] > CONSTRUCTION_LOWER_LIMIT && elevationsMap[i][j] < CONSTRUCTION_UPPER_LIMIT) {
          typeMap[i][j] = "C_ROAD";   
        }        
      }      
    }
    // Outlet below
    if (zone.outlets[3]) {
      int i = 8;
      for (int j = 15; j >= 8; j--) {
        if (elevationsMap[i][j] > CONSTRUCTION_LOWER_LIMIT && elevationsMap[i][j] < CONSTRUCTION_UPPER_LIMIT) {
          typeMap[i][j] = "C_ROAD";   
        }       
      }           
    } 
  }

  // Add strech of shoreline road if it passes through here
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      // Needs to find if construction transition point falls through each subZone, so:
      // Try top-left to bottom-right corner scan first
      float centerX = zone.x + (i + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation1 = getIslandElevation(zone.superZone, centerX, centerY);
      centerX = zone.x + (i + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      centerY = zone.y + (j + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation2 = getIslandElevation(zone.superZone, centerX, centerY);
      if (elevation1 > CONSTRUCTION_LOWER_LIMIT ^ elevation2 > CONSTRUCTION_LOWER_LIMIT) {
        typeMap[i][j] = "C_ROAD";         
      }
      // Try top-right to bottom-left corner scan first
      centerX = zone.x + (i + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      centerY = zone.y + (j + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      elevation1 = getIslandElevation(zone.superZone, centerX, centerY);
      centerX = zone.x + (i + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      centerY = zone.y + (j + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      elevation2 = getIslandElevation(zone.superZone, centerX, centerY);
      if (elevation1 > CONSTRUCTION_LOWER_LIMIT ^ elevation2 > CONSTRUCTION_LOWER_LIMIT) {
        typeMap[i][j] = "C_ROAD";         
      }     
    }
  }
  
  // Find outlets for roads
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      if (typeMap[i][j].equals("C_ROAD")) {
        // Left
        if (i == 0 || typeMap[i - 1][j].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[0] = true;          
        }        
        // Right
        if (i == 15 || typeMap[i + 1][j].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[1] = true;          
        }        
        // Up
        if (j == 0 || typeMap[i][j - 1].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[2] = true;          
        }        
        // Down
        if (j == 15 || typeMap[i][j + 1].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[3] = true;          
        }
      }
    }
  }
  
  // Try to add some farms
  for (int attempt = 0; attempt < 16; attempt++) {
    int i = (int) random(2, 14);
    int j = (int) random(2, 14);    
    if (typeMap[i][j].equals("C_ISLAND")) {
      boolean byRoad = typeMap[i - 1][j].equals("C_ROAD")
        || typeMap[i + 1][j].equals("C_ROAD")
        || typeMap[i][j - 1].equals("C_ROAD")
        || typeMap[i][j + 1].equals("C_ROAD");
      if (byRoad) {
        typeMap[i][j] = "C_BUILDING";
        // Choose entrance
        ArrayList<Integer> entrances = new ArrayList<Integer>();
        // Check left
        if (typeMap[i - 1][j].equals("C_ROAD")) {
          entrances.add(0);
        }
        // Check right
        if (typeMap[i + 1][j].equals("C_ROAD")) {
          entrances.add(1);
        }
        // Check above
        if (typeMap[i][j - 1].equals("C_ROAD")) {
          entrances.add(2);
        }
        // Check below
        if (typeMap[i][j + 1].equals("C_ROAD")) {
          entrances.add(3);
        }  
        int entrance = entrances.get((int) random(entrances.size()));
        outletsMatrix.matrix[i][j].outlets[entrance] = true;
      }
    }
  }
  
  // Grow some fields
  for (int attempt = 0; attempt < 280; attempt++) {
    int i = (int) random(2, 14);
    int j = (int) random(2, 14);    
    if (typeMap[i][j].equals("C_ISLAND")
        && elevationsMap[i][j] > CONSTRUCTION_LOWER_LIMIT - 0.02
        && elevationsMap[i][j] < CONSTRUCTION_UPPER_LIMIT
        && (typeMap[i - 1][j].equals("C_BUILDING")
        || typeMap[i + 1][j].equals("C_BUILDING")
        || typeMap[i][j - 1].equals("C_BUILDING")
        || typeMap[i][j + 1].equals("C_BUILDING")
        || typeMap[i - 1][j].equals("C_FIELD")
        || typeMap[i + 1][j].equals("C_FIELD")
        || typeMap[i][j - 1].equals("C_FIELD")
        || typeMap[i][j + 1].equals("C_FIELD"))) {
      typeMap[i][j] = "C_FIELD";
    }
  }
  // Find outlets for fields
  for (int i = 1; i < 15; i++) {
    for (int j = 1; j < 15; j++) {  
      if (typeMap[i][j].equals("C_FIELD")) {
        // Left
        if (typeMap[i - 1][j].equals("C_FIELD")) {
          outletsMatrix.matrix[i][j].outlets[0] = true;          
        }        
        // Right
        if (typeMap[i + 1][j].equals("C_FIELD")) {
          outletsMatrix.matrix[i][j].outlets[1] = true;          
        }        
        // Up
        if (typeMap[i][j - 1].equals("C_FIELD")) {
          outletsMatrix.matrix[i][j].outlets[2] = true;          
        }        
        // Down
        if (typeMap[i][j + 1].equals("C_FIELD")) {
          outletsMatrix.matrix[i][j].outlets[3] = true;          
        }
      }
    }
  }
   
  // And finally instantiate subZones
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {   
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), typeMap[i][j],
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);   
      subZones[i][j].elevation = elevationsMap[i][j];
      subZones[i][j].outlets = outletsMatrix.matrix[i][j].outlets;
    }
  }
}

void generateB_Town(Zone zone) {
  randomSeed(zone.seed);  
  Zone[][] subZones = zone.subZones;  
  String[][] typeMap = new String[16][16];
  OutletsMatrix outletsMatrix = new OutletsMatrix();
  
  // Initialize to island
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      typeMap[i][j] = "C_ISLAND";
    }    
  }
   
  // Some let's-start-with-concentric-rectangles city planning
  int nearX = (int) random(2, 5);
  int nearMidX = 6;
  int farMidX = 10;
  int farX = (int) random(12, 14);
  int nearY = (int) random(2, 5);
  int nearMidY = 6;
  int farMidY = 10;
  int farY = (int) random(12, 14);
  boolean inner = random(1) < 0.8;
  boolean outer = random(1) < 0.4;
  for (int i = 3; i < 14; i++) {
    for (int j = 3; j < 14; j++) {
      boolean onInner = inner && (i == nearMidX || j == nearMidY 
          || i == farMidX|| j == farMidY);
      boolean onOuter = outer && (i == nearX || j == nearY
          || i == farX || j == farY);
      if (onInner || onOuter) {
        typeMap[i][j] = "C_ROAD";        
      }
    }
  }
  // Erase some road segments
  float erasureChance = random(0.0, 0.3);
  for (int i = 3; i < 14; i++) {
    for (int j = 3; j < 14; j++) { 
      if (typeMap[i][j].equals("C_ROAD") && random(1) < erasureChance) {
        typeMap[i][j] = "C_ISLAND";           
      }
    }
  }
  
  // Delete isolated road segments
  for (int i = 3; i < 14; i++) {
    for (int j = 3; j < 14; j++) { 
      if (typeMap[i][j].equals("C_ROAD")
          && !typeMap[i - 1][j].equals("C_ROAD")
          && !typeMap[i + 1][j].equals("C_ROAD")
          && !typeMap[i][j - 1].equals("C_ROAD")
          && !typeMap[i][j + 1].equals("C_ROAD")) {
        typeMap[i][j] = "C_ISLAND"; 
      }
    }
  }
  
  // Create road/s if a road flows in / through this zone
  boolean hasOutlet = false;
  for (boolean outlet : zone.outlets) {
    if (outlet) {
      hasOutlet = true;
    }
  }

  // Add through-roads
  if (hasOutlet) {
    // Outlet to the left
    if (zone.outlets[0]) {
      int j = 8;
      for (int i = 0; i < 9; i++) {
       typeMap[i][j] = "C_ROAD";       
      }
    }
    // Outlet to the right
    if (zone.outlets[1]) {
      int j = 8;
      for (int i = 15; i >= 8; i--) {
       typeMap[i][j] = "C_ROAD";       
      }      
    }
    // Outlet above
    if (zone.outlets[2]) {
      int i = 8;
      for (int j = 0; j < 9; j++) {
       typeMap[i][j] = "C_ROAD";       
      }      
    }
    // Outlet below
    if (zone.outlets[3]) {
      int i = 8;
      for (int j = 15; j >= 8; j--) {
       typeMap[i][j] = "C_ROAD";       
      }           
    } 
  }

  // Add strech of shoreline road if it passes through here
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      // Needs to find if construction transition point falls through each subZone, so:
      // Try top-left to bottom-right corner scan first
      float centerX = zone.x + (i + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation1 = getIslandElevation(zone.superZone, centerX, centerY);
      centerX = zone.x + (i + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      centerY = zone.y + (j + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation2 = getIslandElevation(zone.superZone, centerX, centerY);
      if (elevation1 > CONSTRUCTION_LOWER_LIMIT ^ elevation2 > CONSTRUCTION_LOWER_LIMIT) {
        typeMap[i][j] = "C_ROAD";         
      }
      // Try top-right to bottom-left corner scan first
      centerX = zone.x + (i + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      centerY = zone.y + (j + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      elevation1 = getIslandElevation(zone.superZone, centerX, centerY);
      centerX = zone.x + (i + 0.0) * pow(16, MAX_DEPTH - (zone.depth + 1));
      centerY = zone.y + (j + 1.0) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      elevation2 = getIslandElevation(zone.superZone, centerX, centerY);
      if (elevation1 > CONSTRUCTION_LOWER_LIMIT ^ elevation2 > CONSTRUCTION_LOWER_LIMIT) {
        typeMap[i][j] = "C_ROAD";         
      }     
    }
  }
  
  // Add some stubby roadlets
  if (random(1) < 0.7) {
    for (int i = 3; i < 14; i++) {
      for (int j = 3; j < 14; j++) {
        if (typeMap[i][j].equals("C_ISLAND")) {
          // How many neighbors are roads?
          int numNeighboringIsland = -1;
          for (int subI = -1; subI <= 1; subI++) {
            for (int subJ = -1; subJ <= 1; subJ++) {
              if (typeMap[i + subI][j + subJ].equals("C_ISLAND")) {
                numNeighboringIsland++;
              }
            }
          }          
          if (numNeighboringIsland > 4 && numNeighboringIsland < 7 && random(1) < 0.1) {
            typeMap[i][j] = "C_ROAD";
          }
        }
      }
    }
  }

  // Find outlets for roads
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      if (typeMap[i][j].equals("C_ROAD")) {
        // Left
        if (i == 0 || typeMap[i - 1][j].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[0] = true;          
        }        
        // Right
        if (i == 15 || typeMap[i + 1][j].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[1] = true;          
        }        
        // Up
        if (j == 0 || typeMap[i][j - 1].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[2] = true;          
        }        
        // Down
        if (j == 15 || typeMap[i][j + 1].equals("C_ROAD")) {
          outletsMatrix.matrix[i][j].outlets[3] = true;          
        }
      }
    }
  }

  // Add buildings next to roads
  float buildingChance = random(0.47, 0.85);
  for (int i = 2; i < 15; i++) {
    for (int j = 2; j < 15; j++) { 
      if (typeMap[i][j].equals("C_ISLAND") &&
          (typeMap[i - 1][j].equals("C_ROAD")
          || typeMap[i + 1][j].equals("C_ROAD")
          || typeMap[i][j - 1].equals("C_ROAD")
          || typeMap[i][j + 1].equals("C_ROAD"))
          && random(1) < buildingChance) {
        typeMap[i][j] = "C_BUILDING";
        // Choose entrance
        ArrayList<Integer> entrances = new ArrayList<Integer>();
        // Check left
        if (typeMap[i - 1][j].equals("C_ROAD")) {
          entrances.add(0);
        }
        // Check right
        if (typeMap[i + 1][j].equals("C_ROAD")) {
          entrances.add(1);
        }
        // Check above
        if (typeMap[i][j - 1].equals("C_ROAD")) {
          entrances.add(2);
        }
        // Check below
        if (typeMap[i][j + 1].equals("C_ROAD")) {
          entrances.add(3);
        }  
        int entrance = entrances.get((int) random(entrances.size()));
        outletsMatrix.matrix[i][j].outlets[entrance] = true;
      }
    }
  }

  // Finally, instantiate subZones
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {  
      float centerX = zone.x + (i + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));
      float centerY = zone.y + (j + 0.5) * pow(16, MAX_DEPTH - (zone.depth + 1));       
      float elevation = getIslandElevation(zone.superZone, centerX, centerY);    
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), typeMap[i][j],
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);   
      subZones[i][j].elevation = elevation;
      subZones[i][j].outlets = outletsMatrix.matrix[i][j].outlets;
    }
  }  
}

void generateB_Ocean(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "C_OCEAN",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
    }
  }
}

void generateB_Space(Zone zone) {
  randomSeed(zone.seed);
  Zone[][] subZones = zone.subZones;
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 16; j++) {
      subZones[i][j] = new Zone(zone, (int) random(MAX_INT), "C_SPACE",
        zone.x + (int) (i * pow(16, MAX_DEPTH - (zone.depth + 1))),
        zone.y + (int) (j * pow(16, MAX_DEPTH - (zone.depth + 1))), zone.depth + 1);
    }
  }
}
