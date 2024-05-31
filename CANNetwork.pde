/**
  *    A CAN network is composed of:
  *        - Nodes
  *        - A bus
  */


class CANNetwork {

    ArrayList<Node> nodes;
    Simulation sim;
    Bus bus;
    
    boolean running = false;
    
    
    CANNetwork(ArrayList<Node> nodes, Bus bus, Simulation sim) {
        this.nodes = nodes;
        this.bus = bus;
        this.sim = sim;
    }
    
    
    
    /**
      *   A bit cycle is :
      *        - Nodes send a dominant or recessive bit (the bus's state is updating)
      *        - Nodes listen on the bus
      *            - Transmitting nodes check a potential bit / ACK error
      *            - Every node checks for errors
      *        - Nodes are updating their state / internal data
      *        - Bus reset its state
      */
    
    //static int curr_t = -1;
    
    void cycle(int t, int startRec, int stopRec) {

        //curr_t = t;
        
        // 1) Send
        nodes.forEach((node) -> {
            char signal = node.sendNextBit(this.bus);
            
            if (sim.recNodes.contains(String.valueOf(node.id)) && t >= sim.startRec && t <= stopRec) {
                String r = sim.txRecs.get(node.id - 1);
                r += signal;
                sim.txRecs.set(node.id - 1, r);
            }
        });
        
        // 2) Listen
        nodes.forEach((node) -> {
            char signal = node.readNextBit(this.bus);
            
            if (sim.recNodes.contains(String.valueOf(node.id)) && t >= sim.startRec && t <= stopRec) {
                String r = sim.rxRecs.get(node.id - 1);
                r += signal;
                sim.rxRecs.set(node.id - 1, r);
                
                
                // Records TEC / REC
                final int nREC = node.REC;
                final int nTEC = node.TEC;
                
                ArrayList<Integer> recList = sim.recRecs.get(node.id - 1);
                ArrayList<Integer> tecList = sim.tecRecs.get(node.id - 1);
                
                if (recList.size() == 0 || recList.get(recList.size() - 1) != nREC) {
                    recList.add(t);
                    recList.add(nREC);
                }
                
                if (tecList.size() == 0 || tecList.get(tecList.size() - 1) != nTEC) {
                    tecList.add(t);
                    tecList.add(nTEC);
                }
            }
            
        });

        // 3) Reset
        bus.reset();
    }
    




    void run(int cycles, int startRec, int stopRec) {
        
        running = true;

        for (int t = 0; ++t < cycles && running;) {
            cycle(t, startRec, stopRec);
        }
    }
    
    
    void switchBus(Bus bus) {
        this.bus = bus;
    }
    
    void addNode(Node node) {
        this.nodes.add(node);
    }
    
    void removeNode(int index) {
        this.nodes.remove(index);
    }
    
    void stopRun() {
        running = false;
    }
}
