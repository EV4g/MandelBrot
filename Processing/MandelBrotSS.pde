double zoom = 3.0;
double centerX = 0, centerY = 0;
boolean save;
boolean lowram;
boolean output;
boolean mLookUp;
PImage img;
boolean[] mandelbrot;
int[] storageGrid;
int start; 
int mset;
int rdim;
int odim;
int fac;
int Rn;
int Gn;
int Bn;
int mandelmax;
String path;
double minX, minY;
int[] Rg;
int[] Gg;
int[] Bg;


void settings() {
  save = false;     //save output to .tif file
  lowram = true;    //use lower ram-usage mode
  output = true;    //output result to canvas
  mLookUp = true;   //mandelbrot-lookup-array or on-the-fly setcalculation //not yet implemented
  rdim = 1000;      //render resolution
  odim = 1000;      //output resolution
  Rn = 5000;        //number of checked iterations per band
  Gn = 500;
  Bn = 50;
  mandelmax = 5000;
  if (output) {
    size(odim, odim);
  }
}

void setup() {
  fac = rdim / odim;
  minX = centerX - zoom/2; 
  minY = centerY - zoom/2;
  path = sketchPath();
  noLoop();
  start = millis();
  if(mLookUp){
    mandelbrot = new boolean [rdim * rdim];
    mandelGrid(mandelmax); //calculate in/out for all points  
  }
  mset = millis()-start; 
  println("Checked points: "+mset+"ms");

  img = new PImage(odim, odim);
  
  if (!lowram) {
    startNMode();  //normal mode
  } else {
    init();        //initialize PImage by setting values to -1<<24
    startLRMode(); //lower-ram usage mode
  }
  if (output) {
    image(img, 0, 0);
  }
  
  println("Total: "+(millis() - start)+"ms");
  println("Done");
}

void keyPressed() {
  if (key == 's') {
    img.save(path+"/"+str(rdim)+"x"+str(rdim)+"x"+str(round(millis()))+".tif");
    println("saved");
  }
}

//starts normal mode
void startNMode() {
  Rg = rPIn(Rn, p(1, 8), false);
  Gg = rPIn(Gn, p(1, 8), false);
  Bg = rPIn(Bn, p(5, 8), false);

  int Calc = millis() - start - mset; 
  println("Calculated trajectories: "+Calc+"ms");

  falseColor();

  int Color = millis() - start - (Calc + mset);
  println("Calculated colour: "+Color+"ms");
  if (save) {
    img.save(path+"/"+str(rdim)+"x"+str(rdim)+"x"+str(round(millis()))+".tif");
    println("Saved: "+(millis() - (Calc + mset + Color + start))+"ms");
  }
}

//starts lower-ram usage mode
void startLRMode() {
  storageGrid = new int[rdim * rdim];
  rPI(Rn, p(1, 6));   //fill grid for R  
  falseColor(16);     //update pixels[] with storageGrid and << by offset
  rPI(Gn, p(1, 6));
  falseColor(8);
  rPI(Bn, p(5, 6));
  falseColor(0);

  int PAF = millis() - start - mset;
  println("Filled pixels: "+PAF+"ms");

  if (save) {
    img.save(path+"/"+str(rdim)+"x"+str(rdim)+"x"+str(round(millis()))+".tif"); //autosave the image
    println("Saved: "+(millis() - (PAF + mset + start))+"ms");
  }
}

int p(float mul, int pow) {
  return (int)(mul * (int)pow(10, pow));
}
