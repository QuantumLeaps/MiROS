# What is it?
"MiROS" is a Minimal Real-Time Operating System (RTOS). This software is a teaching aid
to illustrate the concepts underlying the Real-Time Operating System (RTOS). The main
goal of the software is simplicity and clear presentation of the concepts, but without
dealing with various corner cases, portability, or error handling. For these reasons,
the software is generally NOT intended or recommended for use in commercial applications.


[![MiROS on YouTube: RTOS part-2](img/MiROS.jpg)](https://youtu.be/PKml9ki3178)


---------------------------------------------------------------------
# Directories and Files

```
FreeAct/
+-3rd_party/       - third-party software (needed in the examples)
| +-CMSIS/         - ARM CMSIS
| +-ek-tm4c123gxl/ - low-level code to support the EK-TM4C123GX board
|
+-examples/
| +-blinky-tm4c/   - Blinky exammple for the EK-TM4C123GX board
|
+-inc/             - include directory
| +-MiROS.h        - MiROS interface
+-src/             - source directory
| +-MiROS.c        - MiROS implementation
```

---------------------------------------------------------------------
# Licensing
MiROS is [licensed](LICENSE.txt) under the GPLv3 open source license.


---------------------------------------------------------------------
# Comments/Discussion
If you'd like to discuss MiROS or related subjects, plese use the ["Issues" tab](https://github.com/QuantumLeaps/MiROS/issues).


---------------------------------------------------------------------
# Contact Information

[state-machine.com](https://www.state-machine.com)
