// This program is very heavily influenced by Pascal Pons's tutorial on
// solving Connect 4.
// Check it out here: http://blog.gamesolver.org/

Position position;

Board board;

void setup() {
    size(600,600);
    
    board = new Board(0, 0, width, height);
    position = new Position();
}

void draw() {
    board.draw(position);
}
