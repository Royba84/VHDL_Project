# VHDL_Project
Mission: design a system that takes (synchronic - serial) data blocks and computes statistics - minimum,maximum,average,median and number of errors in communication for each data block

General block digaram:
![image](https://user-images.githubusercontent.com/105777016/178103775-6b978349-9d65-4ffe-91e6-6a84f9672b79.png)

When the orange block will represent the syncronic transmitter.

# System requirements:
- The system will be operated from a single clock of 50 [MHz].
- Reset - Active low.
- The system will be turned on to "idle" mode.
- First press on "start" will make "Generator_data_serial_ to begin and output data block and will transform the system from idle state to input state.
- Each data block size will be 64.
- Each data will be made of 8 bits (positive number between 0 to 255 + parity bit - total of 9 bits per bit).
- Each parameter will be transimitted in a serial way.
- In the end of receiving 64 parameters, the system will move automatically to calculating mode.
- The system has to make the following claculations:
1) Maximum value out of 64.
2) Minimum value out of 64.
3) Mean value out of 64.
4) Median of 64 values (since the number of values is even the median will be defined as average of the 2 middle values).
5) Number of errors coming for the transmitter.
- In the calculation where the output can include fractions, the numbers will be rounded up.
- In the end of the calculations the system will present the data and turn on LED2.
- In displaying mode, the maximal value will be presented first, then the minimal and so on (according to 1-5), the transition between them will be by pressing DISPLAY.

System states:
![image](https://user-images.githubusercontent.com/105777016/178104072-86c4ef3f-5b89-4058-9547-52637c91e7c6.png)

- The system in free state when being turned on.
- The system computed and process the data.
- The system present the calculations output.

Inside claculation bubble there is another state machine:

![image](https://user-images.githubusercontent.com/105777016/178104099-e5427311-ef54-4aa1-aae0-59bf7e190258.png)

This state machine is managing the process from data being requested to processing and finally storing for display.
Those states will be discussed in the "Main-Controller" component.

# Quartos - Pin configuration:

![image](https://user-images.githubusercontent.com/105777016/178104158-1a7ed6e3-d903-4ae6-a18f-661a94efb05b.png)

![image](https://user-images.githubusercontent.com/105777016/178104160-f576ef97-f2df-4b7e-9121-d753e7bb1979.png)

Required equipment:
- Cyclone V kit
- A computer with the following programs installed: ModelSim, quartos and Notepad++.

# Detailed engineering design:

# 1) Serial Data Generator:

This block produces syncronic serial data.

![image](https://user-images.githubusercontent.com/105777016/178104220-d2c83ba0-6666-46f5-86ff-e7732e127d7d.png)

![image](https://user-images.githubusercontent.com/105777016/178104234-bffb78a3-0f5f-4568-941e-9bcb568f6528.png)

![image](https://user-images.githubusercontent.com/105777016/178104236-26ecbaa9-0860-44ad-b1ac-b50386b3ae87.png)



# 2) Serial to Parallel:

![image](https://user-images.githubusercontent.com/105777016/178104255-7df62d15-ad50-4050-9c9b-6562d8138d68.png)

![image](https://user-images.githubusercontent.com/105777016/178104257-c7771bba-2909-43c6-b925-9423411be8ad.png)

How this block operates:
The pins entrance will be serial where SER_DIN_VALID='1', and the bits will get into the system through SER_DIN.
This block converts each 8 bits that being received from the block "Serial data generator" to bits vector, this vector will be used as output: PAR_DOUT.
In addition, bit number 9 which stands for parity, after being checked with G_PARITY will tell us if we got the data bits in a good condition, this calculation will be used as output: PARTY_ERROR.
Output: PAR_DOUT_VALID - goes 'up' for one clock cycle only when the outputs are available.


Simulation results:
![image](https://user-images.githubusercontent.com/105777016/178104343-e6579ea1-7876-4780-b3fc-27f57a5100d4.png)

Full image of 2 iterations, in the following image we will take a look in detail on the first iteration.

![image](https://user-images.githubusercontent.com/105777016/178104374-2802b508-821e-4ce4-bedc-cb9bd4e17072.png)

In this image, pay attention that for the signal PAR_DOUT inside the "SerialToParallel" label, the data is indeed correct.

