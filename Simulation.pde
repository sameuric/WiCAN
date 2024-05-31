class Simulation {

    
    //  --- Simulation components ---
    
    final static int BITRATE = 10000; // 10 kbps
    final static int CYCLES = 2000;

    // Nodes
    ArrayList<Node> nodes = new ArrayList<Node>();
    
    // Busses
    WiredBus wiredBus = new WiredBus();
    WirelessBus wirelessBus = new WirelessBus();
    
    // CAN network
    CANNetwork network;

    
    int startRec = 0;
    int stopRec = 2000;
    
    
    
    
    
    
    
    
    
    
    // Display parameters
    boolean drawing = false;
    boolean displaying = true;
    
    // Recording simulation
    String recNodes = "1/2/3";
    
    ArrayList<String> rxRecs = new ArrayList<String>();
    ArrayList<String> txRecs = new ArrayList<String>();
    
    ArrayList<ArrayList<Integer>> recRecs = new ArrayList<ArrayList<Integer>>();
    ArrayList<ArrayList<Integer>> tecRecs = new ArrayList<ArrayList<Integer>>();
    
    
    
    
    
    
    
    // --- Functions ---
    
    Simulation() {
        
        rxRecs.add("");  txRecs.add("");
        rxRecs.add("");  txRecs.add("");
        rxRecs.add("");  txRecs.add("");
        
        recRecs.add(new ArrayList<Integer>());
        recRecs.add(new ArrayList<Integer>());
        recRecs.add(new ArrayList<Integer>());
        
        
        tecRecs.add(new ArrayList<Integer>());
        tecRecs.add(new ArrayList<Integer>());
        tecRecs.add(new ArrayList<Integer>());
        
        this.network = new CANNetwork(nodes, wirelessBus, this);
        
        
        colors.add(#EE00EE); // Pink
        colors.add(#4169E1); // Blue
        colors.add(#E0C000); // Yellow
        
        
        colors.add(#EE00EE); // Pink
        colors.add(#4169E1); // Blue
        colors.add(#E0C000); // Yellow
        
        /*
        colors.add(#EE00EE); // Pink
        colors.add(#4169E1); // Blue
        colors.add(#E0C000); // Yellow
        
        
        colors.add(#EE00EE); // Pink
        colors.add(#4169E1); // Blue
        colors.add(#E0C000); // Yellow
        
        //*/
        
        
        int lecas = 1;

        if (lecas == 1) {
            nodes.add(new Node(1, 180 + 0 * 100, 200, "", 3, 1000));              // Blue
            nodes.add(new Node(2, 180 + 20 * 100, 200, "10100101", 2, 1));        // Yellow
            nodes.add(new Node(3, 180 + 40 * 100, 200, "1111010111110000111101011111000011110101111100001111010111110000", 1, 20)); // Pink
        }
        else if (lecas == 2) {
            nodes.add(new Node(1, 180 + 0 * 100, 200, "", 3, 1000));              // Blue
            nodes.add(new Node(2, 180 + 20 * 100, 200, "1111010111110000111101011111000011110101111100001111010111110000", 1, 20)); // Pink
            nodes.add(new Node(3, 180 + 40 * 100, 200, "10100101", 2, 1));        // Yellow
        }
        else if (lecas == 3) {
            nodes.add(new Node(1, 180 + 0 * 100, 200, "1111010111110000111101011111000011110101111100001111010111110000", 1, 20)); // Pink
            nodes.add(new Node(2, 180 + 20 * 100, 200, "", 3, 1000));              // Blue
            nodes.add(new Node(3, 180 + 40 * 100, 200, "10100101", 2, 1));        // Yellow
        }
        
        // Search 
        else if (lecas == 4) {
            nodes.add(new Node(1, 180 + 0 * 100, 200, "10100101", 2, 1));            // Yellow
            nodes.add(new Node(2, 180 + 20 * 100, 200, "1111010111110000111101011111000011110101111100001111010111110000", 1, 20)); // Pink
            nodes.add(new Node(3, 180 + 40 * 100, 200, "10100101", 3, 1));        // Yellow
        }
        
        // Cas 1 qui se met down
        else if (lecas == 5) {
            nodes.add(new Node(1, 180 + 0 * 100, 200, "1111110111110010111101011011000011110101101100001111010111110000", 1, 20)); // Pink
            nodes.add(new Node(2, 180 + 20 * 100, 200, "10100101", 3, 1));        // Yellow
            nodes.add(new Node(3, 180 + 40 * 100, 200, "0000001110000111101000000000011110101111100001111010111110000111", 2, 15)); // Pink
        }
        
        else {
            nodes.add(new Node(1, 180 + 0 * 100, 200, "10100101", 2, 3));            // Yellow
            nodes.add(new Node(2, 180 + 20 * 100, 200, "1111010111110000", 1, 13));  // Pink
            nodes.add(new Node(3, 180 + 40 * 100, 200, "00111100", 15, 2));           // Yellow
        }


       
        
        // Faulty nodes
        nodes.get(0).deaf = false;
        
        nodes.get(0).mute = false;
        nodes.get(2).mute = false;
    }

    
    void sm_start() {
        
        if (stopRec > CYCLES) {
            stopRec = CYCLES;
        }
        
        network.run(CYCLES, startRec, stopRec);
        
        if (displaying) {
            sm_print();
            drawing = true;
        }
    }
    
    
    // Return cycle's time in ms
    int time_c(int cycles) {
        return cycles * 1000 / BITRATE;
    }
    
    
    
    void sm_stop() {
    }
    
    void sm_print() {
        
        
    }
}
