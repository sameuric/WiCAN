class WiredBus implements Bus {
    

    char state;

    WiredBus() {
        state = '1';
    }
    
    
    void reset() {
        state = '1';
    }
    
    
    char output(Node node) {
        return state;
    }
    
    char output(int x, int y) {
        return state;
    }
    
    
    void update(char bit, Node node) {
        if (bit == '0') {
            state = '0';
        }
    }
}
