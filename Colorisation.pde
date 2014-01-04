import processing.pdf.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

/* BASIC INIT */
int duration;
int f;
String[] data;
int[] remplissage;
String bin;
String default_couleur = "e6e6e6";
Integer[] tmp_couleur = new Integer[3];
int resultat;
boolean debug = false;

/* AUDIO */
Minim minim;
AudioInput in;
FFT fft;

/* AFFICHAGE */
int padding   = 0;
int longeur   = 1;
int epaisseur = 1;
float offset  = 0;
float angle;
int rayon;

void setup() {  
  
  rayon     = round(displayHeight/4-10);
  //println(rayon);
//duration = 50000;
  duration = 478000;   // 900'000 = 15 Minutes
  f        = 8;        // 08 frames/s = 1 couleur/s 
  bin      = "";       // Empty binary
  
  noStroke();
  size(1000, 1000);
  //size(displayWidth, displayHeight);
  frameRate(f);
  
  // Audio setup
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 4096, 44100);
  fft=new FFT(in.bufferSize(), in.sampleRate());
  
  // Dimentionnement de data[]
  int data_length = round(duration/3000);
  data = new String[data_length];
  remplissage = new int[data_length];
  
  println(data.length);
  println(remplissage.length);

  angle = TWO_PI/(float)data.length;
  
  // Affichage
  for (int i=0; i<data_length; i++) {
    data[i]=default_couleur;
    remplissage[i] = 0;
  }
}

void draw() {
  background(#FFFFFF);
  fft.forward(in.mix);

  if (audioEvent()) {
    bin+="1";
    if(debug) {
      textSize(18);
      fill(125);
      text("•", 40, 40);
    }
  }
  else bin+="0";

  if(debug) {
    fill(125);
    textSize(18);
    textAlign(LEFT);
    text("R : "+tmp_couleur[0], 60, height-40);
    text("V : "+tmp_couleur[1], 160, height-40);
    text("B : "+tmp_couleur[2], 260, height-40);
    textAlign(RIGHT);
    text(getNextColor()+" / "+remplissage.length, width-40, 40);
    textAlign(CENTER);
    text(bin, width/2, height/2); 
  }

  // Routine
  if (bin.length()==8) {
    tmp_couleur[nextColor()]=int(unbinary(bin));
    bin="";
  }
  
  if (nextColor()==3) { // RVB Complet
     data[getNextColor()]=hex(color(tmp_couleur[0], tmp_couleur[1], tmp_couleur[2]),6); 
     remplissage[getNextColor()]=1;
     
     // R.A.Z. TMP
     bin="";
     tmp_couleur[0] = null;
     tmp_couleur[1] = null;
     tmp_couleur[2] = null;
  }

  for(int i=0; i<data.length; i=i+1) {
    fill(unhex("FF"+data[i])); noStroke();
    
//    triangle(rayon*cos(angle*(i-1))+width/2+offset, rayon*sin(angle*(i-1))+height/2+offset, rayon*cos(angle*(i))+width/2+offset, rayon*sin(angle*(i))+height/2+offset,  rayon/1.5*cos(angle*(i-1))+width/2, rayon/1.5*sin(angle*(i-1))+height/2);
    ellipseMode(CENTER);
    ellipse(rayon*cos(angle*(i-1))+width/2, rayon*sin(angle*(i-1))+height/2, 10, 10);
  }
  
  if(remplissage[remplissage.length-1]==1) {
       complete(); 
  }
  
}

boolean audioEvent () {
   for(int i = 0; i < fft.specSize(); i++)
  {
    if (fft.getFreq(i) > 10) { // remplacer 10 par var poto pour régler. 10 OK dans studio
      return true;
    }
  }
  return false;
}

int nextColor () {
   if(tmp_couleur[0] == null) return 0;
   else if (tmp_couleur[1] == null) return 1;
   else if (tmp_couleur[2] == null) return 2;
   else return 3;  // RVB complet
}

int getNextColor() {
  for (int i=0; i<remplissage.length; i++) {
    if(remplissage[i]==1) {
       resultat=i; 
    }
  }
  return resultat+1;
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
     debug ^= true;
  }
}

void complete () {
   println("Done.");
   noLoop();
   fill(#ffffff); noStroke();
   beginRecord(PDF, "pdf/takemura.pdf");
   for(int i=0; i<data.length; i=i+1) {
    fill(unhex("FF"+data[i])); noStroke();
    ellipse(rayon*cos(angle*(i-1))+width/2, rayon*sin(angle*(i-1))+height/2, 10, 10);
    //triangle(rayon*cos(angle*(i-1))+width/2+offset, rayon*sin(angle*(i-1))+height/2+offset, rayon*cos(angle*(i))+width/2+offset, rayon*sin(angle*(i))+height/2+offset,  rayon/1.5*cos(angle*(i-1))+width/2, rayon/1.5*sin(angle*(i-1))+height/2);
  }
  endRecord();
}
