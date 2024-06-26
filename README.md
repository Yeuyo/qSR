# qSR
A software package for quantitative analysis of single molecule localization microscopy data in live and fixed cells.

Pair Correlation Analysis

For the pair correlation analysis, our software makes use of code developed by Veatch et al. The function get_autocorr is made available in the publication cited below. The code should be downloaded, renamed as get_autocorr.m and added to the MATLAB search path.

Sarah L. Veatch et al. Correlation Functions Quantify Super-Resolution Images and Estimate Apparent Clustering Due to Over-Counting. PLOS ONE. 27 Feb 2012 DOI: 10.1371/journal.pone.0031457


FastJet Hierarchical Clustering

To perform FastJet Hierarchical Clustering, the FastJet code must first be compiled. qSR uses the fjcore distibution of FastJet, version 3.2.0, a software package developed by the particle physics community for jet finding and analysis at colliders.

                     FastJet release 3.2.0 [fjcore]
                 M. Cacciari, G.P. Salam and G. Soyez                  
     A software package for jet finding and analysis at colliders      
                           http://fastjet.fr                           
	                                                                      
 Please cite EPJC72(2012)1896 [arXiv:1111.6097] if you use this package
 for scientific work and optionally PLB641(2006)57 [hep-ph/0512210].   
                                                                       
 FastJet is provided without warranty under the terms of the GNU GPLv2.
 It uses T. Chan's closest pair algorithm, S. Fortune's Voronoi code
 and 3rd party plugin jet algorithms. See COPYING file for details.

To use the Hierarchical Clustering feature, 
  Compile the FastJetTree.cc code. 
  
  For Unix systems, this can be done using g++. cd into qSR/SpatialClustering/BioJet/FJCore/fjcore-3.2.0/ and call
  g++ -O BioJetsTree.cc fjcore.cc -o BioJetsTreeUnix

  In Windows, the code should be compiled using MinGW. The gcc and std c++ libraries should be statically linked. cd in qSR/SpatialClustering/BioJet/FJCore/fjcore-3.2.0/ from the minGW command line and call
  g++ -static -static-libgcc -static-libstdc++ -O BioJetsTree.cc fjcore.cc -o BioJetsTree

