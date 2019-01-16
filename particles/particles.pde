// Exploration of Dithering
// Project 5
// Title: Particles
// Creator: Fi Graham

// Enviroment Variables
boolean export = false;
String savePath = "particles-cctv.png";
PGraphics main; // main graphics for exporting at differt size than working
int size = 1080; // final export size, includes boarder
int scale = 2; // working scale, devisor for export size
int border = 200;
int downSampleFactor = 4; // must be 1 or 2^something

// Color Variables
color primaryColor;
color secondaryColor;

// Image
PImage original;
PImage img;
String imagePath = "CCTV.png";

// Particles
ParticleSystem particleSystem;

// Setup Function
void setup() {  
  size(540, 540);
  setupEnviroment();
  setupColors();
  setupImage();
  errorForceParticles();
  showParticles();
  drawToMain();
  image(main, 0, 0, width, height);
  if (export) {
    main.save(savePath);
  }
}

// sets up main graphics and size
void setupEnviroment() {
  // square format is assumed
  // create main graphics before border changes size variable
  main = createGraphics(size, size);
  // account for border in size
  size = size - border * 2;
}

// Sets up Color Varaibles
void setupColors() {
  primaryColor = color(255);
  secondaryColor = color(0, 0, 170);
}

// loads image and does some pre processing
void setupImage() {
  original = loadImage(imagePath);
  // pre processing image
  original.resize(size/downSampleFactor, size/downSampleFactor);
  original.filter(GRAY);
  img = original.get();
  particleSystem = createParticles(img);
}

void errorForceParticles() {
  
}

// Handles image processing
void showParticles() {
  particleSystem.display(img);
  changeColor(
    img,
    new ColorPair(color(255), primaryColor),
    new ColorPair(color(0), secondaryColor)
  );
  img = upSampleImage(img, downSampleFactor);
}

// Handles drawing image in main graphics
void drawToMain() {
  main.beginDraw();
  main.background(secondaryColor);
  main.image(img, border, border);
  main.endDraw();
}

// will replace first color in ColorPair with second color in ColorPair
void changeColor(PImage img, ColorPair... pairs) {
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    for (ColorPair pair : pairs) {
      if (img.pixels[i] == pair.first) {
        img.pixels[i] = pair.second;
      }
    }
  }
  img.updatePixels();
}

// scales an image up directly, nothing fancy
PImage upSampleImage(PImage in, int factor) {
  in.loadPixels();
  PImage out = createImage(in.width * factor, in.height * factor, ARGB);
  out.loadPixels();
  for (int x = 0; x < out.width; x++) {
    for (int y = 0; y < out.height; y++) {
      int indexIn = x/factor + y/factor * in.width;
      int indexOut = x + y * out.width;
      out.pixels[indexOut] = in.pixels[indexIn];
    }
  }
  out.updatePixels();
  return out;
}

// simple function to calculate index of 2d data in one 1d array
int index(int x, int y, int w) {
  return x + y * w;
}

ParticleSystem createParticles(PImage img) {
  img.loadPixels();
  ParticleSystem particleSystem = new ParticleSystem();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      float input = brightness(img.pixels[index(x, y, img.width)]);
      color closest = closestColor(input);
      Particle p = new Particle(new PVector(x, y), closest);
      particleSystem.particles.add(p);
    }
  }
  return particleSystem;
}

color closestColor(float input) {
  return color(round(input / 255) * 255);
}
