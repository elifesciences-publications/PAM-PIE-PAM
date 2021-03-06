//  LifetimeFitMLE.cpp

#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include "time.h"
#include "matrix.h"

///////////////////////////////////////////////////////////////////////////
// This function does the actual correlation; but the function called is below
///////////////////////////////////////////////////////////////////////////
void LifetimeFitMLE(double *sig, double *model, double *range, int n_tau, int n_datapoints, double* mean_tau)
{
    // sig:     (nx1) Microtime histogram
    // model:   (n;m) library of pregenerated model function
    // range:   (1xm) vector containing respective lifetime values to model
    // n_tau:   (1x1) number of lifetimes
    // n_datapoints: (1x1) number of data points
    int i,k,j;
    
    // initialize some variables
    int div = 100;
    int MIN = 0;
    int points_per_iter = 21;
    
    double *current_model = new double[n_datapoints*points_per_iter]; 
    double *current_range = new double[points_per_iter];
    double *istar = new double[points_per_iter]; 
    double *istar_temp = new double[n_datapoints]; 
    
    for (i=0;i<3;i++)
    {
        // read out model given by current search range
        for (j=0;j<points_per_iter;j++) {current_range[j] = 0;}
        for (k=0;k<points_per_iter;k++) {current_range[k] = range[MIN+k*div];}
        for (j=0;j<n_datapoints*points_per_iter;j++) {current_model[j] = 0;}
        
        for (k=0;k<points_per_iter;k++)
            {
                for (j=0;j<n_datapoints;j++)
                {
                    current_model[j+k*n_datapoints] = model[j+n_datapoints*(MIN+k*div)];
                }
            }
        
        for (j=0;j<points_per_iter;j++) {istar[j] = 0;}
        for (k=0;k<points_per_iter;k++)
        {
            for (j=0;j<n_datapoints;j++) {istar_temp[j] = 0;}
            // calculate loglikelihood = SIG*log(SIG/Model)
            for (j=0;j<n_datapoints;j++)
            {
                if (sig[j] == 0) { istar_temp[j] += 0;}
                else if (current_model[j+k*n_datapoints] == 0) {istar_temp[j] += 0;}
                else // calculate istar
                {
                    istar_temp[j] += sig[j]*log(sig[j]/current_model[j+k*n_datapoints]);
                }
            }
            
            // sum up
            for (j=0;j<n_datapoints;j++) {istar[k] += istar_temp[j];}
        }

        // catch case where all bins are zero
        double test_zero;
        for (k=0;k<points_per_iter;k++) {
            test_zero += istar[k];
        }
        
        if (test_zero == 0) { mean_tau = 0; MIN = 1;}
        else
        {
            // find the minimum istar
            int min_idx = 0;
            double min_val = istar[0];
            for (j=0;j<points_per_iter;j++)
            {
                if (istar[j] < min_val) {min_val = istar[j];min_idx = j;}
            }
            *mean_tau = current_range[min_idx];
            // update running variables
            for (j=0;j<n_tau;j++)
            {
                if (range[j]-*mean_tau == 0)
                {
                    MIN = j-div;
                }
            }
            if (MIN < 0) { MIN = 0;}
            
        }
        div /= 10;
    }
    
    delete [] current_range;
    delete [] current_model;
    delete [] istar;
    delete [] istar_temp;
};


///////////////////////////////////////////////////////////////////////////
// This function is called from matlab  ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// nlhs is the number of output parameter
// *plhs is an array of pointers to the output parameters
// nrhs is the number of input parameters
// *prhs is an array of pointers to the input parameters
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Initializes pointers for the output and input arguments
    double *sig;
    double *model;
    double *range;
    int n_tau, n_datapoints, n_bursts;
    double *scatter;
    double *scatter_fraction;
    double *mean_tau;
    
    // Assigns input pointers to initialized pointers
    sig = mxGetPr(prhs[0]);
    model = mxGetPr(prhs[1]);
    range = mxGetPr(prhs[2]);
    n_tau = mxGetScalar(prhs[3]);
    n_datapoints = mxGetScalar(prhs[4]);
    n_bursts = mxGetScalar(prhs[5]);
    scatter = mxGetPr(prhs[6]);
    scatter_fraction = mxGetPr(prhs[7]);
    
    plhs[0] = mxCreateDoubleMatrix(n_bursts,1,mxREAL);
    mean_tau = mxGetPr(plhs[0]);
    
    int i,j,k;
    double* mi_hist = new double[n_datapoints];
    double* model_temp = new double[n_datapoints*n_tau];
    // loop over all bursts
    for (i = 0;i<n_bursts;i++)
    {
        // get microtime hisotgram
        for (j = 0;j<n_datapoints;j++)
        {
            mi_hist[j] = sig[j + n_datapoints*i];
        }
         // normalize microtime histogram
        double norm = 0;
        for (j = 0;j<n_datapoints;j++){norm += mi_hist[j];};
        for (j = 0;j<n_datapoints;j++){mi_hist[j] /= norm;};
        
        // apply scatter contribution to model function
        for (k=0;k<n_tau;k++)
        {
            for (j = 0;j<n_datapoints;j++)
            {
                model_temp[j+k*n_datapoints] = (1-scatter_fraction[i])*model[j+k*n_datapoints] + scatter_fraction[i]*scatter[j];
            }
        }
        
        // Calls function to do the actual work
        LifetimeFitMLE(mi_hist, model_temp, range, n_tau, n_datapoints, &mean_tau[i]);        
    }
    delete [] mi_hist;
    delete [] model_temp;
};





