%% Initialize the StoryGraphs project
% This file will be called automatically on starting Matlab in this directory.

clear all;
clc;
close all;

% Make some directories
if ~exist('tmp/', 'dir'),           mkdir('tmp/'); end
if ~exist('cache/', 'dir'),         mkdir('cache/'); end

global VIDEOEVENTS;

%% Working directory
VIDEOEVENTS.base_dir = [fileparts(mfilename('fullpath')) '/'];
VIDEOEVENTS.mex_dir = [VIDEOEVENTS.base_dir, 'utilities/mex/'];

% Check first initialization
first_init;

%% C++ / OKAPI / TRACKING-LIB Binaries
VIDEOEVENTS.binaries.render_to_html = [VIDEOEVENTS.base_dir, 'visualization/gen_html.py'];
VIDEOEVENTS.binaries.render_template_folder = [VIDEOEVENTS.base_dir, 'visualization/render_templates/'];

%% Repository folders
addpath(genpath('utilities/'));
addpath('scenes/');
addpath('threading/');
addpath('initializers/');
addpath('visualization/');

%% Initialize parameters
initParams;

%% Go go go :)
fprintf('=======================================================\n');
fprintf(['Initialized Shot Threading & Scene Detection repository. Example video for:', ...
         '\n\t%20s : The Big Bang Theory', ...
     '\n'], ...
     'BBT(se, ep)');

