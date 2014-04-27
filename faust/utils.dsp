import("math.lib");

select4(i,a,b,c,d) = select2(i > 2, select3(i,a,b,c), d);

semitones = pow(1.05946, _);

stereomix(pan, l, r) = pan*l+(1-pan)*r, (1-pan)*l+pan*r;

// stateless random generator
rand(x) = fn(x) / (RAND_MAX + 1)
with {
  fn = ffunction(int random(float), "helpers.h", "");
  RAND_MAX = fconstant(int RAND_MAX, <math.h>);
};
