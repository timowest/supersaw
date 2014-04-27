import("music.lib");
import("filter.lib");
import("math.lib");

import("utils.dsp");

detunes(freq, detune) = relations : par(i, 7, tune)
with {
  relations = -0.11002313, -0.06288439, -0.01952356, 0, 0.01991221, 0.06216538, 0.10745242;
  tune = *(y):+(1):*(freq); //(1+y*rel) * freq;
  fn(x) = (10028.7312891634*pow(x,11)) - (50818.8652045924*pow(x,10)) + (111363.4808729368*pow(x,9)) -
      (138150.6761080548*pow(x,8)) + (106649.6679158292*pow(x,7)) - (53046.9642751875*pow(x,6)) + 
      (17019.9518580080*pow(x,5)) - (3425.0836591318*pow(x,4)) + (404.2703938388*pow(x,3)) - 
      (24.1878824391*pow(x,2)) + (0.6717417634*x) + 0.0030115596;
  y = fn(detune);
};

sosc(freq, gate) = freq : (phase~_) : *(2):-(1)
with {  
  phase(prev, f) = select2(reset, fmod(prev + f / SR, 1.0), rand(f)); 
  reset = gate > mem(gate);
};

mixer(ctrl) = par(i, 3, side * _), main * _, par(i, 3, side * _) :> _
with {
  main = -0.55366*ctrl + 0.99785;
  side = -0.73764*pow(ctrl, 2) + 1.2841*ctrl + 0.044372;
};

// biquad in transposed direct form II 
biquad = (fn ~ (_,_)) : (!,!,_)
with {
  fn(z1_,z2_,b0,b1,b2,a1,a2,x) = z1,z2,y 
  with { 
    y =        (b0 * x) + z1_;
    z1 = z2_ + (b1 * x) - (a1 * y);
    z2 =       (b2 * x) - (a2 * y);
  };
};

hp(freq, res) = biquad(b0,b1,b2,a1,a2) : biquad(b0,b1,b2,a1,a2)
with {
  w = freq / SR;
  r = max(0.001, 2.0 * (1.0 - res));
  k = tan(w * PI);
  k2 = k * k;
  rk = r * k;
  bh = 1.0 + rk + k2;

  b0 = 1.0 / bh;
  b1 = -2.0 / bh;
  b2 = b0;
  a1 = (2.0 * (k2 - 1.0)) / bh;
  a2 = (1.0 - rk + k2) / bh;
};

supersaw(freq, detune, mix, gate) = detunes(freq, detune)
                                  : par(i, 7, sosc(_,gate)) 
                                  : mixer(mix) : hp(freq, 0.3);

//process = supersaw;



