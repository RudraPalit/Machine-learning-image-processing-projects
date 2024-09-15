// Importing the necessary Processing library
import processing.core.*;

// Declare global variables for images, number of chaincode directions, and cell size
PImage inputImage1;
PImage inputImage2;
int numChaincodeDirections = 10; // Adjust based on the level of detail needed
int cellSize = 8; // Example cell size

void setup() {
  // Set up the canvas size
  size(1500, 1400); // Adjust based on your display needs

  // Load two images from file paths
  inputImage1 = loadImage("C:/Users/neilp/Desktop/part1/img2.png");
  inputImage2 = loadImage("C:/Users/neilp/Desktop/part1/img2.png");
  
  // Ensure images are loaded correctly
  if (inputImage1 == null || inputImage2 == null) {
    println("Images could not be loaded.");
    return;
  }

  // Convert images to grayscale
  toGrayscale(inputImage1);
  toGrayscale(inputImage2);
  
  // Calculate HOG descriptors for both images
  float[] hogDescriptor1 = calculateHOGDescriptor(inputImage1);
  float[] hogDescriptor2 = calculateHOGDescriptor(inputImage2);
  
  // Compute and print cosine similarity between the two HOG descriptors
  float similarity = cosineSimilarity(hogDescriptor1, hogDescriptor2);
  println("Cosine Similarity: " + similarity);
}

// Function to convert an image to grayscale using luminosity method
void toGrayscale(PImage img) {
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int index = x + y * img.width;
      // Calculate grayscale value using luminosity method
      float r = red(img.pixels[index]);
      float g = green(img.pixels[index]);
      float b = blue(img.pixels[index]);
      img.pixels[index] = color(0.21 * r + 0.72 * g + 0.07 * b);
    }
  }
  img.updatePixels();
}

// Function to calculate HOG descriptor for an image
float[] calculateHOGDescriptor(PImage img) {
  // Calculate the number of cells in X and Y directions
  int numCellsX = img.width / cellSize;
  int numCellsY = img.height / cellSize;
  // Initialize a 3D array to store histograms for each cell
  float[][][] histograms = new float[numCellsX][numCellsY][numChaincodeDirections];
  
  // Calculate histograms for each cell
  for (int i = 0; i < numCellsX; i++) {
    for (int j = 0; j < numCellsY; j++) {
      histograms[i][j] = createHistogram(img, i * cellSize, j * cellSize, cellSize, numChaincodeDirections);
    }
  }

  // Normalize histograms for each cell
  for (int i = 0; i < numCellsX; i++) {
    for (int j = 0; j < numCellsY; j++) {
      normalizeBlock(histograms[i][j]);
    }
  }
  
  // Flatten histograms into a 1D array
  return flattenHistograms(histograms);
}

// Function to calculate gradient at a given pixel
float[] calculateGradient(PImage img, int x, int y) {
  int px = img.pixels[y * img.width + x];
  int mx = x > 0 ? img.pixels[y * img.width + (x - 1)] : px;
  int my = y > 0 ? img.pixels[(y - 1) * img.width + x] : px;
  int gx = (px & 0xFF) - (mx & 0xFF);
  int gy = (px & 0xFF) - (my & 0xFF);
  float magnitude = sqrt(gx*gx + gy*gy);
  float direction = atan2(gy, gx) * 180 / PI;
  direction = (direction < 0) ? 360 + direction : direction;
  return new float[] {magnitude, direction};
}

// Function to create a histogram for a given cell
float[] createHistogram(PImage img, int cellX, int cellY, int cellSize, int numDirections) {
  float[] histogram = new float[numDirections];
  float angleStep = 360 / numDirections;

  for (int y = 0; y < cellSize; y++) {
    for (int x = 0; x < cellSize; x++) {
      int pixelX = cellX + x;
      int pixelY = cellY + y;
      if (pixelX < img.width && pixelY < img.height) {
        float[] gradient = calculateGradient(img, pixelX, pixelY);
        int bin = (int)(gradient[1] / angleStep) % numDirections;
        histogram[bin] += gradient[0];
      }
    }
  }
  return histogram;
}

// Function to normalize histogram values
void normalizeBlock(float[] histogram) {
  float sum = 0;
  for (int i = 0; i < histogram.length; i++) {
    sum += histogram[i] * histogram[i];
  }
  float norm = sqrt(sum);
  for (int i = 0; i < histogram.length; i++) {
    histogram[i] = norm == 0 ? 0 : histogram[i] / norm;
  }
}

// Function to flatten 3D histogram array into a 1D array
float[] flattenHistograms(float[][][] histograms) {
  int totalLength = histograms.length * histograms[0].length * histograms[0][0].length;
  float[] featureVector = new float[totalLength];
  int index = 0;
  for (int i = 0; i < histograms.length; i++) {
    for (int j = 0; j < histograms[0].length; j++) {
      for (int k = 0; k < histograms[0][0].length; k++) {
        featureVector[index++] = histograms[i][j][k];
      }
    }
  }
  return featureVector;
}

// Function to calculate cosine similarity between two feature vectors
float cosineSimilarity(float[] hog1, float[] hog2) {
  float dotProduct = 0;
  float normHog1 = 0;
  float normHog2 = 0;
  for (int i = 0; i < hog1.length; i++) {
    dotProduct += hog1[i] * hog2[i];
    normHog1 += hog1[i] * hog1[i];
    normHog2 += hog2[i] * hog2[i];
  }
  normHog1 = sqrt(normHog1);
  normHog2 = sqrt(normHog2);
  return dotProduct / (normHog1 * normHog2);
}
