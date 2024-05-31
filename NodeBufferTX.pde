
/**
  *   A NodeBufferTX instance read each bit on RX and
  *   try to build a CAN frame representation on-the-fly.
  */

class NodeBufferTX {
    
    Node node;
    
    String sequence = "";
    char ackBit = ' ';
    
    NodeBufferTX(Node node) {
        this.node = node;
    }
    
    
    
    char write(Bus bus) {
        
        if (node.state == NodeStates.STATE_DISCONNECTED) {
            return '1';
        }
        
        if (ackBit != ' ') {
            bus.update(node.mute ? '1' : ackBit, node);

            this.node.bufferRX.tx = ackBit; // Transmitted bit
            ackBit = ' ';
            return this.node.bufferRX.tx;
        }
        
        else if (sequence.length() > 0) {
            bus.update(node.mute ? '1' : sequence.charAt(0), node);
            this.node.bufferRX.tx = sequence.charAt(0); // Transmitted bit
            sequence = sequence.substring(1);
            return this.node.bufferRX.tx;
        }
        
        return '1';
    }
    
    
    void fillBuffer(String raw) {
        //println("Buffer filled with ", raw);
        sequence = sequence + raw;
    }
    
    void clearBuffer() {
        sequence = "";
        ackBit = ' ';
    }
    
    
    void setAckBit(char bit) {
        this.ackBit = bit;
    }
}
