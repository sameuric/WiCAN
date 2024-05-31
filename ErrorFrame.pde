/**
  *   Represent a CAN Error Frame
  */


class ErrorFrame extends CANFrame {

    // Fields
    String errorFlags; // Superposition of Error flags (6–12 bits) 
    final static String errorDelimiter = "11111111";
    
    
    String toBinary() {
        return errorFlags + errorDelimiter;
    }
    
    String nextEmptyField() {
        if (errorFlags.isEmpty()) {
            return "ERR_FLAG";
        }
        return "NONE";
    }
}
