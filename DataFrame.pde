/**
  *   Manage and represent a data CAN frame
  */


class DataFrame extends CANFrame {


    // Fields
    String  SOF = "",
            ID = "",
            RTR = "",
            IDE = "",
            R0 = "",
            DLC = "",
            DATA = "",
            CRC = "",
            
            CRC_DEL = "",
            ACK = "",
            ACK_DEL = "",
            EOF = "";

    NodeBufferRX bf;
    
    // Buffer for destuffing
    String dbuff = "";
    

    // A Data Frame can be empty
    DataFrame() {
    }
    
    DataFrame(NodeBufferRX bf) {
        this.bf = bf;
    }

    DataFrame(int id, String data) {

        this.ID = binary(id, 11);

        while (data.length() % 8 != 0) {
            data = "0" + data;
            println("Added 0;");
        }

        this.DATA = data;
        this.DLC = binary(data.length() / 8, 4);
        fillEmptyFields();
    }
    
    



    // Check syntax while adding the new bit
    boolean addBit(char bit) {
        
        
        // Bit de-stuffing
        if (CRC.length() < 15) {
            
            if (dbuff == "") {
                dbuff += bit;
            }
            
            else if (dbuff.length() == 5) {
                if (bit == dbuff.charAt(0)) {
                    // ERROR BIT STUFFING
                    dbuff = "";
                    this.bf.error(ErrorTypes.STUFF_ERROR);
                    return false;
                }
                else {
                    dbuff = String.valueOf(bit);//println("ignored");
                    return true;
                }
            }
            else {
                if (bit == dbuff.charAt(0)) {
                    dbuff += bit;
                }
                else {
                    dbuff = String.valueOf(bit);
                }
            }
        }
        
        
        
        //println("Frame added ", bit);
        
        if (SOF.length() < 1 && bit == '0') {
            SOF += bit;
            return true;
        }

        if (ID.length() < 11) {
            ID += bit;
            return true;
        }
        
        if (RTR.length() < 1) {
            RTR += bit;
            return true;
        }
        
        if (IDE.length() < 1) {
            IDE += bit;
            return true;
        }
        
        if (R0.length() < 1) {
            R0 += bit;
            return true;
        }
        
        if (DLC.length() < 4) {
            DLC += bit;
            return true;
        }
        
        
        
        // Data field
        int code = Integer.parseInt(this.DLC, 2);
        
        if (DATA.length() < 8 * code) {
            DATA += bit;
            return true;
        }
        
        if (CRC.length() < 15) {
            CRC += bit;
            return true;
        }
        
        if (CRC_DEL.length() < 1) {
            
            if (bit == '1') {
                CRC_DEL += bit;
                return true;
            }
            
            return false;
        }
        
        
        // ACK slot
        
        if (ACK.length() < 1) {
            
            if (bit == '0') {
                ACK += bit;
                return true;
            }
            
            return false;
        }
        
        if (ACK_DEL.length() < 1) {
            
            if (bit == '1') {
                ACK_DEL += bit;
                return true;
            }
            
            return false;
        }
        
        
        // EOF 
        
        if (EOF.length() < 7) {
            
            if (bit == '1') {
                EOF += bit;
                return true;
            }
            
            return false;
        }
        return false;
    }




    // Fill empty fields with a default value

    void fillEmptyFields() {

        if (SOF.length() < 1) {
            SOF = "0";
        }

        if (ID.length() < 11) {
            ID = "00000001";
        }
        
        if (RTR.length() < 1) {
            RTR = "0";
        }
        
        if (IDE.length() < 1) {
            IDE = "0";
        }
        
        if (R0.length() < 1) {
            R0 = "0";
        }
        
        if (DLC.length() < 4) {
            DLC = "0001";
        }
        
        
        
        // Data field
        int code = Integer.parseInt(this.DLC, 2);
        
        while (DATA.length() < 8 * code) {
            DATA = "0" + DATA;
        }
        
        
        
        if (CRC.length() < 15) {
            CRC = "000111000111000";
        }
        
        if (CRC_DEL.length() < 1) {
            CRC_DEL = "1";
        }
        
        
        // ACK slot
        
        if (ACK.length() < 1) {
            ACK = "1";
        }
        
        if (ACK_DEL.length() < 1) {
            ACK_DEL = "1";
        }

        if (EOF.length() < 7) {
            EOF = "1111111";
        }
    }



    

    
    // Returns a stuffed Data Frame
    
    String getStuffedFrame() {
        return STUFF(SOF + ID + RTR + IDE + R0 + DLC + DATA + CRC) + CRC_DEL + ACK + ACK_DEL + EOF;
    }
    
    
    // Returns a non-stuffed Data Frame
    
    String getRawFrame() {
        return SOF + ID + RTR + IDE + R0 + DLC + DATA + CRC + CRC_DEL + ACK + ACK_DEL + EOF;
    }
    

    // Stuff a Data Frame
    
    String STUFF(final String bits) {
        
        String res = "";
        String s_bsb = "";
        
        final char[] cbits = bits.toCharArray();
        
        
        for (final char bit : cbits) {
            
            if (s_bsb == "") {
                s_bsb += bit;
                res += bit;
                continue;
            }
            
            if (bit == s_bsb.charAt(0)) {
                
                if (s_bsb.length() == 4) {
                    final String sBit = (bit == '0') ? "1" : "0";
                    res += bit + sBit;
                    s_bsb = sBit;
                }
                else {
                    res += bit;
                    s_bsb += bit;
                }
            }
            else {
                res += bit;
                s_bsb = String.valueOf(bit);
            }
        }
        
        return res;
    }
    
    
    
    
    
    
}
