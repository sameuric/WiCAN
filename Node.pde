class Node {

    int id;
    int x, y;
    int state;
    
    boolean listening;
    
    int period = 0;
    int pr_counter = 0;
    DataFrame msg;
    
    NodeBufferRX bufferRX;
    NodeBufferTX bufferTX;


    // Errors counters
    int TEC = 0;
    int REC = 0;
    

    // Physical properties
    final float Pout = 10.0; // 10 dBm = 10 mW
    final float RSSI = -68; 
    
    
    // Faulty nodes
    boolean deaf = false;
    boolean mute = false;
    
    
    
    Node(int id, int x, int y, String msg, int msgID, int period) {
        this.x = x;
        this.y = y;
        this.id = id;
        this.period = period;
        
        // Create buffers
        this.bufferRX = new NodeBufferRX(this);
        this.bufferTX = new NodeBufferTX(this);
        
        
        
        
        
        
        if (msg == "") {
            listening = true;
            this.msg = new DataFrame();
            println("Node", id, "is listening only");
        }
        
        else {
            listening = false;
            this.period = period;
            this.msg = new DataFrame(msgID, msg);
            println("Node", this.id,"is sending:", msg);
            
            
        }
        
        
        // Default
        state = NodeStates.STATE_WAITING;
    }
    
    
    /*
    // Update node's state due to some event
    
    void update(NetEvents ev) {
        
        
        
    }
    //*/
    
    
    // Ask its BufferTX to send the next bit
    
    char sendNextBit(Bus bus) {
        
        if (this.state == NodeStates.STATE_DISCONNECTED) {
            return '1';
        }
        
        if (!this.listening && this.state == NodeStates.STATE_WAITING && ++this.pr_counter >= this.period) {
            this.state = NodeStates.STATE_SENDING;
            //println("Node ", this.id, " is now sending");
            
            
            // Fill BufferTX
            this.bufferTX.fillBuffer(this.msg.getStuffedFrame());
        }
        
        if (this.state == NodeStates.STATE_SENDING) {
            return this.bufferTX.write(bus);
        }
        
        if (this.state == NodeStates.STATE_ACKING) {
            this.bufferTX.ackBit = '0';
            return this.bufferTX.write(bus);
        }
        
        // Default
        return this.bufferTX.write(bus);
    }
    
    
    
    // Ask its BufferRX to read the next bit
    
    char readNextBit(Bus bus) {
        
        if (this.state == NodeStates.STATE_DISCONNECTED) {
            return '1';
        }
        
        return this.bufferRX.read(bus);
    }
    
    
    void updateREC(int n) {
        REC += n;
        
        if (REC > 255) {
            REC = 255;
            return;
        }
        
        if (REC < 0) {
            REC = 0;
        }
    }
    
    
    void updateTEC(int n) {
        TEC += n;
        
        if (TEC > 255) {
            TEC = 255;
            return;
        }
    }
    
    
    
    void handleEvent(int ev) {
        
        if (ev == NetEvents.ARBITR_LOSS) {
            this.state = NodeStates.STATE_RECEIVING;
            this.bufferTX.clearBuffer();
            return;
        }
        
        if (ev == NetEvents.ACK_REQUIRED) {
            this.state = NodeStates.STATE_ACKING;
            return;
        }
        
        if (ev == NetEvents.END_OF_EOF) {
            
            if (state == NodeStates.STATE_SENDING) {
                this.pr_counter = 0;
                // After a successful transmission of a frame (getting ACK and no error detected until EOF is finished) the TEC is decreased by 1
                if (TEC > 0) --TEC;
            }
            
            //println("Node", id, "has received:", this.bufferRX.frame.getRawFrame());
            //println("Message :", this.bufferRX.frame.DATA, "to:", this.bufferRX.frame.ID);
            this.bufferRX.reset();
            this.state = NodeStates.STATE_IFS;
        }
    }
    
    
    // Update due to lifecycle
    
    void update(Bus bus) {
        
        // Sends bit to transmit, if any
        this.bufferTX.write(bus);
        
        // Check what node is listening on the network
        char readBit = this.bufferRX.read(bus);
        
        
        if (state == NodeStates.STATE_WAITING) {
            
            if (readBit == '1' && random(1) < 0.2) {
                state = NodeStates.STATE_SENDING;
            }
            else if (readBit == '0') {
                state = NodeStates.STATE_RECEIVING;
            }

            return;
        }
        
        
        
        
        if (state == NodeStates.STATE_SENDING) {
            
            if (readBit != this.bufferRX.tx) {
                error(ErrorTypes.BIT_ERROR);
            }

            return;
        }
        
        
        if (state == NodeStates.STATE_IFS) {
            
            if (readBit == '0') {
                error(ErrorTypes.FORM_ERROR);
            }

            return;
        }
        
        
        
        if (state == NodeStates.STATE_RECEIVING) {
            
            

            return;
        }
        
        
    }
    
    
    // Receive WirelessSignal
    char receiveWirelessSignal(float RSS) {
        return (RSS >= this.RSSI) ? '0' : '1';
    }

    
    // Error management
    
    void error(int err) {
        this.bufferTX.clearBuffer();
        
    }
    
    
    
    void off() {
        
        println("NODE", id, "OFF");
    }
    
}
