#!/usr/bin/python
import jinja2
import scipy.io as spio
import numpy
import sys, pdb

def loadmat(filename):
    '''
    this function should be called instead of direct spio.loadmat
    as it cures the problem of not properly recovering python dictionaries
    from mat files. It calls the function check keys to cure all entries
    which are still mat-objects
    '''
    data = spio.loadmat(filename, struct_as_record=False, squeeze_me=True)
    return _check_keys(data)

def _check_keys(dict):
    '''
    checks if entries in dictionary are mat-objects. If yes
    todict is called to change them to nested dictionaries
    '''
    for key in dict:
        if isinstance(dict[key], spio.matlab.mio5_params.mat_struct):
            dict[key] = _todict(dict[key])
    return dict

def _todict(matobj):
    '''
    A recursive function which constructs from matobjects nested dictionaries
    '''
    dict = {}
    for strg in matobj._fieldnames:
        elem = matobj.__dict__[strg]
        if isinstance(elem, spio.matlab.mio5_params.mat_struct):
            dict[strg] = _todict(elem)
        else:
            dict[strg] = elem
    return dict


# """ USAGE: %prog <html_template> <mat_fname> <rendered_output> """
# prepare arguments
html_template = sys.argv[1]
mat_fname = sys.argv[2]
rendered_output = sys.argv[3]

# load template and matfile
print "Loading HTML template and Mat file"
template = jinja2.Template(open(html_template).read())
data = loadmat(mat_fname)

# select the appropriate key from loadmat
key = [k for k in data.keys() if not k.startswith('__')][0]
print "Using --%s-- as key..." % key

# open output file and render to it from the template
fid = open(rendered_output, 'w')
fid.write(template.render(data[key]))
fid.close()

