double zoomHorizon;
double zoomVert;
double centerX = 0, centerY = 0;
boolean save = false;
int[] grid;
int[] Rg;
int[] Gg;
int[] Bg;
int start; 
int mset;

void setup() {
  start = millis();
  size(1000, 1000);
  background(0);
  zoomHorizon = 3.0;
  zoomVert = 3.0 / ((double)width / (double)height);

  grid = new int [height * width];     
  grid = mandelGrid(5000, grid, true);  
  //reColour(grid); //display mandelbrot set for debug  
  mset = millis()-start; 
  println("Checked points: "+mset+"ms");
  
  //startNMode(); //normal mode
  startLRMode(); //lower-ram usage mode
}

void keyPressed() {
  if (key == 's') {
    save(str(width)+"x"+str(height)+"x"+str(round(millis()))+".png");
    println("saved");
  }
}

void draw() {  
  noLoop();
}

//starts normal mode
void startNMode() {
  Rg = new int[height * width];
  Gg = new int[height * width];
  Bg = new int[height * width];
  Rg = rPI(5000, p(1, 6), grid, false);
  Gg = rPI(500, p(1, 6), grid, false);
  Bg = rPI(50, p(1, 6), grid, false);

  int Calc = millis() - start - mset; 
  println("Calculated trajectories: "+Calc+"ms");

  falseColor(Rg, Gg, Bg); //only for normal mode

  int Color = millis() - start - (Calc + mset);
  println("Calculated colour: "+Color+"ms");
  if (save) {
    save(str(width)+"x"+str(height)+"x"+str(round(millis()))+".png"); //autosave the image
    println("Saved: "+(millis() - (Calc + mset + Color) - start)+"ms");
  }
  println("Total: "+(millis() - start)+"ms");
}

//starts lower-ram usage mode
void startLRMode() {
  falseColor(rPI(5000, p(1, 6), grid, false), "R");
  falseColor(rPI(500, p(1, 6), grid, false), "G");
  falseColor(rPI(50, p(1, 6), grid, false), "B");
  
  int PAF = millis() - start - mset;
  println("Filled pixels: "+PAF+"ms");
  
  if (save) {
    save(str(width)+"x"+str(height)+"x"+str(round(millis()))+".png"); //autosave the image
    println("Saved: "+(millis() - PAF - mset - start)+"ms");
  }
  println("Total: "+(millis() - start)+"ms");
}

int p(int mul, int pow) {
  return mul * (int)pow(10, pow);
}
