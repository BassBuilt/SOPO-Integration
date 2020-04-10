class Agent {
  int x, y;
  
  Agent(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void enterConversation() {    
  }
  
  void exitConversation() {
  }
}

class Conversation {
  Agent agent;
  
  Conversation(Agent agent) {
    this.agent = agent;
  }
}
