/*  PATHFINDER ALGORITHMS
 *  Ira Winder, ira@mit.edu
 *  Coded w/ Processing 3 (Java)
 *
 *  The Main Tab "PathfinderBasic" shows an example implementation of 
 *  algorithms useful for finding shortest pathes snapped to a gridded 
 *  network. Explore the 'classes' tab to see how they work.
 */

// Objects to define our Network
//
ObstacleCourse oCourse;
RasterCourse rCourse;
RoadNetwork rNetwork;
Graph network;
Pathfinder finder;

//  Object to define and capture a specific origin, destiantion, and path
//
ArrayList<Path> paths;

//  Objects to define agents that navigate our environment
//
ArrayList<Agent> people;

String roadFile = "city/roads";
String imageFile = "Walls-Level4";
//String imageFile = "city/roads";
String fileName;

//float latCtr = +42.350;
//float lonCtr = -71.066;
//float tol    =  0.035;
//float latMin = latCtr - tol;
//float latMax = latCtr + tol;
//float lonMin = lonCtr - tol;
//float lonMax = lonCtr + tol;

boolean showFrameRate = false;

void initEnvironment() {
  //  A Road Network Created from a QGIS File
  //
  // Use this function rarely when you need to clean a csv file. It saves a new file to the data folder
  //rNetwork = new RoadNetwork(roadFile + ".csv", latMin, latMax, lonMin, lonMax); 
  //
  rNetwork = new RoadNetwork(roadFile + ".csv");
  
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 5;  // pixels
  int graphWidth = width;   // pixels
  int graphHeight = height; // pixels
  network = new Graph(graphWidth, graphHeight, nodeResolution, rNetwork);
  //network.cullRandom(0.5); // Randomly eliminates 50% of the nodes in the network
  
  fileName = "mesh_scale_" + network.SCALE + "_" + imageFile + ".tsv";
  
  /*
  // An example boundary condition defined by a grayscale image sized within the canvas area
  //FORMAT: RasterCourse(PImage raster, float threshold, float radius, int rX, int rY, int rW, int rH)
  //
  PImage courseImage = loadImage(imageFile + ".png");
  float threshold = 0.5; // 0.0 - 1.0: grayscale threshold for positive reading
  float sensitivity = 0.9; // 0.0 - 1.0: percent of pixels in search area needed for positive read
  float searchRadius = nodeResolution; // pixels around each node to search
  int rasterX = 20;
  int rasterY = 100;
  int rasterW = width  - 2*rasterX;
  int rasterH = height - 2*rasterY;
  rCourse = new RasterCourse(courseImage, sensitivity, threshold, searchRadius, rasterX, rasterY, rasterW, rasterH);
  rCourse.invert();
  network.applyCourse(rCourse);
  */
}

void initPaths() {
  //  An example pathfinder object used to derive the shortest path
  //  setting enableFinder to "false" will bypass the A* algorithm
  //  and return a result akin to "as the bird flies"
  //
  finder = new Pathfinder(network);
  
  //  FORMAT 1: Path(float x, float y, float l, float w)
  //  FORMAT 2: Path(PVector o, PVector d)
  //
  paths = new ArrayList<Path>();
  Path p;
  PVector origin, destination;
  for (int i=0; i<1000; i++) {
    //  An example Origin and Desination between which we want to know the shortest path
    //
    int rand1 = int( random(network.nodes.size()));
    int rand2 = int( random(network.nodes.size()));
    origin      = network.nodes.get(rand1).loc;
    destination = network.nodes.get(rand2).loc;
    p = new Path(origin, destination);
    p.solve(finder);
    paths.add(p);
  }
}

void findPaths() {
  finder = new Pathfinder(network);
  
  for (Path p: paths) {
    p.solve(finder);
  }
  
  initPopulation();
}

void initPopulation() {
  //  An example population that traverses along shortest path calculation
  //  FORMAT: Agent(x, y, radius, speed, path);
  //
  Agent person;
  PVector loc;
  int random_waypoint;
  float random_speed;
  people = new ArrayList<Agent>();
  Path random;
  for (int i=0; i<2000; i++) {
    random = paths.get( int(random(paths.size())) );
    if (random.waypoints.size() > 1) {
      random_waypoint = int(random(random.waypoints.size()));
      random_speed = 1.0*random(0.1, 0.3);
      loc = random.waypoints.get(random_waypoint);
      person = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints);
      people.add(person);
    }
  }
}

void setup() {
  size(1000, 1000);
  //fullScreen();
  initEnvironment();
  //try {
  //  loadMesh();
  //} catch(RuntimeException e){
  //  println("Network file not found. Try saving one first.");
  //}
  initPaths();
  initPopulation();
}

void draw() {
  background(0);
  
  //Displays the RasterCourse grpahic
  //
  //tint(255, 100); // overlaid as an image
  //image(rCourse.raster, rCourse.rX, rCourse.rY, rCourse.rW, rCourse.rH);
  //stroke(255);
  //noFill();
  //rect(rCourse.rX, rCourse.rY, rCourse.rW, rCourse.rH);
  
  //  Displays the Graph in grayscale.
  //
  tint(255, 75); // overlaid as an image
  image(network.img, 0, 0);
  
  //  Displays the path last calculated in Pathfinder.
  //  The results are overridden everytime findPath() is run.
  //  FORMAT: display(color, alpha)
  //
  //boolean showVisited = false;
  //finder.display(100, 150, showVisited);
  
  //  Displays the path properties.
  //  FORMAT: display(color, alpha)
  //
  //for (Path p: paths) {
  //  p.display(100, 20);
  //}
  //for (int i=0; i<paths.size(); i+=5) {
  //  paths.get(i).display(100, 20);
  //}
  
  //  Update and Display the population of agents
  //  FORMAT: display(color, alpha)
  //
  boolean collisionDetection = true;
  for (Agent p: people) {
    p.update(personLocations(people), collisionDetection);
    p.display(#FFFF00, 200);
  }
  
  textAlign(CENTER, CENTER);
  fill(255);
  textAlign(LEFT, TOP);
  String fRate = "";
  if (showFrameRate) fRate = "\nFramerate: " + frameRate;
  text("Press 'r' to regenerate OD matrix\n" +
       "Click mouse to manually add or remove a node\n" +
       "Press 's' and 'l' to save and load graph-mesh to CSV file\n" +
       "Press 'c' to clear any manual edits to mesh\n" +
       fRate, 20, 20);
  
}

ArrayList<PVector> personLocations(ArrayList<Agent> people) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: people) {
    l.add(a.location);
  }
  return l;
}

void keyPressed() {
  switch(key) {
    case 'r':
      initPaths();
      initPopulation();
      break;
    case 's':
      saveMesh();
      break;
    case 'l':
      loadMesh();
      findPaths();
      initPopulation();
      break;
    case 'c':
      initEnvironment();
      initPaths();
      initPopulation();
      break;
    case 'f':
      showFrameRate = !showFrameRate;
      break;
  }
}

void mouseClicked() {
  if (!network.roadNetwork) {
    network.toggleSnapNode(mouseX, mouseY);
    network.generateEdges();
    findPaths();
    initPopulation();
  }
}

void saveMesh() {
  Table mesh = new Table();
  mesh.addColumn("x");
  mesh.addColumn("y");
  TableRow row;
  for(Node n: network.nodes) {
    row = mesh.addRow();
    row.setFloat(0, n.loc.x);
    row.setFloat(1, n.loc.y);
  }
  saveTable(mesh, fileName, "tsv");
}

void loadMesh() {
  Table mesh = loadTable(fileName);
  ArrayList<PVector> locations = new ArrayList<PVector>();
  PVector current;
  float x, y;
  for (int i=0; i<mesh.getRowCount(); i++) {
    x = mesh.getFloat(i, 0);
    y = mesh.getFloat(i, 1);
    current = new PVector(x, y);
    locations.add(current);
  }
  network.newNodes(locations);
}