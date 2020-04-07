import java.util.Collections;
import java.util.Random;

final int MAX_DEPTH = 4;

final int RENDER_FLAB = 1;
final int MOVEMENT_FACTOR = 1;
final int CAMERA_PUSH_MARGIN = 3 * MOVEMENT_FACTOR;

PGraphics panel;
int panelSize;

Zone world;

Camera cam;
Player player;
boolean inConversation;

boolean cursor;
int cursorTimer;
final int CURSOR_SIT_TIME = 48;
boolean[] keys;

PImage img1, img2;

void setup() {
  frameRate(24);
  fullScreen(P2D);
  panelSize = height / 2 + 300;
  
  noCursor();  
  noSmooth();
  panel = createGraphics((RENDER_FLAB * 2 + 1) * 16, (RENDER_FLAB * 2 + 1) * 16, P2D); 
  ((PGraphicsOpenGL) panel).textureSampling(2);

  noiseDetail(4, 0.4);
  world = new Zone(null, 35, "WORLD", 0, 0, 0);
  world.generate();

  cam = new Camera(world);
  player = new Player(world.subZones[8][8]);
  
  keys = new boolean[20];
  
  img1 = loadImage("images/am.png");
  img2 = loadImage("images/text2.png");
}

void draw() {
  background(20);

  panel.beginDraw();
  // Render camera
  cam.render();
    
  // Display player
  int subI = (player.x - cam.x) / (int) pow(16, MAX_DEPTH - player.depth);
  int subJ = (player.y - cam.y) / (int) pow(16, MAX_DEPTH - player.depth);
  panel.loadPixels();
  //panel.pixels[subI + 16 + (subJ + 16) * 48] = lerpColor(panel.pixels[subI + 16 + (subJ + 16) * 16], color(250), .9);
  panel.pixels[subI + 16 * RENDER_FLAB + (subJ + 16 * RENDER_FLAB) * (RENDER_FLAB * 2 + 1) * 16] = color(250);
  panel.updatePixels();

  // Conversation panel
  if (inConversation) {
    int topY;
    // Conversation panel should be on opposite vertical half as player
    if (player.y < cam.y + 11 * (int) pow(16, MAX_DEPTH - (cam.depth + 1))) {
      topY = 28;
    } else {
      topY = 2; 
    }
    
    panel.fill(255);
    panel.rect(2, topY, 43, 17);
    panel.rect(2, topY, 17, 17);
    panel.image(img1, 3, topY + 1, 16, 16);
    
    panel.fill(20);
    panel.textSize(9);
    panel.image(img2, 20, topY + 1, 21, 16);
  }
    
  panel.endDraw();
  
  // Display panel
  image(panel, width / 2 - panelSize / 2, height / 2 - panelSize / 2, panelSize, panelSize); 
  
  handleInput();
}

void handleInput() {
  // Check if interact key triggered
  if (keys[7]) {
    inConversation = !inConversation;
    keys[7] = false;
  }
  
  if (!inConversation) {
    if (keys[1]) {
      // Left
      player.x -= MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (player.depth));
      if (player.x < cam.x + CAMERA_PUSH_MARGIN * (int) pow(16, MAX_DEPTH - (cam.depth + 1))) {
        cam.x -= MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (cam.depth + 1));
      }
    }
    if (keys[2]) {
      // Right
      player.x += MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (player.depth));
      if (player.x > cam.x + (16 - CAMERA_PUSH_MARGIN) * (int) pow(16, MAX_DEPTH - (cam.depth + 1))) {
        cam.x += MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (cam.depth + 1));
      }
    }
    if (keys[3]) {
      // Up
      player.y -= MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (player.depth));
      if (player.y < cam.y + CAMERA_PUSH_MARGIN * (int) pow(16, MAX_DEPTH - (cam.depth + 1))) {
        cam.y -= MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (cam.depth + 1));  
      }
    }
    if (keys[4]) {
      // Down
      player.y += MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (player.depth));
      if (player.y > cam.y + (16 - CAMERA_PUSH_MARGIN) * (int) pow(16, MAX_DEPTH - (cam.depth + 1))) {
        cam.y += MOVEMENT_FACTOR * (int) pow(16, MAX_DEPTH - (cam.depth + 1));   
      }
    }
    // Constrain camera
    cam.constrainPos();
    player.constrainPos();
    
    // Check for exiting to superZone
    if (keys[5] && cam.depth != 0) {
      int newPlayerX = player.x - player.x % (int) pow(16, MAX_DEPTH - (player.depth - 1));
      int newPlayerY = player.y - player.y % (int) pow(16, MAX_DEPTH - (player.depth - 1));
      player.move(newPlayerX, newPlayerY, player.depth - 1);
      int newCamX = player.x - 8 * (int) pow(16, MAX_DEPTH - cam.depth) ;
      int newCamY = player.y - 8 * (int) pow(16, MAX_DEPTH - cam.depth) ;
      cam.move(newCamX, newCamY, cam.depth - 1);
      
      keys[5] = false;
      // Cancel enter key to prevent flashing between depths
      keys[6] = false;
    }    
    // Check for entering subZone
    if (keys[6] && cam.depth < MAX_DEPTH - 1) {
      cam.move(player.x, player.y, cam.depth + 1);
      int newPlayerX = player.x + 8 * (int) pow(16, MAX_DEPTH - (player.depth + 1));
      int newPlayerY = player.y + 8 * (int) pow(16, MAX_DEPTH - (player.depth + 1));
      player.move(newPlayerX, newPlayerY, player.depth + 1);
      
      keys[6] = false;
      // Cancel exit key to prevent flashing between depths
      keys[5] = false;
    }
  }
}

class Player {
  int x, y, depth;
  
  Player(Zone zone) {
    x = zone.x;
    y = zone.y;
    depth = zone.depth;    
  }
  
  void move(int x, int y, int depth) {
    this.x = x;
    this.y = y; 
    this.depth = depth;    
    constrainPos();
  }
  
  void constrainPos() {
    x = constrain(x, 0, (int) (pow(16, MAX_DEPTH) - pow(16, MAX_DEPTH - depth)));
    y = constrain(y, 0, (int) (pow(16, MAX_DEPTH) - pow(16, MAX_DEPTH - depth))); 
  }
}

class Camera {
  int x, y, depth;
  
  Camera(Zone zone) {
    x = zone.x;
    y = zone.y;
    depth = zone.depth;
  }  
  
  void move(int x, int y, int depth) {
    this.x = x;
    this.y = y; 
    this.depth = depth;    
    constrainPos();
  }
  
  void constrainPos() {
    x = constrain(x, 0, (int) (pow(16, MAX_DEPTH) - pow(16, MAX_DEPTH - depth)));
    y = constrain(y, 0, (int) (pow(16, MAX_DEPTH) - pow(16, MAX_DEPTH - depth))); 
  }
  
  void render() {
    panel.background(20);
    for (int i = -RENDER_FLAB; i <= RENDER_FLAB; i++) {
      for (int j = -RENDER_FLAB; j <= RENDER_FLAB; j++) {  
        int currentCamX = cam.x + i * (int) pow(16, MAX_DEPTH - cam.depth);
        int currentCamY = cam.y + j * (int) pow(16, MAX_DEPTH - cam.depth);        
        int stepSize = (int) pow(16, MAX_DEPTH - (cam.depth + 1));
        for (int subI = 0; subI < 16; subI++) {
          for (int subJ = 0; subJ < 16; subJ++) {
            Zone zoneToDraw = findZone(currentCamX + subI * stepSize, currentCamY + subJ * stepSize, depth + 1);
            if (zoneToDraw != null && !zoneToDraw.type.contains("SPACE")) {
              randomSeed(zoneToDraw.seed);
              int c = getZoneColor(zoneToDraw);
              if (random(1) < 0.5) {
                panel.set(RENDER_FLAB * 16 + 16 * i + subI, RENDER_FLAB * 16 + 16 * j + subJ, c); 
              } else {
                panel.set(RENDER_FLAB * 16 + 16 * i + subI, RENDER_FLAB * 16 + 16 * j + subJ, lerpColor(c, color(80), 0.04));           
              }
            } else {
              randomSeed(1231513520 * frameCount + (long) (currentCamX + subI * stepSize + 12.124 * currentCamY + subJ * stepSize));
              if (random(1) < 0.5) {
                panel.set(RENDER_FLAB * 16 + 16 * i + subI, RENDER_FLAB * 16 + 16 * j + subJ, color(20)); 
              } else {        
                panel.set(RENDER_FLAB * 16 + 16 * i + subI, RENDER_FLAB * 16 + 16 * j + subJ, color(25)); 
              }
            }
          }      
        }
      }
    }
  }
}

void mouseMoved() {
  cursor = true;
  cursorTimer = CURSOR_SIT_TIME;
}

void mousePressed() {
  if (!cursor) {
    cursor = true;
    cursorTimer = CURSOR_SIT_TIME;
  }
}

void keyPressed() {
  if (key == ENTER || key == RETURN)
    keys[0] = true;
  // Left
  if (key == 'a' || keyCode == LEFT)
    keys[1] = true;
  // Right
  if (key == 'd' || keyCode == RIGHT)
    keys[2] = true;
  // Up
  if (key == 'w' || keyCode == UP)
    keys[3] = true;
  // Down
  if (key == 's' || keyCode == DOWN)
    keys[4] = true;
  // Out
  if (key == 'q')
    keys[5] = true;
  // In (enter)
  if (key == 'e')
    keys[6] = true;
  // Interact
  if (key == 'c')
    keys[7] = true;
}

void keyReleased() {
  if (key == ENTER || key == RETURN)
    keys[0] = false;
  // Left
  if (key == 'a' || keyCode == LEFT)
    keys[1] = false;
  // Right
  if (key == 'd' || keyCode == RIGHT)
    keys[2] = false;
  // Up
  if (key == 'w' || keyCode == UP)
    keys[3] = false;
  // Down
  if (key == 's' || keyCode == DOWN)
    keys[4] = false;
  // Out
  if (key == 'q')
    keys[5] = false;
  // In (enter)
  if (key == 'e')
    keys[6] = false;
  // Interact
  if (key == 'c')
    keys[7] = false;
}
