#ifndef __SDLRUN_H
#define __SDLRUN_H

#include <idris_rts.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL2_gfxPrimitives.h>
#include <SDL2/SDL_ttf.h>

// Start SDL, open a window with dimensions (x,y) - return the window
void* createWindow(char* title, int xsize, int ysize);

// create a renderer for the window
void* createRenderer(void* window);

void renderPresent(void* s_in);

// quit sdl and cleanup
void quit(void* window, void* renderer);

// Events
void* pollEvent(VM* vm); // builds an Idris value
void* waitEvent(VM* vm); // builds an Idris value

// Structs

void* color(int r, int g, int b, int a);
void* rect(int x, int y, int w, int h);

// Drawing primitives

void pixel(void *s_in,
	   int x, int y,
	   int r, int g, int b, int a);

void filledRect(void *s,
	        int x, int y, int w, int h,
	        int r, int g, int b, int a);

void filledEllipse(void* s_in,
		   int x, int y, int rx, int ry,
                   int r, int g, int b, int a);
void drawLine(void* s_in,
	      int x, int y, int ex, int ey,
	      int r, int g, int b, int a);

void filledTrigon(void* s_in,
		  int x1, int y1,
		  int x2, int y2,
		  int x3, int y3,
		  int r, int g, int b, int a);

// these are really needed

void filledPolygon(void* s_in,
		   int* xs, int* ys, int n,
		   int r, int g, int b, int a);

void polygonAA(void* s_in,
	       int* xs, int* ys, int n,
	       int r, int g, int b, int a);

// http://www.ferzkopp.net/Software/SDL2_gfx/Docs/html/_s_d_l2__gfx_primitives_8h.html#a6cb082e6eb4253d591927c6bf7eba06f
void bezier(void* renderer,
	    int* xs, int* ys,
	    int n, // number of points, >= 3
	    int s, // steps for the interpolation
	    int r, int g, int b, int a);
  
// buffer related

void* newArray(int len);

void setValue(int* arr, int idx, int val);


// -----------------------------------------------------------------------------
// TTF wrapper

void* ttfRenderTextSolid(SDL_Renderer* renderer, TTF_Font *font, const char *text, SDL_Color* col);
void renderTextSolid(SDL_Renderer* renderer, TTF_Font *font, const char *text, SDL_Color* col, int x, int y);

// -----------------------------------------------------------------------------
// GL 

void* createGLContext(void* window);

void deleteGLContext(void* ctx);

void glMakeCurrent(void* win, void* ctx);

#endif
