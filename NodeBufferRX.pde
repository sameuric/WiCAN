/**
  *   A NodeBufferRX instance reads each bit on RX and
  *   try to build a CAN frame representation on-the-fly.
  */

class NodeBufferRX {
    
    DataFrame frame;
    Node node;
    
    // Transmitted bit (if any)
    char tx = ' ';
    
    // IFS counter
    int IFS_counter = 0;
    
    // FECs counters (Dominant and Recessive ECs counters)
    int DFEC = 0;
    int RFEC = 0;
    
    boolean primary;
    boolean receiver = true;
    
    NodeBufferRX(Node node) {
        this.node = node;
        this.frame = new DataFrame(this);
    }
    
    
    
    char read(Bus bus) {
        
        if (node.state == NodeStates.STATE_DISCONNECTED) {
            return '1';
        }
        
        char readBit = (node.deaf) ? '1' : bus.output(this.node);

        if (!parseBit(readBit)) {
            //println("parseBit has returned false");
        }
        
        return readBit;
    }
    
    
    /**
      *  Parse the bit read on the bus and do :
      *      - Update node's state
      *      - Build an internal DataFrame
      *      - Manage errors
      *      - 
      *      - 
      */
    
    
    boolean parseBit(char rx) {
        if (rx == '0') {
            return parseRX0();
        }
        else {
            return parseRX1();
        }
    }
    
    
    
    
    
    /**
      *   Parse a dominant bit
      */
    
    
    boolean parseRX0() {
        
        // Update state to SOF
        if (node.state == NodeStates.STATE_WAITING) {
            updateState(NodeStates.STATE_RECEIVING);
            return this.frame.addBit('0');
        }
        
        // Build the DataFrame
        if (node.state == NodeStates.STATE_RECEIVING) {
            
            // CRC delimiter is dominant, error
            if (frame.CRC.length() == 15 && frame.CRC_DEL.length() == 0) {
                error(ErrorTypes.FORM_ERROR);
                return false;
            }
            
            // EOF has a dominant bit, error
            if (frame.ACK_DEL.length() == 1 && frame.EOF.length() < 7) {
                error(ErrorTypes.FORM_ERROR);
            }
            
            return this.frame.addBit('0'); // If return false ?
        }
        
        // Check bit error and build the DataFrame
        if (node.state == NodeStates.STATE_SENDING) {
            
            if (tx != '0') {
                
                // Lost arbitration
                if (frame.SOF.length() > 0 && frame.ID.length() < 11) {
                    
                    // Still receiving
                    if (!this.frame.addBit('0')) {
                        error(ErrorTypes.STUFF_ERROR);
                        return false;
                    }
                    
                    this.node.handleEvent(NetEvents.ARBITR_LOSS);
                    //println("arbitration loss");
                    return true;
                }
                // Receive ACK
                else if (frame.ACK.length() == 0 && frame.CRC_DEL.length() == 1) {
                    //println("ACK OK for node", this.node.id);
                    this.frame.addBit('0');
                    return true;
                }
                else {
                    error(ErrorTypes.BIT_ERROR);
                }
                return false;
            }
            
            this.frame.addBit('0');
            return true; 
        }
        
        // Counter IFS
        if (node.state == NodeStates.STATE_IFS) {
            error(ErrorTypes.IFS_ERROR);
            return true;
        }
        
        // Must receive dominant bit for ACK slot
        if (node.state == NodeStates.STATE_ACKING) {
            this.frame.addBit('0');
            
            // After a successful reception of a frame (reception without error up to the ACK slot and the successful sending of the ACK bit), the REC is
            // decreased by 1, if it was between 1 and 127. If it was greater than 127, then it will be set to a value between 119 and 127.
            
            if (node.REC > 127) {
                node.REC = 120;
            }
            else if (node.REC > 0) {
                node.REC--;
            }
            
            
            updateState(NodeStates.STATE_RECEIVING);
            return true;
        }
        
        
        
        
        
        // Error states (parseRX0)
        
        if (node.state == NodeStates.STATE_ACT_ERR_FLAG || node.state == NodeStates.STATE_PSV_ERR_FLAG) {
            
            if (DFEC < 12 && RFEC == 0) {
                
                // When a receiver detects a dominant bit as the first bit after sending an error flag, the REC is increased by 8.
                if (DFEC == 6) {
                    //node.REC += 8;
                    node.updateREC(8);
                }
                
                ++DFEC;
            }
            else {
                error(ErrorTypes.FORM_ERROR);
            }
            
            return true;
        }

        // Ignore bit
        return true;
    }
    
    
    
    

    boolean parseRX1() {
        
        // Ignore bit
        if (node.state == NodeStates.STATE_WAITING) {
            //println("Node ", this.node.id, "parsed bit 1 and returned;");
            return true;
        }
        
        // Build the DataFrame
        if (node.state == NodeStates.STATE_RECEIVING) {
            
            // CRC delimiter is recessive
            if (frame.CRC.length() == 15 && frame.CRC_DEL.length() == 0) {
                this.node.handleEvent(NetEvents.ACK_REQUIRED);
                //return false;
            }
            
            // Last bit of the frame
            if (frame.EOF.length() == 6) {
                this.frame.addBit('1');
                this.node.handleEvent(NetEvents.END_OF_EOF);
                return true;
            }
            
            return this.frame.addBit('1'); // If return false ?
        }
        
        // Check bit error and build the DataFrame
        if (node.state == NodeStates.STATE_SENDING) {
            
            if (tx != '1') {
                error(ErrorTypes.BIT_ERROR);
                return false;
            }
            
            // Last bit of the frame
            if (frame.EOF.length() == 6) {
                this.frame.addBit('1');
                this.node.handleEvent(NetEvents.END_OF_EOF);
                return true;
            }
            
            // Receive ACK
            if (frame.ACK.length() == 0 && frame.CRC_DEL.length() == 1) {
                println("ACK '1' for node", this.node.id);
                error(ErrorTypes.ACK_ERROR);
                return false;
            }
            
            this.frame.addBit('1');
            return true; 
        }
        
        // Counter IFS
        if (node.state == NodeStates.STATE_IFS) {
            
            ++IFS_counter;
            
            if (IFS_counter == 3) {
                IFS_counter = 0;
                //println("IFS ended for node", this.node.id);
                
                this.reset();
                node.bufferTX.clearBuffer(); // Not sure
                updateState(NodeStates.STATE_WAITING);
            }
            
            return true;
        }
        
        // Must receive dominant bit for ACK slot
        if (node.state == NodeStates.STATE_ACKING) {
            error(ErrorTypes.ACK_ERROR);
            return true;
        }
        
        
        
        
        
        // Error states (parseRX1)
        
        if (node.state == NodeStates.STATE_ACT_ERR_FLAG || node.state == NodeStates.STATE_PSV_ERR_FLAG) {
            
            if (DFEC >= 6 && DFEC <= 12) {
                
                if (RFEC == 0) {
                    primary = (DFEC > 6) ? true : false;
                    
                    if (!receiver && primary) {
                        if (node.TEC < 255) node.TEC += 8;
                    }
                    else if (receiver && primary) {
                        if (node.REC < 255) node.updateREC(8);
                    }
                    else if (receiver && !primary) {
                        node.updateREC(1);
                    }
                    
                }
                
                if (RFEC < 7) {
                    ++RFEC;
                }
                else if (RFEC == 7) {
                    // Leave error state
                    IFS_counter = 0;
                    updateState(NodeStates.STATE_IFS);
                }
                else {
                    error(ErrorTypes.FORM_ERROR);
                    return false;
                }
            }
            else if (node.state == NodeStates.STATE_PSV_ERR_FLAG) {
                RFEC++;
                
                if (RFEC > 13) {
                    // Leave error state
                    IFS_counter = 0;
                    updateState(NodeStates.STATE_IFS);
                }
                
                return true;
            }
            else {
                error(ErrorTypes.FORM_ERROR);
                return false;
            }
        }

        // Ignore bit
        return true;
    }
    
    
    
    void updateState(int nodeState) {
        node.state = nodeState;
    }
    
    void reset() {
        this.frame = new DataFrame(this);
    }
    
    
    
    // Enter in error mode
    
    void error(int err) {
        
        
        // When a transceiver detects an error, the REC will be increased by 1, except when the detected error is a bit error during the sending of an active error flag.
        if (err != ErrorTypes.BIT_ERROR || node.state != NodeStates.STATE_ACT_ERR_FLAG) {
            node.updateREC(1);
        }


        if (node.state != NodeStates.STATE_ACT_ERR_FLAG && node.state != NodeStates.STATE_PSV_ERR_FLAG) {
            receiver = !(node.state == NodeStates.STATE_SENDING);
        }

        
        if (!receiver) {
            // When a transmitter sends an error flag, the TEC is increased by 8.
            node.TEC += 8;
            
            //If a transmitter detects a bit error while sending an active error flag, the TEC is increased by 8.
            if (err == ErrorTypes.BIT_ERROR && node.state == NodeStates.STATE_ACT_ERR_FLAG) {
                node.TEC += 8;
            }
        }
        else {
        
            // Receiver case
            
            // If a receiver detects a bit error while sending an active error flag, the REC is increased by 8.
            if (err == ErrorTypes.BIT_ERROR && node.state == NodeStates.STATE_ACT_ERR_FLAG) {
                node.updateREC(8);
            }
            
        }
        
        // Clear buffers
        this.reset();
        node.bufferTX.clearBuffer();
        
        
        // TEC and REC
        
        if (node.TEC < 128 && node.REC < 128) {
            updateState(NodeStates.STATE_ACT_ERR_FLAG);
            node.bufferTX.fillBuffer("000000");
        }
        else if (node.TEC > 255) {
            // Disconnected
            node.TEC = 0;
            node.REC = 0;
            updateState(NodeStates.STATE_DISCONNECTED);
            println("Node ", node.id, " disconnected");
        }
        else if (node.TEC > 127 || node.REC > 127) {
            
            if (node.state != NodeStates.STATE_PSV_ERR_FLAG) {
                updateState(NodeStates.STATE_PSV_ERR_FLAG);
                println("Node", node.id, "now in passive error mode");// at", CANNetwork.curr_t);
            }
            node.bufferTX.fillBuffer("111111");
        }
        
        
        // Reset Frame Erros Counters
        DFEC = 0;
        RFEC = 0;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
