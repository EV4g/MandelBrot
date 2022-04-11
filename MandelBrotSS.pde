double zoomHorizon;
double zoomVert;
double centerX = 0, centerY = 0;
boolean save = false;
boolean lowram = true;
PImage img;
boolean[] mandelbrot;
int[] storageGrid;
int[] Rg;
int[] Gg;
int[] Bg;
int start; 
int mset;
int xdim;
int ydim;

void setup() {
  xdim = 1000;
  ydim = 1000;
  noLoop();
  start = millis();
  zoomHorizon = 3.0;
  zoomVert = 3.0 / ((double)xdim / (double)ydim);
  mandelbrot = new boolean [ydim * xdim];
  mandelGrid(5000); //calculate in/out for all points  
  mset = millis()-start; 
  println("Checked points: "+mset+"ms");
  
  if(!lowram){
    size(1000, 1000);
    background(0);
    startNMode(); //normal mode
  } else {
    img = new PImage(xdim, ydim);
    startLRMode(); //lower-ram usage mode
  }
  println("Total: "+(millis() - start)+"ms");
}

void keyPressed() {
  if (key == 's') {
    if(!lowram){
      save(str(xdim)+"x"+str(ydim)+"x"+str(round(millis()))+".tif");
    } else {
      img.save(str(xdim)+"x"+str(ydim)+"x"+str(round(millis()))+".tif");
    }
    println("saved");
  }
}

//starts normal mode
void startNMode() {
  Rg = new int[ydim * xdim];
  Gg = new int[ydim * xdim];
  Bg = new int[ydim * xdim];
  Rg = rPIn(5000, p(1, 7), false);
  Gg = rPIn(500, p(1, 7), false);
  Bg = rPIn(50, p(1, 7), false);

  int Calc = millis() - start - mset; 
  println("Calculated trajectories: "+Calc+"ms");

  falseColor(Rg, Gg, Bg);

  int Color = millis() - start - (Calc + mset);
  println("Calculated colour: "+Color+"ms");
  if (save) {
    save(str(xdim)+"x"+str(ydim)+"x"+str(round(millis()))+".tif");
    println("Saved: "+(millis() - (Calc + mset + Color + start))+"ms");
  }
}

//starts lower-ram usage mode
void startLRMode() {
  storageGrid = new int[ydim * xdim];
  rPI(5000, p(1, 8), false);   //fill grid for R  
  falseColor("R");             //update pixels[] with grid
  rPI(500, p(1, 8), false);
  falseColor("G");
  rPI(50, p(5, 8), false);
  falseColor("B");
  
  int PAF = millis() - start - mset;
  println("Filled pixels: "+PAF+"ms");
  
  if (save) {
    save("testmap/"+str(xdim)+"x"+str(ydim)+"x"+str(round(millis()))+".tif"); //autosave the image
    println("Saved: "+(millis() - (PAF + mset + start))+"ms");
  }
}

int p(float mul, int pow) {
  return (int)(mul * (int)pow(10, pow));
}
