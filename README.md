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
The <code>first_init.m</code> script will be called on running <code>startup.m</code> the first time. This will ask you to download sample image files for one video each of The Big Bang Theory and Buffy the Vamipre Slayer. Please follow the instructions. The images have been downscaled by 2 for reducing the size. You will also need to download or link to the VLFeat library.

---
### Example usage
<code>VideoStruct = BBT(1, 1); params = initParams(VideoStruct);</code>
<code>ssim = shot_similarity(VideoStruct, params);</code>
<code>[VideoStruct, shot_assigned] = similarity_to_threading(ssim);</code>
<code>visualize_threads_via_htmlrender(VideoStruct, Threads, shot_assigned);</code>

Create support for a TV episode by providing the correct interface to VideoStruct (see initializers), and a way to load frames of the video. As an example, the repository includes a few frames of shots of one episode Big Bang Theory.

----
### External toolboxes
- [VLFeat](http://www.vlfeat.org/install-matlab.html): Vision Libraries in C++ with a nice interface in Matlab


### Main functions
- [run_and_show_threading.m](run_and_show_threading.m)   A complete pipeline for computing and visualizing shot threads.
- [dp_scenes.m](scenes/dp_scenes.m)   Scene detection using dynamic programming


----
### Visualization
Python Jinja can be used to automatically generate HTML pages to visualize and/or debug both the shot threading and scene detection results. See [this](https://makarandtapaswi.wordpress.com/2013/08/28/jinja-to-visualize-shot-threads-and-scenes/) blog post for a sneak peak


### Changelog
- 06.02.2015: v0.1: A complete working implementation of shot threading


