#Here, I will talk about some milestones my project and the things that I've done and been doing now.
First, understanding about normal system of LFSR (stand for Linear feedback shift register) used formally in PRNG (psuedo-random number generator)
- LFSR will bring for us the formular to produce **random** number generator that can be applied in cyber security because it is produced following a **complex** equation.
- Diving into LFSR a little bit that's each bit will be shifted right one positon (just for example, you guys can shift left as well). At that time, there's always a position that haven't had number yet. We need to have XOR any exist bit at here to fullfill this space:

  <img width="1874" height="1060" alt="image" src="https://github.com/user-attachments/assets/1e363636-6adc-4ef5-9ed6-538cee3ea775" />

