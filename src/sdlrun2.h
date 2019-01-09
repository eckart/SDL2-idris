#ifndef __SDLRUN_H
#define __SDLRUN_H

#include <idris_rts.h>
#include <SDL.h>
#include <SDL2_gfxPrimitives.h>
#include <SDL_ttf.h>

int initSDL();

// enums

int idr_get_pixel_format(int i);


// Start SDL, open a window with dimensions (x,y) - return the window
void* createWindow(char* title, int xsize, int ysize);

int idr_GetWindowWidth(void* win);
int idr_GetWindowHeight(void* win);


// create a renderer for the window
void* createRenderer(void* window);

void renderPresent(void* s_in);

// quit sdl and cleanup
void quit(void* window, void* renderer);


void* idr_lock_texture(SDL_Texture* texture, VM* vm);

// Events
void* pollEvent(VM* vm); // builds an Idris value
void* waitEvent(VM* vm); // builds an Idris value

// Structs

void* color(int r, int g, int b, int a);
void* rect(int x, int y, int w, int h);

// these are really needed

void filledPolygon(void* s_in,
		   int* xs, int* ys, int n,
		   int r, int g, int b, int a);

void strokePolygon(void* s_in,
		   int* xs, int* ys, int n,
		   int r, int g, int b, int a);

void strokeAAPolygon(void* s_in,
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
