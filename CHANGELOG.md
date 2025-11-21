-------- version 0.0.01 ---------
First version of the PC:
- Added the ability to enter the parameters of the op amp (1x1, 2x2, 3x3)
- Added the calculation of the possible uncertainty zone
- Added the calculations of the controllers (nominal and robust) for the op amp of dimension 2x2
- Added the settings (Tmod, criterion selection, uncertainty zone input (common for all parameters))

-------- version 0.1.0 ---------
- Added the calculation of the robust-adaptive controller for the op amp of dimension 2x2
- Improved the optimization of the coefficient search for the robust controller

-------- version 0.2.0 ---------
- Reworked the basic settings (criterion selection, Tmod input)
- Added the advanced settings (uncertainty zone input for each parameter)

-------- version 0.3.0 ---------
- Increased functionality of advanced settings (different disturbances, coefficient enumeration, enumeration of nominal or extreme values)
- Added excel file for saving calculations

-------- version 0.4.0 ---------
- Added the ability to build a transient process graph

-------- version 0.5.0 ---------
- Added calculation of the nominal controller for op amps with dimensions 1x1 (Search and non-search method)
- Added calculation of the robust controller for op amps with dimensions 1x1 (Search, non-search and MC method)
- Added calculation of the robust controller by the MS method for op amps with dimensions 2x2

-------- version 0.5.2 ---------
- Repeating functions moved to separate files

-------- version 0.6.0 ---------
- Added calculation of robust-adaptive controller for 1x1 op amp (PI controller)
- Added the ability to plot a transient process graph for 1x1 op amp with the maximum difference between robust and robust-adaptive controller.

-------- version 0.6.1 ----------
- Fixed a bug where a failure could occur when starting the calculation of a robust controller using the MS method
- Fixed a bug where two sound notifications were generated at once after calculating the controller using the MS method.

-------- version 0.7.0 ----------
- Optimized approximation of control objects
- Added the ability to calculate controller parameters for 3x3 op amps

In future versions it is planned to:
- Improve optimization and speed up controller calculations
- Refine some functions to reduce their number
- Add the ability to select a controller (I or PI) for 1x1 op amps
- Provide the ability to enter parameters of the nominal and robust controller when calculating the robust-adaptive controller