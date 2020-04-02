// Returns the elevation of a given position within a island (as an A-level zone)
float getIslandElevation(Zone island, float x, float y) {
  noiseSeed(island.seed);
  int islandCenterX = island.x + 8 * (int) pow(16, MAX_DEPTH - (island.depth + 1));
  int islandCenterY = island.y + 8 * (int) pow(16, MAX_DEPTH - (island.depth + 1));
  float distance = sqrt(pow(x - islandCenterX, 2) + pow(y - islandCenterY, 2));
  float distanceScalar = constrain(map(distance,
    0.0 * (int) pow(16, MAX_DEPTH - (island.depth + 1)),
    10.0 * (int) pow(16, MAX_DEPTH - (island.depth + 1)), 1, 0), 0, 1);
  float edgeDistance = max(abs(x - islandCenterX), abs(y - islandCenterY));
  distanceScalar *= constrain(map(edgeDistance,
    7.0 * (int) pow(16, MAX_DEPTH - (island.depth + 1)),
    8.0 * (int) pow(16, MAX_DEPTH - (island.depth + 1)), 1, 0.0), 0.0, 1);
  return distanceScalar * noise(x / 4.0 / pow(16, MAX_DEPTH - (island.depth + 1)),
      y / 4.0 / pow(16, MAX_DEPTH - (island.depth + 1)));
}

class OutletsMatrix {
  
  OutletsNode[][] matrix;

  OutletsMatrix() {
    matrix = new OutletsNode[16][16];
    
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 16; j++) {
        matrix[i][j] = new OutletsNode(i, j);
      }
    }
  }
}

class OutletsNode {
  // Array indicating whether there is an outlet in each cardinal direction of node [left, right, up, down]
  boolean[] outlets;
  boolean reached;
  int x, y;
  
  OutletsNode(int x, int y) {
    this.x = x;
    this.y = y;
    outlets = new boolean[4];
  }
}  

void createRoadSystem(boolean[][] landMap, int startI, int startJ, OutletsMatrix outletsMatrix) {
  OutletsNode startingNode = outletsMatrix.matrix[startI][startJ];
  startingNode.reached = true;
  ArrayList<OutletsNode> frontier = new ArrayList<OutletsNode>();
  frontier.add(startingNode);
  
  // Extend road out from start position, repeatedly randomly choosing members with unreached potential neighbors
  while (!frontier.isEmpty()) {
    // Choose random member from frontier
    int index = (int) random(0, frontier.size());
    OutletsNode currentNode = frontier.get(index);
    
    // Create random order to try neighboring nodes
    ArrayList<Integer> selections = new ArrayList<Integer>();
    selections.add(0);
    selections.add(1);
    selections.add(2);
    selections.add(3);
    Collections.shuffle(selections, new Random((int) random(MAX_INT)));
    
    // Run through unreached neighboring nodes to connect to
    boolean wasSuccessful = false;
    for (int direction : selections) {
      OutletsNode option;
      if (direction == 0) {
        // Left
        option = outletsMatrix.matrix[currentNode.x - 1][currentNode.y];
      } else if (direction == 1) {
        // Right
        option = outletsMatrix.matrix[currentNode.x + 1][currentNode.y];
      } else if (direction == 2) {
        // Up
        option = outletsMatrix.matrix[currentNode.x][currentNode.y - 1];
      } else {
        // Down
        option = outletsMatrix.matrix[currentNode.x][currentNode.y + 1];
      }
      if (landMap[option.x][option.y] && (!option.reached || random(1) < 0.1)) {
        currentNode.outlets[direction] = true;
        int oppositeDirection = direction % 2 == 0 ? direction + 1 : direction - 1;
        option.outlets[oppositeDirection] = true;
        option.reached = true;
        frontier.add(option);
        wasSuccessful = true;
        break;
      }    
    }
    // Remove nodes in frontier with no possible unreached neighbors to extend to
    if (!wasSuccessful) {
      frontier.remove(currentNode);
    }
  }  
}
