import("math.lib");
import("utils.dsp");

svf(fc, res, type) = fn ~ (_,_,_) : (!,!,!,_)
with {
  g = tan(PI * fc / SR);
  k = 1.0 - 0.99 * res;
  ginv = g / (1.0 + g * (g + k));
  g1 = ginv;
  g2 = 2.0 * (g+k) * ginv;
  g3 = g * ginv;
  g4 = 2.0 * ginv;

  fn(v0_, v1_, v2_, x) = v0, v1, v2, out
  with {
    v0 = x;
    v3 = v0 + v0_ - 2.0 * v2_;
    v1 = v1_ + (g1 * v3 - g2 * v1_);
    v2 = v2_ + (g3 * v3 + g4 * v1_);

    // LP BP HP N
    out = select4(type, v2, v1, v0 - k * v1 - v2, v0 - k * v1);
  };
};

//process = svf(1000.0, 1, 0);
