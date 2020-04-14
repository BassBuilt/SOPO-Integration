class AgentSprite {
  Animation head;
  PImage hand;
  Animation shirt;
  PImage wrist;
  Animation background; 
  
  boolean handUp;
  
  void drawImage() {
    randomSeed(1000 * frameCount);
    // Update movement variables
    if (frameCount % 6 == 0) {
      if (random(1) < 0.5) {
        handUp = !handUp;
      }
    }
    
    // Draw background
    agentPanel.image(background.getFrame(), 0, 0, 16, 16);
    // Draw shirt
    agentPanel.image(shirt.getFrame(), 0, 0, 16, 16);
    // Draw head
    agentPanel.image(head.getFrame(), 0, 0, 16, 16);
    // Draw wrist
    agentPanel.image(wrist, 3, handUp ? 11 : 12, 3, 3);
    // Draw hand
    agentPanel.image(hand, 4, handUp ? 12 : 13, 1, 1);
  }
}

class Animation {
  PImage[] frames;
  int frameIndex;
  
  Animation(PImage[] frames) {
    this.frames = frames;
    frameIndex = 0;
  }
  
  PImage getFrame() {
    return frames[frameIndex = (frameIndex + 1) % frames.length];
  }
}
