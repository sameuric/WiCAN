

/**
  *   CAN NETWORK SIMULATOR
  *
  *    Author: Sacha Meurice
  *    © Sacha Meurice, All rights reserved.
  *
  *    Link : https://github.com/sameuric/WiCAN
  */



Simulation sim;

boolean displayEC = false;
boolean displayGraph = true;
boolean displayCursor = false;


boolean displayREC = false;
boolean endedPointAdded = false;

color cursorColor;
color textColor;



ArrayList<Integer> colors = new ArrayList<Integer>();


// Emplacement de calcul temporaire pour un chronograme
ArrayList<Integer> calc;


void setup() {
    
    surface.setTitle("CAN network simulator");
    surface.setResizable(true);
    
    size(1850, 800);
    background(#FFFFFF);
    frameRate(40);
    
    
    // Launch simulation in a seperate thread
    sim = new Simulation();
    thread("launchSimulation");
    
    
    
    
    
    textColor = #000000;
    cursorColor = color(100, 100, 100, 250);
    textSize(20);
    fill(textColor);
    noFill();
    strokeWeight(2);
}



void graph() {


    // --- Variables ---
    
    text("Start time:  " + String.valueOf(sim.time_c(sim.startRec)) + " ms" + "         Stop time:  " + String.valueOf(sim.time_c(sim.stopRec)) + " ms" + "         Delta:  " + String.valueOf(sim.time_c(sim.stopRec) - sim.time_c(sim.startRec)) + " ms", 50, 40);

    int incr = 0;
    final int off_X = 50;
    final int off_Y = 30;

    final int TLENGTH = sim.stopRec - sim.startRec;
    final float dStep = (width - 3.5 * off_X) / TLENGTH;
    final float GHEIGHT = (height - 1.5 * off_Y);
    
    
    
    
    
    
    
    // --- Gestion des axes ---
    
    final int AX = int(off_X + (dStep) * TLENGTH);
    final int AY = int(GHEIGHT);
    
    
    // Ligne de début
    stroke(150,150,150);
    line(off_X, off_Y + 80, off_X, AY);
    triangle(off_X-5, off_Y + 80, off_X+5, off_Y + 80, off_X, off_Y + 70);
    
    text(displayREC ? "REC" : "TEC", off_X - 15, off_Y + 60);
    
    // Ligne d'axe
    line(off_X, AY, AX, AY);
    triangle(AX, AY - 5, AX, AY + 5, AX + 10, AY);
    
    
    // X-coordinates
    final int AINCR = 15;
    
    for (float i = 0.0; i <= AINCR; ++i) {
        final String value = String.valueOf(int(0.1 * (sim.startRec + (i/AINCR) * (sim.stopRec - sim.startRec))));
        final String texte = (i == AINCR) ? value + " (ms)" : value;
        
        final float _t = off_X -10 + (i/AINCR) * (AX - off_X);
        
        text(texte, _t, AY + 25);
        
        // Graduation
        if (i < AINCR && i > 0) line(_t + 5 * value.length(), AY - 15, _t + 5 * value.length(), AY);
    }
    
    
    // Y-coordinates
    final int AINCR2 = 8;
    
    for (float i = 0.0; i <= AINCR2; ++i) {
        final String value = String.valueOf(int((i/AINCR2) * 255));
        
        final float _t = AY - (i/AINCR2) * GHEIGHT*0.8;
        
        text(value, off_X - 20 - 5 * value.length(), _t);
        
        // Graduation
        if (i < AINCR && i > 0) line(off_X + 0, _t - 5, off_X +10, _t - 5);
    }
    
    
    
    
    
    // --- Graph Core ---
    

    for (Node node: sim.nodes) {
        
        if (TLENGTH <= 0) {
            continue;
        }
        ++incr;
        
        
        // Affichage de quoi ?
        
        //final char[] seq = sim.rxRecs.get(node.id - 1).toCharArray();
        
        // --- Data ---
    
        ArrayList<Integer> recSeq = displayREC ? sim.recRecs.get(node.id - 1) : sim.tecRecs.get(node.id - 1);
        
        if (!endedPointAdded) {
            ArrayList<Integer> a = sim.tecRecs.get(node.id - 1);
            
            
            //a.add(sim.CYCLES);
            //a.add(a.get(a.size() - 2));
            
            a.add(sim.CYCLES);
            a.add(a.get(a.size() - 2));
            a.add(sim.CYCLES);
            a.add(a.get(a.size() - 2));
            
            
            ArrayList<Integer> b = sim.recRecs.get(node.id - 1);
            
            
            b.add(sim.CYCLES);
            b.add(b.get(b.size() - 2));//*/
            b.add(sim.CYCLES);
            b.add(b.get(b.size() - 2));//*/
        }
        
        
        // Get EC values
        //calc = new ArrayList<Integer>();
        
        float x = 0, x2 = 0;
        float y = 0, y2 = 0;
        
        final float GW = width - 3.5 * off_X;
        
        
        for (int i = 0; i < recSeq.size() - 4; i += 2) {
            
            //final int t = sim.startRec + i;
            int t = recSeq.get(i);
            int EC = recSeq.get(i + 1);
            
            
            int t2 = recSeq.get(i+2);
            int EC2 = recSeq.get(i + 3);
            
            
            //x = (i / (recSeq.size() / 1)) * GW;
            x = (float(t - sim.startRec) / TLENGTH) * GW;
            x2 = (float(t2 - sim.startRec) / TLENGTH) * GW;
            
            y = (float(EC) / 255) * (GHEIGHT*0.8);
            y2 = (float(EC2) / 255) * (GHEIGHT*0.8);
            
            
            // Draw two lines

            stroke(colors.get(incr - 1));
            //println("--- DEBUG ---", t, "--", x, "ù", x2);
            line(off_X + x, AY - y, off_X + x2, AY - y);
            
            line(off_X + x2, AY - y, off_X + x2, AY - y2);
        }

    }
    
    endedPointAdded = true;
    
    
    
    if (displayCursor) {
        stroke(cursorColor);
        line(mouseX, 0, mouseX, height);
    }

}









void draw() {
    
    background(#FFFFFF);
    
    if (displayGraph && sim.drawing && sim.displaying) {
        graph();
    }

    else if (sim.drawing && sim.displaying) {

        
        // RX
        
        text("Start time:  " + String.valueOf(sim.time_c(sim.startRec)) + " ms" + "         Stop time:  " + String.valueOf(sim.time_c(sim.stopRec)) + " ms" + "         Delta:  " + String.valueOf(sim.time_c(sim.stopRec) - sim.time_c(sim.startRec)) + " ms", 50, 40);
        //text("Stop time:  " + String.valueOf(sim.time_c(sim.stopRec)) + " ms", 70, 55);
        
        
        int incr = 0;
        int THICK = 50;
        final int off_X = 30;

        final int TLENGTH = sim.stopRec - sim.startRec;
        final float dStep = (width - 3.5 * off_X) / TLENGTH;

        for (Node node: sim.nodes) {
            
            if (TLENGTH <= 0) {
                continue;
            }
            
            ++incr;
            
            
            // Affichage de quoi ?
            
            if (displayEC) {
                
                THICK = 30;
                ArrayList<Integer> recSeq = sim.recRecs.get(node.id - 1);
                
                
                // Position des blocs contraintes
                
                ArrayList<Integer> blocks = new ArrayList<Integer>();
                blocks.add(0);
                blocks.add(4);
                
                int ta = blocks.get(0);
                int tb = blocks.get(1);
                int tval = recSeq.get(1);
                
    
            
                int x = 0;
                int y = 0;    // Binary
                final int off_Y = 110 * incr;
                
                text("Node " + String.valueOf(node.id) + " (REC)", off_X + 20, off_Y - 7);
                
                
                
                // Encadrement sur toute la ligne
                line(off_X, off_Y, off_X, off_Y + THICK); // Gauche
                line(off_X, off_Y + THICK * y, off_X + dStep * TLENGTH, off_Y + THICK * y); // Haut
                line(off_X + dStep * TLENGTH, off_Y + THICK * y, off_X + dStep * TLENGTH, off_Y + THICK * (y + 1)); // Droite
                line(off_X, off_Y + THICK, off_X + dStep * TLENGTH, off_Y + THICK); // Bas
                
                
                
                // Get EC values
                calc = new ArrayList<Integer>();
                
                for (int i = 0; i < TLENGTH; ++i) {
                    final int t = sim.startRec + i;
                    
                    // Extract 'EC from t value
                    int EC = recSeq.get(1);
                    
                    for (int j = 2; j + 1 < recSeq.size(); j += 2) {
                        if (t >= recSeq.get(j)) {
                            EC = recSeq.get(j + 1);
                        }
                        else {
                            break;
                        }
                    }
                    
                    calc.add(EC);
                }
                
                
                
                // Dessin en code barre ou en bloc
                
                for (int i = 0; i < TLENGTH; ++i) {

                    
                    // Bloc contrainte ?

                    if (i >= ta && i <= tb) {
                        continue;
                    }
                    

                    
                    final int EC = calc.get(i);
                    final float incr_X = i * dStep; // Position du curseur actuel

                    // Fin d'un bloc contrainte ?
                    
                    if (i == tb + 1) {
                        
                        // Etendre le bloc contrainte ?
                        if (EC == tval && i < TLENGTH - 1) {
                            ++tb;
                            continue;
                        }

                        final float BL_size = (tb - ta + 1) * dStep;
                        line(off_X + incr_X, off_Y, off_X + incr_X, off_Y + THICK);
                        
                        final String dispValue = String.valueOf(calc.get(ta));
                        text(dispValue, off_X + incr_X - BL_size / 2 - 5 * dispValue.length(), off_Y + THICK/1.35);
                    }
                    
                    
                    // Un bloc contrainte se créé si la valeur EC
                    // ne change pas pendant 7 cycles
                    
                    if (i + 6 < TLENGTH && calc.get(i + 6) == EC
                                        && calc.get(i + 5) == EC
                                        && calc.get(i + 4) == EC
                                        && calc.get(i + 3) == EC 
                                        && calc.get(i + 2) == EC 
                                        && calc.get(i + 1) == EC)
                    {
                        ta  = i;
                        tb = i + 6;
                        tval = EC;
                        
                        line(off_X + incr_X, off_Y, off_X + incr_X, off_Y + THICK);
                        continue;
                    }
                    
                    
                
                    
                    // .... sinon, on fait un "code barre"
                    
                    color cbarre = color(255, 150, 150);
                    final int delta = EC - calc.get(i - 1);//println("DELTA ", delta);
                    
                    if (delta > 0) {
                        if (delta < 8) {
                            cbarre = color(100, 20, 20);
                        }
                        else if (delta < 10) {
                            cbarre = color(150, 0, 0);
                        }
                        else {
                            cbarre = color(250, 0, 0);
                        }
                    }
                    else if (delta == 0) {
                        cbarre = color(30, 30, 100, 200);
                    }
                    else {
                        if (delta < -10) {
                            cbarre = color(250, 0, 0);
                        }
                        else if (delta < -8) {
                            cbarre = color(150, 0, 0);
                        }
                        else {
                            cbarre = color(50, 0, 0);
                        }
                    }
                    
                    fill(cbarre);
                    rect(off_X + incr_X, off_Y, dStep, THICK);
                    fill(textColor);
                }
            }
            else {
                final char[] seq = sim.rxRecs.get(node.id - 1).toCharArray();
    
            
                float x = 0;
                int y = 0;    // Binary
                final int off_Y = 110 * incr - 10;
                
                text("Node " + String.valueOf(node.id) + " (RX)", off_X + 20, off_Y - 7);
                
                textSize(13);
                text("0", off_X - 11, off_Y + 4);
                text("1", off_X - 11, off_Y + THICK + 2);
                textSize(20);
                
                for (char c : seq) {
                    
                    // Trait gris
                    stroke(color(150,150,150,80));
                    line(off_X + x + dStep, off_Y, off_X + x + dStep, off_Y + THICK);
                    
                    stroke(colors.get(incr - 1));
                    line(off_X + x, off_Y + THICK * y, off_X + x, off_Y + THICK * ((c == '0') ? 0 : 1));
                    y = (c == '0') ? 0 : 1;
                    
                    line(off_X + x, off_Y + THICK * y, off_X + x + dStep, off_Y + THICK * y);
                    x = x + dStep;
                }
            }
        }
        
        
        
        
        
        
        
        
        
        // TX
        
        for (Node node: sim.nodes) {
            
            if (TLENGTH <= 0) {
                continue;
            }
            
            ++incr;


            // Affichage de quoi ?
            
            if (displayEC) {
                
                ArrayList<Integer> tecSeq = sim.tecRecs.get(node.id - 1);
                
                // Position des blocs contraintes
                
                ArrayList<Integer> blocks = new ArrayList<Integer>();
                blocks.add(0);
                blocks.add(4);
                
                int ta = blocks.get(0);
                int tb = blocks.get(1);
                int tval = tecSeq.get(1);
                
    
            
                int x = 0;
                int y = 0;    // Binary
                final int off_Y = 110 * incr;
                
                text("Node " + String.valueOf(node.id) + " (TEC)", off_X + 20, off_Y - 7);
                
                
                
                // Encadrement sur toute la ligne
                line(off_X, off_Y, off_X, off_Y + THICK); // Gauche
                line(off_X, off_Y + THICK * y, off_X + dStep * TLENGTH, off_Y + THICK * y); // Haut
                line(off_X + dStep * TLENGTH, off_Y + THICK * y, off_X + dStep * TLENGTH, off_Y + THICK * (y + 1)); // Droite
                line(off_X, off_Y + THICK, off_X + dStep * TLENGTH, off_Y + THICK); // Bas
                
                
                
                // Get EC values
                calc = new ArrayList<Integer>();
                
                for (int i = 0; i < TLENGTH; ++i) {
                    final int t = sim.startRec + i;
                    
                    // Extract 'EC from t value
                    int EC = tecSeq.get(1);
                    
                    for (int j = 2; j + 1 < tecSeq.size(); j += 2) {
                        if (t >= tecSeq.get(j)) {
                            EC = tecSeq.get(j + 1);
                        }
                        else {
                            break;
                        }
                    }
                    
                    calc.add(EC);
                }
                
                
                
                // Dessin en code barre ou en bloc
                
                for (int i = 0; i < TLENGTH; ++i) {

                    
                    // Bloc contrainte ?

                    if (i >= ta && i <= tb) {
                        continue;
                    }
                    

                    
                    final int EC = calc.get(i);
                    final int incr_X = i * int(dStep); // Position du curseur actuel

                    // Fin d'un bloc contrainte ?
                    
                    if (i == tb + 1) {
                        
                        // Etendre le bloc contrainte ?
                        if (EC == tval && i < TLENGTH - 1) {
                            ++tb;
                            continue;
                        }

                        final int BL_size = (tb - ta + 1) * int(dStep);
                        line(off_X + incr_X, off_Y, off_X + incr_X, off_Y + THICK);
                        
                        final String dispValue = String.valueOf(calc.get(ta));
                        text(dispValue, off_X + incr_X - BL_size / 2 - 5 * dispValue.length(), off_Y + THICK/1.35);
                    }
                    
                    
                    // Un bloc contrainte se créé si la valeur EC
                    // ne change pas pendant 6 cycles
                    
                    if (i + 5 < TLENGTH && calc.get(i + 5) == EC
                                        && calc.get(i + 4) == EC
                                        && calc.get(i + 3) == EC 
                                        && calc.get(i + 2) == EC 
                                        && calc.get(i + 1) == EC)
                    {
                        ta  = i;
                        tb = i + 5;
                        tval = EC;
                        
                        line(off_X + incr_X, off_Y, off_X + incr_X, off_Y + THICK);
                        continue;
                    }
                    
                    
                
                    
                    // .... sinon, on fait un "code barre"
                    
                    color cbarre = color(150, 150, 150);
                    final int delta = EC - calc.get(i - 1);//println("DELTA ", delta);
                    
                    if (delta > 0) {
                        if (delta < 8) {
                            cbarre = color(100, 20, 20);
                        }
                        else if (delta < 10) {
                            cbarre = color(150, 0, 0);
                        }
                        else {
                            cbarre = color(250, 0, 0);
                        }
                    }
                    else if (delta == 0) {
                        cbarre = color(30, 30, 100, 200);
                    }
                    else {
                        if (delta < -10) {
                            cbarre = color(250, 0, 0);
                        }
                        else if (delta < -8) {
                            cbarre = color(150, 0, 0);
                        }
                        else {
                            cbarre = color(50, 0, 0);
                        }
                    }
                    
                    fill(cbarre);
                    rect(off_X + incr_X, off_Y, dStep, THICK);
                    fill(textColor);
                }
            }
            else {
                final char[] seq = sim.txRecs.get(node.id - 1).toCharArray();
        
                
                float x = 0;
                int y = 0;    // Binary
                final int off_Y = 110 * incr;
                
                
                
                text("Node " + String.valueOf(node.id) + " (TX)", off_X + 20, off_Y - 7);
                
                textSize(13);
                text("0", off_X - 11, off_Y + 4);
                text("1", off_X - 11, off_Y + THICK + 2);
                textSize(20);
                
                for (char c : seq) {
                    
                    // Trait gris
                    stroke(color(150,150,150,80));
                    line(off_X + x + dStep, off_Y, off_X + x + dStep, off_Y + THICK);
                    
                    stroke(colors.get(incr - 1));
                    line(off_X + x, off_Y + THICK * y, off_X + x, off_Y + THICK * ((c == '0') ? 0 : 1));
                    y = (c == '0') ? 0 : 1;
                    
                    line(off_X + x, off_Y + THICK * y, off_X + x + dStep, off_Y + THICK * y);
                    x = x + dStep;
                }
            }
        }
        
        
        
        // --- Gestion des axes ---
        
        final int AX = int(off_X + (dStep) * TLENGTH);
        final int AY = 110*incr + 100;
        
        
        // Ligne de début
        stroke(150,150,150);
        line(off_X, 0, off_X, AY);
        
        // Ligne d'axe
        line(off_X, AY, AX, AY);
        triangle(AX, AY - 5, AX, AY + 5, AX + 10, AY);
        
        
        // Valeurs d'axes
        final int AINCR = 15;
        
        for (float i = 0.0; i <= AINCR; ++i) {
            final String value = String.valueOf(int(0.1 * (sim.startRec + (i/AINCR) * (sim.stopRec - sim.startRec))));
            final String texte = (i == AINCR) ? value + " (ms)" : value;
            
            final float _t = off_X -10 + (i/AINCR) * (AX - off_X);
            
            text(texte, _t, AY + 25);
            if (i < AINCR && i > 0) line(_t + 5 * value.length(), AY - 15, _t + 5 * value.length(), AY);
        }
        
        
        
        
        if (displayCursor) {
            stroke(cursorColor);
            line(mouseX, 0, mouseX, height);
        }
    }
}



void keyReleased() {
    if (key == 'c') {
        displayCursor = !displayCursor;
    }
    else if (key == 'e' && sim.drawing && sim.displaying) {
        displayEC = !displayEC;
    }
    else if (key == 'g') {
        displayGraph = !displayGraph;
    }
    else if (key == 's') {
        displayREC = !displayREC;
    }
}


void launchSimulation() {
    sim.sm_start();
    
    ArrayList<Integer> recNode3 = sim.recRecs.get(3 - 1);
    
    for (int h = 0; h < recNode3.size(); ++h) {
        print(recNode3.get(h), "/");
    }
    
    println(" ");
    println("THREAD ENDED");
}
