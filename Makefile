BUNDLE = faust/supersaw.lv2
INSTALL_DIR = /usr/local/lib/lv2
ALSA_GTK = `pkg-config --cflags --libs alsa` `pkg-config --cflags --libs gtk+-2.0`
FAUST = -I/usr/local/lib/faust/
FAUSTTOOLSFLAGS = -Isrc
export FAUSTTOOLSFLAGS

#CFLAGS=-O3 -mtune=native -march=native -mfpmath=sse -ffast-math -ftree-vectorize
CFLAGS=-mtune=native -march=native -mfpmath=sse -ffast-math -ftree-vectorize  

$(BUNDLE):
	faust2lv2synth -I src faust/supersaw.dsp

install: $(BUNDLE)
	mkdir -p $(INSTALL_DIR)
	rm -rf $(INSTALL_DIR)/$(BUNDLE)
	cp -R $(BUNDLE) $(INSTALL_DIR)

standalone: gen
	faust -vec -a alsa-gtk.cpp -I src faust/supersaw.dsp > gen/supersaw.cpp
	g++ -Wall gen/supersaw.cpp  -Isrc $(ALSA_GTK) $(FAUST) $(CFLAGS) -lm -o supersaw.out

run:
	jalv.gtk http://faust-lv2.googlecode.com/supersaw

gen:
	mkdir gen

clean:
	rm -rf $(BUNDLE) *.so *.out gen/* faust/*-svg 
