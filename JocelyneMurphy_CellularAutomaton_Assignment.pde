//Change These Values
int n = 60; //for best results, choose a number between 30 and 80
float blinksPerSecond = 50;
float lightningThreshold = 15; //number of particles at the bottom of the cloud before lightning strikes
int particleConcentration = 30; // one in every (ParticleConcentration) will be a particle to start.
int chargeOdds = 1000; // odds that when particles collide a charge will be generated. A higher chargeOdds = lower chance.
float stormSeverity = 100; //chose a number between 1 (mild) and 100 (severe)
int framecount = 0;

//Don't change these values
boolean[][] boom = new boolean[n][n];
int[][] cells = new int[n][n];
int[][] cellsNext = new int[n][n];
int[][] xSpeeds = new int[n][n];
int[][] xSpeedsNext = new int[n][n];
int[][] ySpeeds = new int[n][n];
int[][] ySpeedsNext = new int[n][n];
float cellSize;
boolean strike = true ;
color neutralParticle = color(120-stormSeverity),  
negParticle = color(255,255,200), posParticle = color(200,255,200);


void setup(){ //FINISHED
  size(800,800, P3D); 
  frameRate( blinksPerSecond * (1 + 1/stormSeverity) ); //a more severe storm will make the animation go faster
  noStroke();
  cellSize = (width)/float(n);
  //twocells();
  plantFirstGeneration();
}        

void scrubNext() {  //CLEARS THE NEXT-GENERATION ARRAYS SO THEY DON'T MIX UP OLD DATA WITH NEW DATA
  cellsNext = new int[n][n];
  xSpeedsNext = new int[n][n];
  ySpeedsNext = new int[n][n];
}


void setNextGeneration() {
  scrubNext(); 
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      if (cells[i][j] > 0) { // if the cell is a particle (not atmosphere)  
        if (cells[i][j] ==4)
          cells[i][j] =1;
        if (cells[i][j] == 2){ //if a green particle has reached the top of the screen, hold it there.
         if((i==3 && ySpeeds[i][j] == 1)|| i==0 && ySpeeds[i][j] == -1){ //in row i = 3 and row i = n-1 (top row), reverse direction
            ySpeeds[i][j] = -1*ySpeeds[i][j];
          }
        }  
        else if (cells[i][j] == 3){ //if a yellow particle has reached the bottom of the screen, hold it there.
         if((i==n-4 && ySpeeds[i][j] == -1)|| i==n && ySpeeds[i][j] == 1){
            ySpeeds[i][j] = -1*ySpeeds[i][j];
          }
        }
        
        //BOUNCING OFF WALLS
            if((j == n-1 && xSpeeds[i][j] == 1)|| (j == 0 && xSpeeds[i][j] == -1)) //if the cell in the outer row contains any type of particle 
              xSpeeds[i][j] = -1*xSpeeds[i][j]; //change directions to 'bounce' off the wall
            if((i==n-1 && ySpeeds[i][j] == 1)||(i==0 && ySpeeds[i][j] == -1))
              ySpeeds[i][j] = -1*ySpeeds[i][j];
        
        if (cells[i][j] == 1) //only check for collisions if a particle doesnt already have a charge
          detectCollisions(i,j);
          
        try { 
            //ASSIGNING NEW SPEEDS TO CELLS (MATCHING THE SPEED OF THE PARTICLE REGARDLESS OF WHAT CELL IT IS IN)
            int iNext = i + ySpeeds[i][j]; // the next i
            int jNext = j + xSpeeds[i][j]; // the next j 
            
            cellsNext[iNext][jNext] = cells[i][j]; // make the next frame location of the cell a neutral particle
            xSpeedsNext[iNext][jNext] = xSpeeds[i][j]; //assign the next frame version of the cell the same speeds as it had in the previous frame
            ySpeedsNext[iNext][jNext] = ySpeeds[i][j];
            
            
         }
            
          catch( Exception e) { // if the location of iNext and jNext is off screen
            cellsNext[i][j] = 0; //make the next frame neutral atmosphere (particle dissapeared)
            xSpeedsNext[i][j] = 0; //delete speed for that frame (no particle there anymore)
            ySpeedsNext[i][j] = 0;
          }
      }
      }
    }
  }

void detectCollisions(int i, int j){
  for( i=0; i<n; i++) {
    for( j=0; j<n; j++) {
      if (cells[i][j] > 0) { // if the cell is a particle (not atmosphere)
        //DETECTING COLLISIONS 
        for(int a = -1; a<= 1; a++){ //for all surrounding cells
          for(int b = -1; b <=1;b++){
            try{
              if((cells[i+a][j+b] > 0) && cells[i][j] > 0 && !(a==0 && b==0)){ //if the current cell is a particle and surrounding cells (not including the current cell and only including those touching along edges and not corners) are particles
                boom[i][j] = true;
                float posneg = random(0,chargeOdds*(1/stormSeverity)); //in more severe storms, the odds of charges being generated increase
                if (posneg <1 && posneg < 0.6 ){ //chance that the particle will become negative
                  xSpeeds[i][j]=0; // stop motion in the horizontal direction
                  ySpeeds[i][j] = 1; //travel to bottom
                  cells[i][j] = 3; //negative particle 
                }
                else if (posneg <1 && posneg > 0.6 ) {//chance that the particle will become postive
                  xSpeeds[i][j]=0; // stop motion in the horizontal direction
                  ySpeeds[i][j] = -1; //travel to top
                  cells[i][j] = 2;
                }
              }
              else
                boom[i][j] = false;
            }
            catch(Exception e){
            }
          }
        }
      }
    }
  }
}

void draw() {
  color fillColour = 0;
  background(255);
  float y = 0;
  println();
  println("FRAME = ", framecount);
  println();
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      float x = j*cellSize;
       
      
      if (numBottomCharges()){
          fillColour = color(255);
      }
        
      //COLOUR TRANSLATOR
      else if (cells[i][j] == 0)
        fillColour = color(random(160-stormSeverity,180-stormSeverity));
      else if (cells[i][j] == 1)
        fillColour = neutralParticle;
      else if (cells[i][j] == 2)
        fillColour = posParticle;
      else if (cells[i][j] == 3)
        fillColour = negParticle;
      else if (cells[i][j] == 4)
        fillColour = color(255);
      
      stroke(fillColour);  
      fill(fillColour);        
      rect(x, y, cellSize, cellSize);
      
      //if (numBottomCharges())
        //plantFirstGeneration();
    }
    
    y += cellSize;
  }
  framecount +=1;
  setNextGeneration();
  copyNextGenerationToCurrentGeneration();
  //noLoop();
}

boolean numBottomCharges(){
  
  if (strike ==true){
    strike = false;
    plantFirstGeneration();
  }
         
  else{
  int count = 0;
  for (int i = n-2; i < n; i++) 
     for (int j = 0; j < n; j++) {
        if(cells[i][j] == 3)
          count++;
     }
  //println(count++);
  if(count>lightningThreshold)
    strike = true;
 // print(strike);
  }
  println(strike);
  return strike;
}

void plantFirstGeneration() { 
    framecount = 0;
    strike = false;
    for (int i = 0; i < n; i++) 
        for (int j = 0; j < n; j++) {
           int rand = int(random(0, particleConcentration)); //1 in 30 cells will be a particle
           
           if (rand==0) { //IF THE CELL IS A PARTICLE...
             cells[i][j]  = 4; // set the colour to particle colour
             
             float b = random(0,1);
             if (b > 0.4) //50% chance that the cell will go left, 50% right
               xSpeeds[i][j] = 1; //number of cells that coloured cell moves over
             else
               xSpeeds[i][j] = -1;
               
             float c = random(0,1);
             if (c > 0.4) // 50% chance up down
               ySpeeds[i][j] = 1;
             else
               ySpeeds[i][j] = -1;
           }
           
           else { // if the cell is not a particle
             cells[i][j] = 0; // set colour to atmosphere
             xSpeeds[i][j] = 0; // set speeds to 0
             ySpeeds[i][j] = 0;
           }
        }    
}

void copyNextGenerationToCurrentGeneration() { 
    for(int i=0; i<n; i++) 
      for(int j=0; j<n; j++) {
        cells[i][j] = cellsNext[i][j]; //copies the next state of cells into the drawn set of cells 
        xSpeeds[i][j] = xSpeedsNext[i][j]; //copies next next speeds to drawn speeds
        ySpeeds[i][j] = ySpeedsNext[i][j]; //(this is neccessary because the speed of a cell must move with the colour)
      }
}
