Accompanying MATLAB code
========================

This folder contains code to generate plots and correlation data for thedynamical systems described in Richard Kennaway's paper "When causation does not
imply correlation: robust violations of the Faithfulness axiom". The paper can
be found on ArXiv at https://arxiv.org/abs/1505.03118, and is also published as
Chapter 4 of "The Interdisciplinary Handbook of Perceptual Control Theory", in
which form it can be accessed at
https://www.sciencedirect.com/science/article/pii/B9780128189481000046

The code should be compatible with versions of Matlab from 2007 on, but I have
not tested it in any version more recent than 2013.

Some additional computations are available here that are not described in the
paper, as I considered that they added little new.  These are the use of
non-Gaussian signals (square waves with random switching times) and
non-parametric measures of correlation (Spearman's rho etc.).cnonc_VI.m and cnonc_fig4 automatically generate some image files.  These
images are the same as in the paper.It is written in Matlab, and uses the following functions from specialisedMatlab toolboxes which may or may not be present in your installation:
Signal Processing Toolbox: xcorr (used to calculate time-lagged auto- and    cross-correlations)
Image Processing Toolbox: imfilter (used to generate smooth random variables)
corr is in the Statistics Toolbox, but I wrote my own version because notall of the machines I use have that toolbox.  The Toolbox version can beused instead if you have it.The principal functions are these:paperExamples.m    Runs cnonc_VI, cnonc_fig4, cnonc_controller1, and cnonc_controller2    with the same parameters used to generate the data in the paper.    Due to the use of random data, the numbers will vary slightly from    one run to another.  With no arguments it will take a few minutes to    run.  It optionally takes an argument to specify how much data to    collect.  It will generate a collection of figures on screen and saved    to image files, and write a large quantity of stuff to the console.cnonc_VI.m    Generates Figure 1(a-e), showing the relationships between V, I, and t,    for a capacitor connected to a varying voltage source.cnonc_fig4.m    Generates Figure 4(a-d), showing traces of D, R, P, O, and E for the    integral controller.cnonc_controller1.m    Generates the correlations for the integral controller example.cnonc_controller2.m    Generates the correlations for the proportional controller example.estimateCorrDist.m    Empirically estimates the standard deviation of the correlation between    two independent slowly varying waveforms, and compares it with the same    measurement for two independent sources of white noise.  The ratio of    their variances is of a similar size to the number of steps in the    coherence time.printAllcovars.m    Calculate all of the conditional correlations between any two variables,    conditional upon any subset of the remainder.All of these except the last two can be called with no arguments, or can havearguments explicitly given as keyword/value pairs.  See the respective filesfor details of expected arguments.Some subsidiary functions of interest are:rand_bac.m    Generates a smooth randomly varying waveform with a specified    autocorrelation time.  ("bac" = bounded autocorrelation.)randSmoothWaveform    As rand_bac, but also ensures that the waveform starts at zero.  This    avoids starting glitches in the simulated systems.randStepWaveform    Takes the same arguments as randWaveform and rand_bac, but generates a    waveform that is always 1 or -1, the switching intervals being    exponentially distributed with a specified average time.  When steps
    happen they are instant.randWaveform    Generates smooth, random step, or single step waveforms according to its
    arguments.  When steps happen, they may be instant, linear ramps, or
    sinusoidal ramps.corrQuadrant    Calculates the quadrant correlation between two random variables.    This is the Pearson correlation between the boolean variables resulting    from comparing each observation against its mean.corrRho    Calculates Spearman's rho correlation between two random variables.    This is the Pearson correlation between the ranks of the observations.corrTau    Calculates Kendall's tau correlation between two random variables.    This is the Pearson correlation between two binary variables: one    comparing the two observations, and one comparing their ranks.These three non-parametric measures of dependence all assume an underlying
monotonic relationship between the variables.====