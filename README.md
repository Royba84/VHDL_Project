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


# 3) Main Controller

![image](https://user-images.githubusercontent.com/105777016/178104438-1dd7f1fd-66b9-410c-a448-acdc97f25e1a.png)

![image](https://user-images.githubusercontent.com/105777016/178104442-484de9e3-aae0-49e2-9b8a-f57628c4807d.png)

How this block operates:
The main controller gets his data from "Serial to Parallel" block through the following inputs:
-DIN
-DIN_VALID
-PARITY_ERROR

The inputs: "START" and "DISPLAY" are being pushed by the user (as shown in the videos in the end of this document) so that they pass through Asynchronic OneShot that will pass to the system in 1 pulse on 1 clock cycle only.
First, the system in "idle" state until the button is pressed. in this state the system is in static state where all the signal and outputs are '0'.
When "start" is being pressed, we will move toward the next state : "DATA_REQUEST_STATE". in this state the system gives as output DATA_REQUEST '1' for the block "SERIAL DATA GENERATOR" for 200 clock cycles and proceed to calculation mode (when the whole data was transferred not necessarily after 200 clock cycles).
In addition, in this state the system adds up all the numbers into array and the whole errors as well into array for the parity number - PARITY_ERRROR.

After receiving 64 data bytes, inside the array sort is being made using "bubble sort" method.
After the sort is over, the next state is "DISPLAY" where we will see first the maximal value (by taking the last value of the array).

The whole process can be summed up to this state machine:

![image](https://user-images.githubusercontent.com/105777016/178104644-850f620a-c62a-441c-9e36-910316f834bd.png)

This sub-state machine is responsible on when and in what order to present the values:

![image](https://user-images.githubusercontent.com/105777016/178104664-eaf9b47c-06e2-440a-b013-d5b94f880642.png)


Block implementation (Very large scale..) from quartos:

![image](https://user-images.githubusercontent.com/105777016/178104635-4e17e425-774e-491d-a5df-821f6306ab74.png)


Simulation results:

![image](https://user-images.githubusercontent.com/105777016/178104696-49f458ef-cd4f-4f69-b3d4-315a81cbe319.png)

We can see the "DISPLAY" button pressed, our machine presenting numbers.

![image](https://user-images.githubusercontent.com/105777016/178104698-99f21e08-b373-4f93-9c3d-066f1952d008.png)


# 4) BCD_to_7SEG

![image](https://user-images.githubusercontent.com/105777016/178104741-791b9098-0ae9-4c4a-b634-581db7eaba29.png)


Truth table:

![image](https://user-images.githubusercontent.com/105777016/178104739-f5a1cfd9-ed2b-4cf6-8d7c-243e5859ea7d.png)


![image](https://user-images.githubusercontent.com/105777016/178104742-1169bafb-9eb7-42cc-a433-801a30a368c6.png)

This component job is to turn on LED's in a certain way to get numbers (digits) from 0 to 9.


# 5) bin2bcd_12bit

![image](https://user-images.githubusercontent.com/105777016/178104772-86aa6fe5-c4d9-448f-bb0a-a786b102eb16.png)

![image](https://user-images.githubusercontent.com/105777016/178104776-3e86b9db-2205-4994-a1b6-7592a14ded04.png)

This block gets binary number which consists 12 bits and divides the number to ones,tens,hundreds, thousends etc...



# Asynchronic Oneshot

Purpose: This component was implemented in order to face the following problem.
When we press one time, instead of multiple pressings (because of high frequency clock) against our disabled reaction time to press the button.

![image](https://user-images.githubusercontent.com/105777016/178104877-5ae69f86-6f59-4810-95da-288d83c0169d.png)


# Statistics_calc - TOP LEVEL

The top level holds the whole system blocks and operates them excatly as mentioned in the system requirements.

![image](https://user-images.githubusercontent.com/105777016/178104902-888cb2b0-4381-4bde-a74b-142a5faea07f.png)

Simulation results:

![image](https://user-images.githubusercontent.com/105777016/178104914-d97dc535-e6a3-4c15-b8c4-07182a6bfa8d.png)

Final results of the simulation, with a little effort it can be seen that our oneshot actually works and we have output to our LED's which shows the display states.

![image](https://user-images.githubusercontent.com/105777016/178104917-c996128f-fa3d-4a36-a9d2-3ba0a8ea3464.png)

Here it can be seen that the display button is pressed for a few time periods.

![image](https://user-images.githubusercontent.com/105777016/178104922-8d65faf5-ef81-4e9b-9413-17ab1a15f7f8.png)



# Hardware flow summary (from Quartos):

![image](https://user-images.githubusercontent.com/105777016/178104995-86d0b80a-0c82-4ea3-827a-08834987315c.png)

It can be seen that i use 18,432/4,567,040 memory which is less that 1% from the Cyclone V system.
it is worth to mention that the only block that actually stores memory data is in the Serial_Data_Generator:

![image](https://user-images.githubusercontent.com/105777016/178105028-accc7139-8622-43bb-9b48-884ef66b3167.png)
![image](https://user-images.githubusercontent.com/105777016/178105031-980ef625-725c-456d-a331-d7ed32f96120.png)

The results:

![image](https://user-images.githubusercontent.com/105777016/178105143-e784c303-ac75-48a7-9289-d7635ce5996b.png)


Exactly as given in the .txt file.


#  Signal Tap

First I compiled the project on Quartus software:

![image](https://user-images.githubusercontent.com/105777016/178105066-26c902e6-a7c7-4853-a1f5-9fe9e8dab317.png)

Made sure that all the compilation tasks were done successfully:

![image](https://user-images.githubusercontent.com/105777016/178105113-0efe996f-9181-4a52-b103-891ae25c70d9.png)

After that, i created a .stp file which was saved inside ".par" folder:

![image](https://user-images.githubusercontent.com/105777016/178105173-2adb64da-ad11-45d7-b75a-97838eca7d88.png)

Then, I connected the Cyclove V kit to power & computer:

![image](https://user-images.githubusercontent.com/105777016/178105223-9a189af1-19a8-42cc-9cde-401645683ae8.png)

Signal tap configuration:
DISPLAY,START,RST - Active low

![image](https://user-images.githubusercontent.com/105777016/178105245-036d5c09-7006-431d-9fb3-83b14683f5c3.png)

Hardware configuration:

![image](https://user-images.githubusercontent.com/105777016/178105264-5113cb5a-d8a9-4556-8e0b-117956c75478.png)


After choosing DISPLAY and START, I made Basic OR operation between them:

![image](https://user-images.githubusercontent.com/105777016/178105299-2f643e60-e3f4-4bf0-a053-6ead0c9e5540.png)

Some states:

1) First time - START
![image](https://user-images.githubusercontent.com/105777016/178105315-65313908-d0f3-4b5d-8b77-6e5a853c900b.png)

2) First time - DISPLAY

![image](https://user-images.githubusercontent.com/105777016/178105335-c7b8c363-3c1e-4017-ab4f-b2b332485376.png)


3) START being pressed inside the process

![image](https://user-images.githubusercontent.com/105777016/178105332-57418f85-78f5-4493-96bd-a3f0a036cab3.png)


4) RESET in the middle of DISPLAY mode

![image](https://user-images.githubusercontent.com/105777016/178105336-58b297b7-df9c-4577-8a43-2dbc14bc9cd8.png)


START:

![image](https://user-images.githubusercontent.com/105777016/178105341-300f9b0a-cbde-41c7-97f8-ce37c13f2d7a.png)


63 on the 7SEG:
![image](https://user-images.githubusercontent.com/105777016/178105344-8e0687ca-94f4-4877-8fe1-805877b6cc7d.png)

001 on the 7SEG:

![image](https://user-images.githubusercontent.com/105777016/178105350-9810392a-39d9-4373-a646-bf2d0b036791.png)


# Hardware flow summart including signal tap:

![image](https://user-images.githubusercontent.com/105777016/178105361-24519126-cf84-4f89-b26c-40d42f0128cd.png)

As expected, while using signal tap, more memory units were in use (19456 vs. 18432 without stap).

# Timing Analyzer

![image](https://user-images.githubusercontent.com/105777016/178105426-af4951bb-5364-41d0-80e9-83741e9ce5d6.png)

The wizard:

![image](https://user-images.githubusercontent.com/105777016/178105433-454db537-c892-4d62-9ad5-9d7637aab0fd.png)

I am interested on "Report Fmax Summary" since i was requested in the system requirement to not pass the 50 [MHz] limit.

![image](https://user-images.githubusercontent.com/105777016/178105470-f6a651ea-9ddf-4fe4-9757-c2f746a503cc.png)

![image](https://user-images.githubusercontent.com/105777016/178105487-aee5ebee-3d0f-4e2a-bcef-321a70c27948.png)

The maximal frequency is 96.01[MHz] which doesn't bother me because my project operates on 50[MHz] which proves - I do not have timing problems :)

Finally, 
this is the system as requested: [Using RTL viewer]

![image](https://user-images.githubusercontent.com/105777016/178105516-bbb0109a-836c-4586-91c6-c666fc730a67.png)


Video of the project operation:

https://youtu.be/BonnT3YB5SE





