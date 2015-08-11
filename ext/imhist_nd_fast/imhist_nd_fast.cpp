/**
 * imhist_nd_fast
 *
 * Fast C/C++ calculation of n-dimensional image histograms (where n is the 
 * number of image channels).
 *
 * @author B.Schauerte
 * @date 2009
 * 
 * BSD 2-Clause License
 * ==================== 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer
 *    in the documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * 
 */

#include "mex.h"

/* access to a 2-dimensional array */
#define _A2D(arr,row,column,nrows) arr[nrows * column + row]
/* access to a 3-dimensional array */
/*This is almost correct. If "a" is M x N x P, then an
appropriate define for 0-based indexing would be:

#define A(i,j,k) a[(i)+((j)+(k)*N)*M]

where

i = 0,...,M-1
j = 0,...,N-1
k = 0,...,P-1

and an appropriate define for 1-based indexing would be:

#define A(i,j,k) a[(i-1)+((j-1)+(k-1)*N)*M]

where

i = 1,...,M
j = 1,...,N
k = 1,...,P*/
/*#define PVAL(image,x,y,c,nrows,ncols) image[(x)+((y)+(c)*ncols)*nrows]*/
#define PVAL(image,row,col,channel,nrows,ncols) image[(row)+((col)+(channel)*ncols)*nrows]

#define _A3D(arr,i,j,k,dims) arr[(i)+((j)+(k)*dims[1])*dims[0]]
/* a3d = @(dims,i,j,k) (i-1)+((j-1)+(k-1)*dims(2))*dims(1) + 1; a3d(size(A),5,4,3), sub2ind(size(A),5,4,3) */

#define GET_IMHIST_ND_IDX(val,bin_min,bin_max,nbins) (((val - bin_min) / ((bin_max - bin_min) + (bin_max - bin_min)/8192)) * (nbins))

/* I declare inline here -- if necessary edit your .mex compiler options to non-ansi (~/.matlab/R2009a/mexopts.sh --> edit the CFLAGS) */
template <typename S, typename T>
inline mwSize
get_imhist_nd_idx(const S val, const T bin_min, const T bin_max, const T nbins)
{
  /*return floor((double(val) - bin_min) / (bin_max + 1 - bin_min)) * (nbins) + 1);*/
  /*return (mwSize)(((val - bin_min) / (bin_max + 1 - bin_min)) * (nbins));*/
	return (mwSize)GET_IMHIST_ND_IDX(val,bin_min,bin_max,nbins);
}

template <typename S, typename T>
void
_mexFunction(int nlhs, mxArray* plhs[], 
	int nrhs, const mxArray* prhs[])
{
  mwSize i = 0, j = 0; /* variables for for-loops */
  
  /* Get the parameters/arguments */
	const S *image = (const S *)mxGetPr(prhs[0]);
	const T *params = (const T *)mxGetPr(prhs[1]);
	const mwSize ncols_params = mxGetN(prhs[1]);
	const mwSize nrows_params = mxGetM(prhs[1]);
	
  if (ncols_params != 3)
    mexErrMsgTxt("params has wrong number of columns, each row should be [min,max,nbins].\n");
  const mwSize  image_ndims       = mxGetNumberOfDimensions(prhs[0]);
  const mwSize* image_dimensions  = mxGetDimensions(prhs[0]); /* <- is this a memory leak? */
  const mwSize  image_nchannels   = image_dimensions[2];
  /* check the dimensionality of the image and the number of lines*/
  if (nrows_params != image_nchannels) 
    mexErrMsgTxt("mismatch, provided binning parameters (i.e. the lines of params) do not match the number of image channels.\n");
  
  /* display some image information */
  const mwSize nrows_image = mxGetM(prhs[0]);
  const mwSize ncols_image = mxGetN(prhs[0]);
  
	/* create output array */
  const mwSize max_dims = 8;
  if (image_nchannels > max_dims)
    mexErrMsgTxt("imhist_nd_fast: number of maximally supported dimensions/channels exceeded.\n");
	mwSize dims[max_dims];
  for (i = 0; i < image_nchannels; i++)
    dims[i] = _A2D(params,i,2,nrows_params);
	plhs[0] = mxCreateNumericArray(image_nchannels, dims, mxDOUBLE_CLASS, mxREAL);
	double *hist = mxGetPr(plhs[0]);

  T channels_bin_min[max_dims];
  T channels_bin_max[max_dims];
  T channels_bin_nbins[max_dims];
  for (i = 0; i < nrows_params; i++)
  {
    channels_bin_min[i]   = _A2D(params,i,0,nrows_params);
    channels_bin_max[i]   = _A2D(params,i,1,nrows_params);
    channels_bin_nbins[i] = _A2D(params,i,2,nrows_params);
  }
  
  const mwSize npixels = mxGetNumberOfElements (prhs[0]) / image_nchannels; /* total number of pixels in the image, i.e. width x height */
  if (image_nchannels != 3)
    mexErrMsgTxt("imhist_nd_fast@TODO: add support for !=3 image channels.\n");
  S a = 0,b = 0,c = 0;
  for (i = 0; i < npixels; i++)
  {
    /* Get pixel value */
    a=image[i + 0*npixels];
    b=image[i + 1*npixels];
    c=image[i + 2*npixels];
      
    /* Increment corresponding histogram entry */
    const mwSize a_idx = get_imhist_nd_idx<S,T>(a,channels_bin_min[0],channels_bin_max[0],channels_bin_nbins[0]);
    const mwSize b_idx = get_imhist_nd_idx<S,T>(b,channels_bin_min[1],channels_bin_max[1],channels_bin_nbins[1]);
    const mwSize c_idx = get_imhist_nd_idx<S,T>(c,channels_bin_min[2],channels_bin_max[2],channels_bin_nbins[2]);
    bool error = false;
    if (a_idx < 0 || b_idx < 0 || c_idx < 0)
    {
      mexPrintf("<0? %d %d %d\n",a_idx,b_idx,c_idx);
      error = true;
    }
    if (a_idx >= dims[0] || b_idx >= dims[1] || c_idx >= dims[2])
    {
      mexPrintf(">=dim? %d %d %d\n",a_idx,b_idx,c_idx);
      error = true;
    }
    if (error)
    {
      mexPrintf("a,b,c = %f %f %f\n", a,b,c);
      return;
    }
    ++_A3D(hist,a_idx,b_idx,c_idx,dims); /* _A3D(arr,i,j,k,dims) arr[(i)+((j)+(k)*dims[1])*dims[0]] */
  }
	
	return;
}


void
mexFunction (int nlhs, mxArray* plhs[], 
	int nrhs, const mxArray* prhs[])
{
  mwSize i = 0, j = 0; /* variables for for-loops */
  
  /* Check number of input parameters */
	if (nrhs != 2) 
  {
  	mexErrMsgTxt("Two inputs required.");
  } 
  else 
		if (nlhs > 1) 
	  {
  		mexErrMsgTxt("Wrong number of output arguments.");
	  }    

  /* Check type of input parameters */
	if (!mxIsDouble(prhs[0]) && !mxIsSingle(prhs[0])) 
		mexErrMsgTxt("Input image should be single or double.\n");
	if (!mxIsDouble(prhs[1]) && !mxIsDouble(prhs[1])) 
		mexErrMsgTxt("Input parameters should be single or double.\n");
		
	if (mxIsDouble(prhs[0]) && mxIsDouble(prhs[1]))
		_mexFunction<double,double> (nlhs, plhs, nrhs, prhs);
	if (mxIsSingle(prhs[0]) && mxIsDouble(prhs[1]))
		_mexFunction<float,double> (nlhs, plhs, nrhs, prhs);
	if (mxIsDouble(prhs[0]) && mxIsSingle(prhs[1]))
		_mexFunction<double,float> (nlhs, plhs, nrhs, prhs);
	if (mxIsSingle(prhs[0]) && mxIsSingle(prhs[1]))
		_mexFunction<float,float> (nlhs, plhs, nrhs, prhs);

	return;
}
