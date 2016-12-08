Shot Threading and Scene Detection
===========

This is an implementation of some basic video processing tools. Currently, it assumes that shot detection has been performed. It also assumes that you have a suitable means of "reading" through video in Matlab, probably best with a frame burst.

The shot threading is further used for scene detection, as proposed in:

----
StoryGraphs: Visualizing Character Interactions as a Timeline  
Makarand Tapaswi, Martin Bäuml, and Rainer Stiefelhagen  
IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2014  
[Project page](https://cvhci.anthropomatik.kit.edu/~mtapaswi/projects-storygraphs.html) | [Paper download](https://cvhci.anthropomatik.kit.edu/~mtapaswi/papers/CVPR2014.pdf) | [StoryGraphs code](https://github.com/makarandtapaswi/StoryGraphs)

----

### Tested on
Ubuntu 12.04, Ubuntu 14.04, with Matlab versions: R2013a onwards.


### First initialization
The <code>first_init.m</code> script will be called on running <code>startup.m</code> the first time. This will ask you to download sample shot frames for one video of The Big Bang Theory. The images have been downscaled by 2. Please follow the other instructions.

---
### Example usage
Initialize the video data.
<code>VideoStruct = BBT(1, 1); initParams;</code>

Compute similarity between every shot and N subsequent shots
<code>ssim = shot_similarity(VideoStruct, params);</code>

Convert similarity to threads (by finding maximal cliques)
<code>[Threads, shot_assigned] = similarity_to_threads(ssim);</code>

Visualize threading using python template engine
<code>visualize_threads_via_htmlrender(VideoStruct, Threads, shot_assigned);</code>

Compute scene change locations
<code>scene_breaks = dp_scenes(VideoStruct, params);</code>

Visualize scene detection using python template engine
<code>visualize_scenes_via_htmlrender(VideoStruct, scene_breaks, params);</code>

Create support for a TV episode by providing the correct interface to VideoStruct (see initializers), and a way to load frames of the video. As an example, the repository includes a few frames of shots of one episode Big Bang Theory.

----
### External toolboxes
- [VLFeat](http://www.vlfeat.org/install-matlab.html): Vision Libraries in C++ with a nice interface in Matlab
- MEX/C++ n-d Image Histogram: Thanks to [Boris Schauerte](http://schauerte.me/), BSD 2-Clause license


### Main functions
- [are_images_similar.m](threading/are_images_similar.m) Check SIFT-based similarity between 2 images.
- [shot_similarity.m](threading/shot_similarity.m)   Compute shot similarity on the whole video (can use parfor).
- [dp_scenes.m](scenes/dp_scenes.m)   Scene detection using dynamic programming.


----
### Visualization
Python Jinja can be used to automatically generate HTML pages to visualize and/or debug both the shot threading and scene detection results. See [this](https://makarandtapaswi.wordpress.com/2013/08/28/jinja-to-visualize-shot-threads-and-scenes/) blog post for a sneak peak


### Changelog
- 05 Mar 2015: v1.0: Complete working implementation shot threading + scene detection
- 06 Feb 2015: v0.1: A complete working implementation of shot threading


