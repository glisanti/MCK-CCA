MCK-CCA: Multi Channel-Kernel Canonical Correlation Analysis for Cross-View Person Re-Identification 
========

This repository provides the implementation of our MCK-CCA approach presented in the paper _Giuseppe Lisanti, Svebor Karaman, Iacopo Masi, "Multi Channel-Kernel Canonical Correlation Analysis for Cross-View Person Re-Identification”, ACM Transactions on Multimedia Computing, Communications and Applications (TOMM), in press, 2017._

This work is an extension of our previous method [2], that was made available at [KCCA Re-Id](https://github.com/glisanti/KCCAReId). Our approach, illustrated below, obtains state-of-the-art performance on multiple Re-Identification benchmarks thanks to the use of a powerful descriptor, the learning of multiple common kernelized projection spaces and an iterative logistic regression to select and weight the distances estimated in these spaces.

![MCK-CCA](http://www-bcf.usc.edu/~iacopoma/download/MCK-CCA.png)

## Requirements 
The code uses the following software and data to run:

1. [MATLAB (Windows, Unix version is the same)](http://www.mathworks.com/products/matlab/)
2. [An approximated version of Dr. Hardoon's KCCA code package.](http://www.davidroihardoon.com/) (4.3 KB)
3. [Descriptors (PRID)](http://www.micc.unifi.it/lisanti/downloads/mck-ccareid_data.zip) (152 MB)
4. [Logistic Regression (liblinear)](https://www.csie.ntu.edu.tw/~cjlin/liblinear/)

**Jan. 2017: The code will download and compile all the necessary files. We are using an approximated, customized version of the KCCA package from Hardoon, which original license is non-commercial.**

## Demo Example
To run our code just run _Demo_MCKCCA.m_ 	
and you should see something like this:

	>Trial # 3
	>> Fold # 1
	>Learning KCCA [Desc 1: Kernel Linear]
	>Centering Kx and Ky
	>Decomposing Kernel with PGSO
	>Computing nbeta from nalpha
	>Project train and test [Desc 1: Kernel Linear]
	>Learning KCCA [Desc 1: Kernel Gauss]
	> ...


## Person Representation

The person representation is derived from [KCCA Re-Id](https://github.com/glisanti/KCCAReId) but in MCK-CCA each feature extracted in each region is kept independent as a channel. For each channel, a specific KCCA is estimated.
For more information on the person representation used see [1].

## Changelog

* 1.0 March. 2017 - Initial Release

## Citation

Please cite these two papers using the following bibtex if you use our code:

``` latex
@article{lisanti:mckcca:tomm17,
author = {Lisanti, Giuseppe and Karaman, Svebor and Masi, Iacopo},
title = {Multi Channel-Kernel Canonical Correlation Analysis for Cross-View Person Re-Identification},
booktitle = {ACM Transactions on Multimedia Computing, Communications and Applications (TOMM)},
year = {2017}, }
```

and

``` latex
@article{lisanti:icdsc14,
author = {Lisanti, Giuseppe and Masi, Iacopo and {Del Bimbo}, Alberto},
title = {Matching People across Camera Views using Kernel Canonical Correlation Analysis},
booktitle = {Eighth ACM/IEEE International Conference on Distributed Smart Cameras},
year = {2014}, }
``` 

## References

[1] G. Lisanti , S. Karaman, I. Masi, Multi Channel-Kernel Canonical Correlation Analysis for Cross-View Person Re-Identification, ACM Transactions on Multimedia Computing, Communications and Applications (TOMM) , 2017.

[2] G. Lisanti , I. Masi , A. Del Bimbo, Matching People across Camera Views using Kernel Canonical Correlation Analysis”, Eighth ACM/IEEE International Conference on Distributed Smart Cameras, 2014.

[3] G. Lisanti, I. Masi, A. D. Bagdanov, and A. Del Bimbo, "Person Re-identification by Iterative Re-weighted Sparse Ranking", IEEE Transactions on Pattern Analysis and Machine Intelligence 2014.

## License
MCK-CCA code is Copyright (c) 2014-2017 of Giusppe Lisanti and Iacopo Masi and Svebor Karaman *giuseppe.lisanti@unifi.it, iacopoma@usc.edu, svebor.karaman@columbia.edu*.
[Media Integration and Communication Center (MICC), University of Florence.](http://www.micc.unifi.it/)
