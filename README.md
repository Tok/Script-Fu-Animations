# Script-Fu-Animations

---

## GTW animation
Script and templates to generate GTW-Logo animations in GIMP.
https://www.gimp.org/

### Vectors
(https://raw.githubusercontent.com/Tok/script-fu-animations/master/vectors "vectors") contains the original SVG files to recreate the individual layers.

### GIMP
(https://raw.githubusercontent.com/Tok/script-fu-animations/master/gimp "gimp") contains xcf files with 3 layers combined from the original SVG files in different sizes.

### Script
gtw-X.X.X.scm is a script-fu script that adds a new menu in gimp, for generating an animation from the provided xcf files. 
The input image requires 3 layers and should have a reasonable width and legth before the animation is generated.
https://docs.gimp.org/en/gimp-concepts-script-fu.html

---

## Results
![GTW Green 480](https://raw.githubusercontent.com/Tok/script-fu-animations/master/results/GTW-0.8.0-480-green.gif "Green 480")
![GTW Red 320](https://raw.githubusercontent.com/Tok/script-fu-animations/master/results/GTW-0.8.0-320-red.gif "Red 320")
For best results, the output should be compressend and optimized.
