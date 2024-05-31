/**
  *   Represent a CAN Overload Frame
  */


class OverloadFrame extends CANFrame {

    // Fields
    final static String overloadFlags = "000000"; // Consists of 6 dominant bits
    final static String overloadDelimiter = "11111111";
    
    
    String toBinary() {
        return overloadFlags + overloadDelimiter;
    }
    
    String nextEmptyField() {
        if (overloadFlags.isEmpty()) {
            return "OVR_FLAG";
        }
        return "NONE";
    }
}
