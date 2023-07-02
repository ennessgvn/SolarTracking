# SolarTracking
In this design, where fuzzy logic is implemented, the function of catching the sun's rays upright is performed. 

## Processing of Light Sensor Data
In this constructed work, the light data that will enter the FPGA via the 4-bit ADC is made sense in the "ldr_control" design inside. Incoming 4-bit data is first assigned to integer value and averaged. The averaged data is reassigned to a 4-bit value and sent to a higher design.

![image](https://github.com/ennessgvn/SolarTracking/assets/79998692/8b50dd83-b011-4eb6-b84d-c678ca9a5543)

## Fuzzy Logic Design
### 1)Fuzzification Design
The averaged data is sent to the "Fuzzy Logic" design to be blurred in 4-bit values. In the design, membership functions and boundaries are defined as internal signals.

![image](https://github.com/ennessgvn/SolarTracking/assets/79998692/1f910eaa-a4e9-4629-8663-e216316ea385)

Input values ​​are sent to the "Fuzzy-Rulebase" block for analysis in the rule base, taking into account the membership functions with defined boundary values.

### 2)Fuzzy Rulebase Design

The fuzzy data is analyzed in terms of 49 rule bases. Each membership function is compared to the boundaries of the membership function of the other input.

![image](https://github.com/ennessgvn/SolarTracking/assets/79998692/8f66893c-469a-41de-960a-f3c7b3612322)


Entries that have been examined on the rule base and can take values ​​within the limits of their own are sent to the "Defuzzification" design for defuzzification.

### 3)Defuzzification Design
Inputs that can take values ​​within the limits of their own are clarified in this design for use in the real world.

![image](https://github.com/ennessgvn/SolarTracking/assets/79998692/01edc856-8570-4e14-8b46-24511f8920f0)

According to the value it receives in the rule base, the "fuzzy_out" output and the motor drive counter value of that output are sent to the upper blocks for processing. The resulting "fuzzy_out" indicates at what level the motor will be driven.

## Motor Drive Design
In this design, depending on the level at which the motor will be driven, motor driving is performed at a certain counter value.

![image](https://github.com/ennessgvn/SolarTracking/assets/79998692/bbc61cab-8bcf-4b50-aacd-68e11f286127)

For example, if "fuzzy_out" is "000" as seen in the picture, the motor will be driven at a very low level and the counter value for that level will be used. In the "Defuzzification" block, this counter value was four. Therefore, the motor will make 4 full turns and bring the panel to the position where it catches the sun's rays vertically.





