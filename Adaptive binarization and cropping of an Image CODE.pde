PImage inputImage;
PImage binarizedImage;

void setup() {
  // Set the canvas size
  size(1500, 1400);
  
  // Load the input image (replace "sample.jpg" with the path to your image)
    inputImage = loadImage("C:/Users/neilp/Desktop/part1/sample 3.jpg"); // Load your image here
  
  // Print original input image
  image(inputImage, 0, 0);
  
  // Convert the input image to grayscale
  toGrayscale(inputImage);
  
  // Perform adaptive binarization on the grayscale image
  binarizedImage = adaptiveBinarization(inputImage);
  
  // Print grayscale image
  image(inputImage, inputImage.width + 10, 0);
  
  // Print binarized image
  image(binarizedImage, 0, inputImage.height + 10);
  
  // Crop out the object from the binarized image
  PImage croppedImage = cropObject(binarizedImage);
  image(croppedImage, inputImage.width + 10, inputImage.height + 10);
}

// Function to convert an image to grayscale
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

// Function to perform adaptive binarization
PImage adaptiveBinarization(PImage img) {
  // Create a new image for binarization
  PImage binarizedImg = createImage(img.width, img.height, ALPHA);
  img.loadPixels();
  binarizedImg.loadPixels();
  
  // Define parameters for adaptive binarization
  int windowSize = 20; // Size of the window for local thresholding
  float scaleFactor = 0.6; // Scaling factor to adjust the threshold
  
  // Iterate through each pixel in the image
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      // Calculate local threshold for the pixel
      float threshold = calculateLocalThreshold(img, x, y, windowSize, scaleFactor);
      int index = x + y * img.width;
      // Apply binarization based on the threshold
      if (brightness(img.pixels[index]) < threshold) {
        binarizedImg.pixels[index] = color(0); // Set to black
      } else {
        binarizedImg.pixels[index] = color(255); // Set to white
      }
    }
  }
  
  // Update pixel data for the binarized image
  binarizedImg.updatePixels();
  return binarizedImg;
}

// Function to calculate local threshold for adaptive binarization
float calculateLocalThreshold(PImage img, int x, int y, int windowSize, float scaleFactor) {
  int total = 0;
  int count = 0;
  
  // Iterate through the pixels in the local window
  for (int j = -windowSize/2; j <= windowSize/2; j++) {
    for (int i = -windowSize/2; i <= windowSize/2; i++) {
      int posX = constrain(x + i, 0, img.width - 1);
      int posY = constrain(y + j, 0, img.height - 1);
      total += brightness(img.get(posX, posY));
      count++;
    }
  }
  
  // Calculate the average intensity in the window
  int average = total / count;
  
  // Adjust the threshold using the scaling factor
  float threshold = average * scaleFactor;
  
  return threshold;
}

// Function to crop out the object from the binarized image
PImage cropObject(PImage binarized) {
  // Define variables to track the bounding box of the object
  int minX = binarized.width;
  int minY = binarized.height;
  int maxX = 0;
  int maxY = 0;
  
  // Iterate through the pixels in the binarized image
  binarized.loadPixels();
  for (int y = 0; y < binarized.height; y++) {
    for (int x = 0; x < binarized.width; x++) {
      int index = x + y * binarized.width;
      // Check if the pixel belongs to the object (black)
      if (binarized.pixels[index] == color(0)) {
        // Update bounding box coordinates
        minX = min(minX, x);
        minY = min(minY, y);
        maxX = max(maxX, x);
        maxY = max(maxY, y);
      }
    }
  }
  
  // Calculate dimensions of the cropped object
  int croppedWidth = maxX - minX + 1;
  int croppedHeight = maxY - minY + 1;
  
  // Extract the cropped object from the binarized image
  PImage croppedImage = binarized.get(minX, minY, croppedWidth, croppedHeight);
  return croppedImage;
}
