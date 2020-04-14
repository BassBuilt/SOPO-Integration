class Agent {
  int seed;
  int x, y;
  AgentSprite sprite;
  boolean spriteCreated;
  
  Agent(int seed, int x, int y) {
    this.seed = seed;
    this.x = x;
    this.y = y; 
  }
  
  void createSprite() {
    randomSeed(seed);
    sprite = new AgentSprite();
    int bodyIndex = (int) random(1, 6);
    sprite.head = new Animation(new PImage[]{loadImage("images/agent_panel/heads/head" + bodyIndex + ".png")});
    sprite.hand = loadImage("images/agent_panel/hands/hand" + bodyIndex + ".png");
    int clothingIndex = (int) random(1, 6);
    sprite.shirt = new Animation(new PImage[]{loadImage("images/agent_panel/shirts/shirt" + clothingIndex + ".png")});
    sprite.wrist = loadImage("images/agent_panel/wrists/wrist" + clothingIndex + ".png");
    int backgroundIndex = (int) random(1, 3);
    sprite.background = new Animation(new PImage[]{loadImage("images/agent_panel/backgrounds/background" + backgroundIndex + ".png")});
    spriteCreated = true;
  }  
}

class Conversation {
  Agent agent;
  
  Conversation(Agent agent) {
    this.agent = agent;
    if (!agent.spriteCreated) {
      agent.createSprite();
    }
  }
}
