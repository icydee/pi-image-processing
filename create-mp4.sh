# Create an mp4 file from a set of input files

ffmpeg -framerate 25 -i img_%04d.jpg -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p video_190519.mp4


