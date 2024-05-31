class WirelessBus implements Bus {
    
    final static float N_factor = 2.0;
    final static float frequency = 433.92;
    final static float lambda_sq = 0.47733;//pow(100 * (2.9979 / frequency), 2);
    final static float coeff = 16*PI*PI/lambda_sq;
    
    // Liste des noeuds qui sont en train d'émettre à un même moment
    ArrayList<Node> nodes;
    
    WirelessBus() {
        nodes = new ArrayList<Node>();
    }
    
    void reset() {
        nodes = new ArrayList<Node>();
    }
    
    
    
    char output(Node node) {
        
        
        // If node is emitting, RSS = 10 dBm (maximum)
        for (Node node2: this.nodes) {
            if (node.id == node2.id) {
                return node.receiveWirelessSignal(10);
            }
        }
        
        
        
        // If node is not emitting, compute RSS
        
        final float PL_EXP = 4.0;
        float RSS = Float.NEGATIVE_INFINITY;
        boolean test = false;
        
        for (Node node2 : nodes) {test = true;
            /**
              *    Each antenna is in the far field of the other:
              *        d >> λ = 0.69 m
              *
              *    https://www.sciencedirect.com/topics/engineering/path-loss
              */


            // 100 px = 1m
            final float dn = pow(sqrt(pow(0.01*(node.x - node2.x), 2) + pow(0.01*(node.y - node2.y), 2)), PL_EXP);
            final float PL_dB = 10 * (log(coeff * dn) / log(10));
            
            //final float Pr = 10 * (log(max(0, pow(10, node2.Pout/10) - pow(10, PL/10))) / log(10)); // Puissance reçue par l'antenne de node2
            final float Pr = node2.Pout - PL_dB;
            
            //println("PR :", Pr);
            
            
            
            RSS = 10 * (log(pow(10, RSS/10) + pow(10, Pr/10)) / log(10));
            
        }

        //if (test) println("RSS :", RSS);
        return node.receiveWirelessSignal(RSS);
    }
    
    char output(int x, int y) {
        return '0';
    }
    
    void update(char bit, Node n) {
        if (bit == '0') {
            nodes.add(n);
        }
    }
    
    
}
