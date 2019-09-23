import java.util.*;

class Board {
    
    int p1Color = #FF0000;
    int p2Color = #0000FF;
    
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
       // P1 turn
       if(pos.moves%2==0) {
           drawTiles(pos.current_position, p1Color);
           drawTiles(pos.current_position^pos.mask, p2Color);
       } else {
           drawTiles(pos.current_position, p2Color);
           drawTiles(pos.current_position^pos.mask, p1Color);
       }
   }
   
   void drawTiles(long pos, int pColor){
       String state = Long.toBinaryString(pos);
       
       // Add leading 0s
       char[] zeroes = new char[Position.WIDTH*(Position.HEIGHT+1) - state.length()];
       Arrays.fill(zeroes, '0');
       state = new String(zeroes) + state;
       
       for(int i=0; i<Position.WIDTH; i++){
           for(int j=0; j<Position.HEIGHT; j++){
               char s = state.charAt(i+j*Position.WIDTH);
               if(s=='1'){
                   fill(pColor);
                   noStroke();
                   ellipse(x+dia*(i+0.5), y+dia*(j+1.5), dia, dia);
               }
           }
       }
   }
}
