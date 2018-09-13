# Project for V&V course 

This repository contains the project for the course of "Verifica e Validazione di sistemi software", started in June 2018. It is an application of a theoretical argument studied over the classes, called "Monte Carlo", applied for estimation of model sensitivity.

Using an approximation algorithm (OAA) we can compute the model sensitivity with respect to a fixed software mutation (disturbance on logic control block). 

We would like to have a global estimation and to this aim we apply Monte Carlo to compute the sensitivity over a certain number of random mutation. For each one we run the OAA algorithm and finally consider the sensitivity in the worst case.

## Getting Started

This project is still in the early stages yet. Since it is a university project, I don't know if I can give you the complete code and models used for testing and debugging the project. 

### Prerequisites

The project runs on Ubuntu and it requires few basic tools:
1) Matlab and Simulink, release R2018a
2) Bash
3) Python

```
You can install Matlab from mathworks.com
The other softwares are preinstalled with Ubuntu.
```

## Running the tests

As I said before, I cannot give you the complete code and the model used for testing. You can try to adapt the code to your own model.

The project started working on the Simulink model of the Automatic Transmission System and the model is composed by the following parts:
1) Original model.
2) Distubed model, on which we inject mutation on Control Logic.
3) Monitor which takes the output of the above models and compare them.

## Built With

* [MATLAB & Simulink](http://www.mathworks.com/downloads/) - The software used in the project

## Authors
* **Luigi Berducci** - *University of Rome La Sapienza* - [luigiberducci](https://github.com/luigiberducci)

## License
This project is licensed under the MIT License.

Copyright (c) 2018 Luigi Berducci

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
