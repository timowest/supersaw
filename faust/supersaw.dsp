import("music.lib");
import("math.lib");

import("osc.dsp");
import("filter.dsp");
import("utils.dsp");

lfo(freq, depth, type) = (phase~_) : wave : *(depth)
with {
  inc = freq / SR;
  phase = fmod(_ + inc, 1.0);
  tri(p) = select2(p < 0.5, 
                   2.0 * (1.0 - (p-0.5) / 0.5) - 1.0,
                   4.0 * p - 1.0);
  saw(p) = 2.0 * p - 1.0;
  pulse(p) = select2(p < 0.5, 1.0, -1.0);
  wave(p) = select4(type, tri(p), saw(p), pulse(p), noise);
};

// TODO curve
env(a,d,s,r,t) = adsr(a,d,s,r,t);

synth = lfo1 <: (osc1, osc2, noise) 
        : (mixer, env1, lfo2)
        : (filter, env2, lfo3) 
        : amp
with {
  freq = nentry("freq", 440, 20, 20000, 1); // Hz
  gain = nentry("gain", 0.3, 0, 10, 0.01); // %
  gate = button("gate"); // 0/1

  oscfine = hslider("oscfine", 0, -1, 1, 0.01);

  osc1coarse = hslider("osc1coarse", 0, -24, 24, 1);
  osc1(mod) = supersaw(freq * semitones(osc1coarse + mod + oscfine),
                       hslider("osc1detune", 0, 0, 1, 0.01),
                       hslider("osc1mix", 0, 0, 1, 0.01),
                       gate);

  osc2coarse = hslider("osc2coarse", 0, -24, 24, 1); 
  osc2(mod) = supersaw(freq * semitones(osc2coarse + mod - oscfine),
                       hslider("osc2detune", 0, 0, 1, 0.01), 
                       hslider("osc2mix", 0, 0, 1, 0.01),
                       gate);

  mixer(o1, o2, n) = (o1*osc1vol + n*noisevol, o2*osc2vol + n*noisevol)
                     : stereomix(oscpan)
  with {
    osc1vol = hslider("osc1vol", 1, 0, 1, 0.01);
    osc2vol = hslider("osc2vol", 1, 0, 1, 0.01);
    noisevol = hslider("noisevol", 0, 0, 1, 0.01);
    oscpan = hslider("oscpan", 0.5, 0, 1, 0.01);
  };

  dcf(freq) = svf(freq, 
                  hslider("dcf1res", 0, 0, 1, 0.01),
                  hslider("dcf1type", 0, 0, 3, 1));

  // TODO key follow
  filter(l, r, menv, mlfo) = dcf(freq, l), dcf(freq, r)
  with {
    filtervel = hslider("filtervel", 0, 0, 1, 0.01);
    dcf1freq = hslider("dcf1freq", 440, 20, 15000, 10);
    envdepth = hslider("dc1envdepth", 0, 0, 1, 0.1);
    freq = dcf1freq * semitones(12*filtervel*gain 
                              + 24*envdepth*menv 
                              + 12*mlfo);
  };

  amp(l, r, menv, mlfo) = mod * l, mod * r
  with {
    ampvel = hslider("ampvel", 0, 0, 1, 0.01);
    volume = hslider("volume", 1, 0, 1, 0.01);
    mod = volume * menv * (0.5+0.5*mlfo);
  };

  // modulation

  lfo1 = lfo(hslider("lfo1freq", 1.0, 0.1, 10, 0.1), // Hz
             hslider("lfo1depth", 0.0, 0.0, 1.0, 0.01),
             hslider("lfo1type", 0, 0, 3, 1));
  lfo2 = lfo(hslider("lfo2freq", 1.0, 0.1, 10, 0.1), // Hz
             hslider("lfo2depth", 0.0, 0.0, 1.0, 0.01),
             hslider("lfo2type", 0, 0, 3, 1));
  lfo3 = lfo(hslider("lfo3freq", 1.0, 0.1, 10, 0.1), // Hz
             hslider("lfo3depth", 0.0, 0.0, 1.0, 0.01),
             hslider("lfo3type", 0, 0, 3, 1));

  env1 = env(hslider("env1attack", 0.01, 0, 4, 0.01), // secs
             hslider("env1decay", 0.1, 0, 4, 0.01), // secs
             hslider("env1sustain", 0.8, 0, 1, 0.01),
             hslider("env1release", 1, 0, 4, 0.01), // secs  
             gate);
  env2 = env(hslider("env2attack", 0.01, 0, 4, 0.01), // secs
             hslider("env2decay", 0.1, 0, 4, 0.01), // secs
             hslider("env2sustain", 0.8, 0, 1, 0.01),
             hslider("env2release", 1, 0, 4, 0.01), // secs
             gate);              
};

process = synth;
