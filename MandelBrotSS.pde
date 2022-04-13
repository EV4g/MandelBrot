double zoom;
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
int dim;
int Rn;
int Gn;
int Bn;
String path;

void settings() {
  save = false;     //save output to .tif file
  lowram = true;    //use lower ram-usage mode
  output = true;    //output result to canvas
  mLookUp = true;   //mandelbrot-lookup-array or on-the-fly setcalculation //not yet implemented
  dim = 1000;
  Rn = 5000;        //number of checked iterations per band
  Gn = 500;
  Bn = 50;
  if (output) {
    size(dim, dim);
  }
}

void setup() {  
  path = sketchPath();
  noLoop();
  start = millis();
  zoom = 3.0;
  mandelbrot = new boolean [dim * dim];
  mandelGrid(5000); //calculate in/out for all points  
  mset = millis()-start; 
  println("Checked points: "+mset+"ms");

  img = new PImage(dim, dim);

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
    img.save(path+"/"+str(dim)+"x"+str(dim)+"x"+str(round(millis()))+".tif");
    println("saved");
  }
}

//starts normal mode
void startNMode() {
  int[] Rg = rPIn(Rn, p(1, 7), false);
  int[] Gg = rPIn(Gn, p(1, 7), false);
  int[] Bg = rPIn(Bn, p(1, 7), false);

  int Calc = millis() - start - mset; 
  println("Calculated trajectories: "+Calc+"ms");

  falseColor(Rg, Gg, Bg);

  int Color = millis() - start - (Calc + mset);
  println("Calculated colour: "+Color+"ms");
  if (save) {
    img.save(path+"/"+str(dim)+"x"+str(dim)+"x"+str(round(millis()))+".tif");
    println("Saved: "+(millis() - (Calc + mset + Color + start))+"ms");
  }
}

//starts lower-ram usage mode
void startLRMode() {
  storageGrid = new int[dim * dim];
  rPI(Rn, p(1, 7), false);   //fill grid for R  
  falseColor(16);            //update pixels[] with storageGrid and << by offset
  rPI(Gn, p(1, 7), false);
  falseColor(8);
  rPI(Bn, p(5, 7), false);
  falseColor(0);

  int PAF = millis() - start - mset;
  println("Filled pixels: "+PAF+"ms");

  if (save) {
    img.save(path+"/"+str(dim)+"x"+str(dim)+"x"+str(round(millis()))+".tif"); //autosave the image
    println("Saved: "+(millis() - (PAF + mset + start))+"ms");
  }
}

int p(float mul, int pow) {
  return (int)(mul * (int)pow(10, pow));
}
