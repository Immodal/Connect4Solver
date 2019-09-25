class Position {
    /** 
     * A class storing a Connect 4 position.
     * Functions are relative to the current player to play.
     * Position containing aligment are not supported by this class.
     *
     * A binary bitboard representationis used.
     * Each column is encoded on HEIGH+1 bits.
     * 
     * Example of bit order to encode for a 7x6 board
     * .  .  .  .  .  .  .
     * 5 12 19 26 33 40 47
     * 4 11 18 25 32 39 46
     * 3 10 17 24 31 38 45
     * 2  9 16 23 30 37 44
     * 1  8 15 22 29 36 43
     * 0  7 14 21 28 35 42 
     * 
     * Position is stored as
     * - a bitboard "mask" with 1 on any color stones
     * - a bitboard "current_player" with 1 on stones of current player
     *
     * "current_player" bitboard can be transformed into a compact and non ambiguous key
     * by adding an extra bit on top of the last non empty cell of each column.
     * This allow to identify all the empty cells whithout needing "mask" bitboard
     *
     * current_player "x" = 1, opponent "o" = 0
     * board     position  mask      key       bottom
     *           0000000   0000000   0000000   0000000
     * .......   0000000   0000000   0001000   0000000
     * ...o...   0000000   0001000   0010000   0000000
     * ..xx...   0011000   0011000   0011000   0000000
     * ..ox...   0001000   0011000   0001100   0000000
     * ..oox..   0000100   0011100   0000110   0000000
     * ..oxxo.   0001100   0011110   1101101   1111111
     *
     * current_player "o" = 1, opponent "x" = 0
     * board     position  mask      key       bottom
     *           0000000   0000000   0001000   0000000
     * ...x...   0000000   0001000   0000000   0000000
     * ...o...   0001000   0001000   0011000   0000000
     * ..xx...   0000000   0011000   0000000   0000000
     * ..ox...   0010000   0011000   0010100   0000000
     * ..oox..   0011000   0011100   0011010   0000000
     * ..oxxo.   0010010   0011110   1110011   1111111
     *
     * key is an unique representation of a board key = position + mask + bottom
     * in practice, as bottom is constant, key = position + mask is also a 
     * non-ambigous representation of the position.
     */

    final static int WIDTH = 7;
    final static int HEIGHT = 6;

    // All longs being initialized with numbers must have an "L" at the end,
    // or it will be interpreted as an int.
    // This tracks only the stones of the current player.
    long current_position = 0L;
    // This tracks all stones regardless of who it belongs to.
    long mask = 0L;

    int moves = 0;

    // Returns true if a column is playable, else the column is full.
    boolean canPlay(int col) {
        // Will not allow play once a winner has been found.
        // Only checks the top row because stones only ever stack on top of each other.
        return getWinner()==0 ? (mask & top_mask(col)) == 0 : false;
    }

    void play(int col) {
        // The converts the board to be in the perspective or the current player's opponent.
        current_position ^= mask;
        // Adding a 1 to the bottom of the mask will cause the empty bit closest to the 
        // bottom to flip.
        // The OR then adds the latest 1 to the stored mask.
        mask |= mask + bottom_mask(col);
        moves++;
    }
    
    // Returns number of the current player.
    int getCurrentPlayer() {
        return moves%2==0 ? 1 : 2;
    }
    
    // Returns the player number of the winner, otherwise 0.
    int getWinner() {
        int player = getCurrentPlayer();
        // The check is only possible after a turn has been taken.
        if(hasAlignment(current_position^mask)) {
             return player==2 ? 1 : 2;
        } else {
            return 0;
        }
    }

    // Returns true if the current player has a 4 alignment
    boolean hasAlignment(long pos) {
        // These operations are able to check the whole board at once.

        // By ANDing a position with itself(displaced by one tile in a given direction), 
        // only cells that have a neighbouring 1 will remain 1.
        // Doing the operations will reduce the whole board to either 0 when no 4 alignment,
        // or greater than 0 when there is a 4 alignment.

        // The first operation checks the first 3 bits for neighbours.
        // The second operation will only result in >0 if there is a 4 alignment.

        // Example of horizontal check
        // position: 0111100
        // operation 1st: 0111100 & 0011110 = 0011100
        // operation 2nd: 0011100 & 0000111 = 0000100 -> contains a 1, thus there is alignment

        // position: 0110100
        // operation 1st: 0110100 & 0011010 = 0010000
        // operation 2nd: 0010000 & 0000100 = 0000000 -> contains no 1s, thus there is no alignment

        // Check for horizontal alignment
        long m = pos & (pos >> (HEIGHT+1));
        if ((m & (m >> (2*(HEIGHT+1))))>0) return true;

        // diagonal 1
        m = pos & (pos >> HEIGHT);
        if ((m & (m >> (2*HEIGHT)))>0) return true;

        // diagonal 2 
        m = pos & (pos >> (HEIGHT+2));
        if ((m & (m >> (2*(HEIGHT+2))))>0) return true;

        // vertical;
        m = pos & (pos >> 1);
        if ((m & (m >> 2))>0) return true;

        return false;
    }

    // Return a bitmask containing a single 1 on the top cell of a given column
    long top_mask(int col) {
        return (1L << (HEIGHT - 1)) << col*(HEIGHT+1);
    }

    // Return a bitmask containing a single 1 on the bottom cell of a given column
    long bottom_mask(int col) {
        return 1L << col*(HEIGHT+1);
    }
    
    String toPrintString() {
        String pos1;
        String pos2;
        String result = "";
        
        // Strings must be reversed or it will be read from front to back
        // instead of the intended back to front
        if(moves%2==0) {
            pos1 = new StringBuilder(Long.toBinaryString(current_position)).reverse().toString();
            pos2 = new StringBuilder(Long.toBinaryString(current_position^mask)).reverse().toString();
        } else {
            pos1 = new StringBuilder(Long.toBinaryString(current_position^mask)).reverse().toString();
            pos2 = new StringBuilder(Long.toBinaryString(current_position)).reverse().toString();
        }
        
        int index;
        for(int i=0; i<WIDTH; i++){
            for(int j=0; j<HEIGHT+1; j++){
                index = j+i*WIDTH;
                // Skip row HEIGHT+1
                if(j!=HEIGHT) {
                    if(index<pos1.length() && pos1.charAt(index)=='1') {
                        result += "1";
                    } else if(index<pos2.length() && pos2.charAt(index)=='1') {
                        result += "2";
                    } else {
                        result += "0";
                    }
                }
            }
        }
        
        return result;
    }
    
    void debug() {
        String pos1;
        String pos2;
        String m = new StringBuilder(Long.toBinaryString(mask)).reverse().toString();
        
        // Strings must be reversed or it will be read from front to back
        // instead of the intended back to front
        if(moves%2==0) {
            pos1 = new StringBuilder(Long.toBinaryString(current_position)).reverse().toString();
            pos2 = new StringBuilder(Long.toBinaryString(current_position^mask)).reverse().toString();
        } else {
            pos1 = new StringBuilder(Long.toBinaryString(current_position^mask)).reverse().toString();
            pos2 = new StringBuilder(Long.toBinaryString(current_position)).reverse().toString();
        }
        println("****************PRINTPOS******************");
        println("Player1");
        int index;
        for(int i=0; i<WIDTH; i++){
            for(int j=0; j<HEIGHT+1; j++){
                index = j+i*WIDTH;
                if(index<pos1.length() && pos1.charAt(index)=='1') {
                    print("1");
                } else {
                    print("0");
                }
            }
            println();
        }
        println("Player2");
        for(int i=0; i<WIDTH; i++){
            for(int j=0; j<HEIGHT+1; j++){
                index = j+i*WIDTH;
                if(index<pos2.length() && pos2.charAt(index)=='1') {
                    print("1");
                } else {
                    print("0");
                }
            }
            println();
        }
        println("MASK");
        for(int i=0; i<WIDTH; i++){
            for(int j=0; j<HEIGHT+1; j++){
                index = j+i*WIDTH;
                if(index<m.length() && m.charAt(index)=='1') {
                    print("1");
                } else {
                    print("0");
                }
            }
            println();
        }
        println();
    }
}
