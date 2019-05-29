import nub.timing.*;
import nub.primitives.*;
import nub.core.*;
import nub.processing.*;

// 1. Nub objects
Scene scene;
Node node;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;
boolean raster = true;
boolean aliasing = false;
boolean shading = true;


// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

// 4. Window dimension
int dim = 10;

void settings() {
  size(int(pow(2, dim)), int(pow(2, dim)), renderer);
}

void setup() {
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fit(1);

  // not really needed here but create a spinning task
  // just to illustrate some nub.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the node instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    @Override
    public void execute() {
      scene.eye().orbit(scene.is2D() ? new Vector(0, 0, 1) :
        yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100);
    }
  };
  scene.registerTask(spinningTask);

  node = new Node();
  node.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow(2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(node);
  triangleRaster();
  popStyle();
  popMatrix();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the node systeddm which has a dimension of 2^n
float edgeFuction(float v1x, float v1y, float v2x, float v2y, float px,float py){
return (((v2x-v1x)*(py-v1y))-((v2y-v1y)*(px-v1x)));
}

// Verificamos si un punto esta dentro o no del triangulo
boolean inside_triangle(float ax, float ay, float bx, float by, float cx, float cy, float x, float y)
{
  float d = (by - cy) * (ax - cx) + (cx - bx) * (ay - cy);
  float alpha = ((by-cy)*(x-cx)+(cx-bx)*(y-cy)) / d;
  float beta = ((cy-ay)*(x-cx)+(ax-cx)*(y-cy)) / d;
  float gamma = 1.0 - alpha - beta;

  return !(alpha < 0 || alpha > 1 || beta < 0 || beta > 1 || gamma < 0 || gamma > 1);
}



// Implement this function to rasterize the triangle.
// Coordinates are given in the node system which has a dimension of 2^n
void triangleRaster() {
  // node.coordinatesOf converts from world to node
  
  float v1x = node.location(v1).x();
  float v1y = node.location(v1).y();
  float v2x = node.location(v2).x();
  float v2y = node.location(v2).y();
  float v3x = node.location(v3).x();
  float v3y = node.location(v3).y();  
  // Valores minimo y maximo de los pixeles en el triangulo
  int minx=round(min(v1x,v2x,v3x));
  int miny=round(min(v1y,v2y,v3y));
  int maxx=round(max(v1x,v2x,v3x));
  int maxy=round(max(v1y,v2y,v3y));

  
  if (debug) {
    pushStyle();    
    stroke(255, 255, 0, 125);
    //point(round(node.coordinatesOf(v1).x()), round(node.coordinatesOf(v1).y()));
    // Vector 1 rojo
    stroke(255, 0, 0);
    point(round(v1x),round(v1y));
    // Vector 2 verde
    stroke(0, 255, 0);
    point(round(v2x),round(v2y));
    // Vector 3 azul
    stroke(0, 0, 255);    
    point(round(v3x),round(v3y));
    
      
   //strokeWeight(0);
   //fill(255,0,255);
   
   int paso=4;
  for(int x=minx; x<maxx; x++){
    for(int y=miny; y<maxy; y++){
      //funciones de los ejes
        float f12;
        float f23;
        float f31;
        //area del trapezoide
        float areax2;
        // Pesos normalizados
        float w1;
        float w2;
        float w3;
        // Colores 
        float color1=0.0;
        float color2=0.0;
        float color3=0.0;
        noStroke();
        // Verificamos cada pixel
             
        for(float subx=0; subx<1; subx+=(float)1/paso){
          for(float suby=0; suby<1; suby+=(float)1/paso){                       
            if (inside_triangle(v1x, v1y, v2x,v2y,v3x,v3y,(x+subx),(y+suby))){
              
              f12 = edgeFuction(v1x,v1y,v2x,v2y,(x+subx),(y+suby));
              f23 = edgeFuction(v2x,v2y,v3x,v3y,(x+subx),(y+suby));
              f31 = edgeFuction(v3x,v3y,v1x,v1y,(x+subx),(y+suby));
              areax2=abs(f12)+abs(f23)+abs(f31);
              
              w1= (f23)/areax2;
              w2=(f31)/areax2;
              w3=(f12)/areax2;
              
              color1+= abs(w1*255);
              color2+= abs(w2*255);
              color3+= abs(w3*255);
              
            } 
          }
        }      
        
        color1 /= Math.pow(paso,2);
        color2 /= Math.pow(paso,2);
        color3 /= Math.pow(paso,2);
        fill(round(color1),round(color2),round(color3));
        rect(x,y,1,1);
        
    }
  }  
  popStyle();
    
  }
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 10 ? n+1 : 2;
    node.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    node.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
}
