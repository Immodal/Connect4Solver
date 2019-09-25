import java.util.*;

class Board {
    
    final int P1CLR = #FF0000;
    final int P2CLR = #0000FF;
    
    float x;
    float y;
    float w;
    float h;
    float dia;

    Board(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.dia = w/Position.WIDTH;
    }
    
    void draw(Position pos) {
        int winner = pos.getWinner();
        if(winner==0) drawInput(pos);
        else drawWinner(winner);
        drawPos(pos);
    }
    
    void drawPos(Position pos){
        String str = pos.toPrintString();
        
        int index;
        for(int i=0; i<Position.WIDTH; i++){
            for(int j=0; j<Position.HEIGHT; j++){
                index = j+i*(Position.WIDTH-1);
                if(str.charAt(index)=='1') fill(P1CLR);
                else if(str.charAt(index)=='2') fill(P2CLR);
                else noFill();
                
                // Y Axis is flipped
                ellipse(x+dia*(i+0.5), y+dia*(abs(Position.HEIGHT-j-1)+1.5), dia, dia);
            }
        }
    }
    
   void drawInput(Position pos) {
        fill(255);
        stroke(0);
        rect(this.x, this.y, this.w, this.dia);
        int t = getMousedOverTile();
        if(t>=0) {
            if(pos.moves%2==0) {
                fill(P1CLR);
            } else {
                fill(P2CLR);
            }
            ellipse(this.x+this.dia*(t+0.5), this.y+this.dia*(0.5), this.dia, this.dia);
        }
   }
  
  void drawWinner(int winner) {
      String msg = "Player " + Integer.toString(winner) + " Wins!";
      fill(0);
      text(msg, this.x+this.w/2, this.y+this.dia/2);
  }
  
  int getMousedOverTile(){
      for(int i=0; i<Position.WIDTH; i++){
          if(mouseX > this.x+this.dia*i && mouseX < this.x+this.dia*(i+1) && mouseY > this.y && mouseY < this.y+this.dia) {
              return i;
          }
      }
      return -1;
   }
   
   boolean mouseIsOver() {
       if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h) {
           return true;
       } else {
           return false;
       }
   }
}
