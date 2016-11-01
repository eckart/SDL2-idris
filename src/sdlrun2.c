#include <stdio.h>
#include <SDL.h>
#include <SDL2_gfxPrimitives.h>
#include <SDL_ttf.h>
#include <SDL_syswm.h>
#include <SDL_video.h>
#include <idris_rts.h>


int initSDL() {
  return SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO);
}


void* createWindow(char* title, int xsize, int ysize) {
    SDL_Window *window;
    /*
    if(SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO) != 0 )
    {
	printf("Unable to init SDL2: %s\n", SDL_GetError());
	return NULL;
    }
    */
    //SDL_LogSetAllPriority(SDL_LOG_PRIORITY_VERBOSE);
    window = SDL_CreateWindow(title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			   xsize, ysize, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL | SDL_WINDOW_ALLOW_HIGHDPI);

    if (window==NULL) {
	printf("Unable to init SDL2: %s\n", SDL_GetError());
	return NULL;
    }

    return (void*) window;
}

void* createGLContext(void* window) {
  SDL_GL_SetAttribute(SDL_GL_SHARE_WITH_CURRENT_CONTEXT, 1);
  SDL_GLContext glcontext = SDL_GL_CreateContext(window);
  SDL_GLContext * ptr = &glcontext;
  return (void*) ptr;
}

void deleteGLContext(void* ctx) {
  SDL_GLContext* glContext = (SDL_GLContext*) ctx;
  SDL_GL_DeleteContext(*glContext); 
}


void glMakeCurrent(void* win, void* ctx) {
  SDL_GLContext* glContext = (SDL_GLContext*) ctx;
  SDL_Window* window = (SDL_Window*) window;
  SDL_GL_MakeCurrent(window, *glContext);
}

void* createRenderer(void* window) {
  SDL_Window* win = (SDL_Window*) window;
  SDL_Renderer *renderer = SDL_CreateRenderer(win,
					      -1,
					      SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);    
  if (renderer==NULL) {
    printf("SDL2: Unable to create renderer: %s\n", SDL_GetError());
    return NULL;
  }
  SDL_RenderClear(renderer);
  
  return (void*) renderer;
}

void renderPresent(void* s_in) {
  SDL_Renderer* r = (SDL_Renderer*)s_in;
  SDL_RenderPresent(r);
}

void quit(void* window, void* renderer) {
  SDL_Window* win = (SDL_Window*) window;
  SDL_Renderer* ren = (SDL_Renderer*) renderer;
  SDL_DestroyRenderer(ren);
  SDL_DestroyWindow(win);
  SDL_Quit();
}

// -----------------------------------------------------------------------------
// structs

void* color(int r, int g, int b, int a) {
  SDL_Color* col = malloc(sizeof(SDL_Color));
  col->r = r;
  col->g = g;
  col->b = b;
  col->a = a;

  return col;
}

void* rect(int x, int y, int w, int h) {
  SDL_Rect* rect = malloc(sizeof(SDL_Rect));
  rect->x = x;
  rect->y = y;
  rect->w = w;
  rect->h = h;
  return rect;
}

// -----------------------------------------------------------------------------
// drawing - may not be needed after all...
//
void pixel(void *s_in,
	   int x, int y,
	   int r, int g, int b, int a) 
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    pixelRGBA(s, x, y, r, g, b, a);
}

void filledRect(void *s_in,
	        int x, int y, int w, int h,
	        int r, int g, int b, int a) 
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    boxRGBA(s, x, y, x+w, y+h, r, g, b, a);
}

void filledEllipse(void* s_in,
		   int x, int y, int rx, int ry,
                   int r, int g, int b, int a) 
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    filledEllipseRGBA(s, x, y, rx, ry, r, g, b, a);
}

void drawLine(void* s_in,
	      int x, int y, int ex, int ey,
	      int r, int g, int b, int a) 
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    lineRGBA(s, x, y, ex, ey, r, g, b, a);
}


void filledTrigon(void* s_in,
		  int x1, int y1,
		  int x2, int y2,
		  int x3, int y3,
		  int r, int g, int b, int a)
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    filledTrigonRGBA(s, x1, y1, x2, y2, x3, y3, r, g, b, a);
}

// --------------------------------------------------------------------
// 
//

void filledPolygon(void* s_in, int* xs, int* ys, int n, int r, int g, int b, int a)
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    short u[n];
    short v[n];
    for (int i = 0; i < n ; i++) {
      //printf("(%i , %i  )", xs[i], ys[i]);
      u[i] = xs[i];
      v[i] = ys[i];
    }
    free(xs);
    free(ys);
    filledPolygonRGBA(s,
		      u, v,
		      n,
		      r, g, b, a);

}

void polygonAA(void* s_in, int* xs, int* ys, int n, int r, int g, int b, int a)
{
    SDL_Renderer* s = (SDL_Renderer*)s_in;
    short u[n];
    short v[n];
    for (int i = 0; i < n ; i++) {
      u[i] = xs[i];
      v[i] = ys[i];
    }
    free(xs);
    free(ys);
    aapolygonRGBA(s,
		      u, v,
		      n,
		      r, g, b, a);

}

void bezier(void* r_in,
	    int* xs, int* ys,
	    int n, // number of points, >= 3
	    int s, // steps for the interpolation
	    int r, int g, int b, int a)
{
    SDL_Renderer* renderer = (SDL_Renderer*)r_in;
    short u[n];
    short v[n];
    for (int i = 0; i < n ; i++) {
      u[i] = xs[i];
      v[i] = ys[i];
    }
    free(xs);
    free(ys);
    bezierRGBA(renderer,
	       u, v,
	       n, s,
	       r, g, b, a);

}

  

void* newArray(int len)
{
  int* buf = malloc(len*sizeof(int));
  return (void*) buf;
}

void setValue(int* arr, int idx, int val)
{
  arr[idx] = val;
}

// -----------------------------------------------------------------------------
// idris interop
//


VAL MOTION(VM* vm, int x, int y, int relx, int rely) {
    VAL m;
    idris_constructor(m, vm, 2, 4, 0);
    idris_setConArg(m, 0, MKINT((intptr_t)x));
    idris_setConArg(m, 1, MKINT((intptr_t)y));
    idris_setConArg(m, 2, MKINT((intptr_t)relx));
    idris_setConArg(m, 3, MKINT((intptr_t)rely));
    return m;
}

VAL BUTTON(VM* vm, int tag, int b, int x, int y) {
    VAL button;

    switch(b) {
    case SDL_BUTTON_LEFT:
        idris_constructor(button, vm, 0, 0, 0);
        break;
    case SDL_BUTTON_MIDDLE:
        idris_constructor(button, vm, 1, 0, 0);
        break;
    case SDL_BUTTON_RIGHT:
        idris_constructor(button, vm, 2, 0, 0);
        break;
    default:
        idris_constructor(button, vm, 0, 0, 0);
        break;
    }

    VAL event;
    idris_constructor(event, vm, tag, 3, 0);
    idris_setConArg(event, 0, button);
    idris_setConArg(event, 1, MKINT((intptr_t)x));
    idris_setConArg(event, 2, MKINT((intptr_t)y));

    return event;
}

VAL RESIZE(VM* vm, int w, int h) {
    VAL m;
    idris_constructor(m, vm, 6, 2, 0);
    idris_setConArg(m, 0, MKINT((intptr_t)w));
    idris_setConArg(m, 1, MKINT((intptr_t)h));
    return m;
}
VAL KEY(VM* vm, int tag, SDL_Keycode key) {
    VAL k;

    switch(key) {
    case SDLK_UP:
        idris_constructor(k, vm, 0, 0, 0);
	break;
    case SDLK_DOWN:
        idris_constructor(k, vm, 1, 0, 0);
	break;
    case SDLK_LEFT:
        idris_constructor(k, vm, 2, 0, 0);
	break;
    case SDLK_RIGHT:
        idris_constructor(k, vm, 3, 0, 0);
	break;
    case SDLK_ESCAPE:
        idris_constructor(k, vm, 4, 0, 0);
	break;
    case SDLK_SPACE:
        idris_constructor(k, vm, 5, 0, 0);
	break;
    case SDLK_TAB:
        idris_constructor(k, vm, 6, 0, 0);
	break;
    case SDLK_F1:
        idris_constructor(k, vm, 7, 0, 0);
	break;
    case SDLK_F2:
        idris_constructor(k, vm, 8, 0, 0);
	break;
    case SDLK_F3:
        idris_constructor(k, vm, 9, 0, 0);
	break;
    case SDLK_F4:
        idris_constructor(k, vm, 10, 0, 0);
	break;
    case SDLK_F5:
        idris_constructor(k, vm, 11, 0, 0);
	break;
    case SDLK_F6:
        idris_constructor(k, vm, 12, 0, 0);
	break;
    case SDLK_F7:
        idris_constructor(k, vm, 13, 0, 0);
	break;
    case SDLK_F8:
        idris_constructor(k, vm, 14, 0, 0);
	break;
    case SDLK_F9:
        idris_constructor(k, vm, 15, 0, 0);
	break;
    case SDLK_F10:
        idris_constructor(k, vm, 16, 0, 0);
	break;
    case SDLK_F11:
        idris_constructor(k, vm, 17, 0, 0);
	break;
    case SDLK_F12:
        idris_constructor(k, vm, 18, 0, 0);
	break;
    case SDLK_F13:
        idris_constructor(k, vm, 19, 0, 0);
	break;
    case SDLK_F14:
        idris_constructor(k, vm, 20, 0, 0);
	break;
    case SDLK_F15:
        idris_constructor(k, vm, 21, 0, 0);
	break;
    case SDLK_LSHIFT:
        idris_constructor(k, vm, 22, 0, 0);
	break;
    case SDLK_RSHIFT:
        idris_constructor(k, vm, 23, 0, 0);
	break;
    case SDLK_LCTRL:
        idris_constructor(k, vm, 24, 0, 0);
	break;
    case SDLK_RCTRL:
        idris_constructor(k, vm, 25, 0, 0);
	break;
    default:
        idris_constructor(k, vm, 26, 1, 0);
        // safe because there's no further allocation.
        idris_setConArg(k, 0, MKINT((intptr_t)key));
	break;
    }

    VAL event;
    idris_constructor(event, vm, tag, 1, 0);
    idris_setConArg(event, 0, k);

    return event;
}

/*
data Event = KeyDown Key                        -- 0
           | KeyUp Key                          -- 1
           | MouseMotion Int Int Int Int        -- 2
           | MouseButtonDown Button Int Int     -- 3
           | MouseButtonUp Button Int Int       -- 4
	   | MouseWheel Int                     -- 5
	   | Resize Int Int                     -- 6
	   | AppQuit                            -- 7
	   | WindowEvent                        -- 8

 */


void* processEvent(VM* vm, int r, SDL_Event * e) {
  VAL idris_event;

  SDL_Event event = *e;
  idris_requireAlloc(128); // Conservative!

  if (r==0) {
    idris_constructor(idris_event, vm, 0, 0, 0); // Nothing
  }
  else {
    VAL ievent = NULL;
    switch(event.type) {
    case SDL_KEYDOWN:
      ievent = KEY(vm, 0, event.key.keysym.sym);
      break;
    case SDL_KEYUP:
      ievent = KEY(vm, 1, event.key.keysym.sym);
      break;
    case SDL_MOUSEMOTION:
      ievent = MOTION(vm, event.motion.x, event.motion.y,
		      event.motion.xrel, event.motion.yrel);
      break;
    case SDL_MOUSEBUTTONDOWN:
      ievent = BUTTON(vm, 3, event.button.button, event.button.x, event.button.y);
      break;
    case SDL_MOUSEBUTTONUP:
      ievent = BUTTON(vm, 4, event.button.button, event.button.x, event.button.y);
      break;
    case SDL_MOUSEWHEEL:
      idris_constructor(ievent, vm, 5, 1, 0);
      idris_setConArg(ievent, 0, MKINT((intptr_t) event.wheel.y));
      break;
    case SDL_WINDOWEVENT:
      switch(event.window.event) {
      case SDL_WINDOWEVENT_RESIZED:
	ievent = RESIZE(vm, event.window.data1, event.window.data2);
	break;
      default:
	// TODO: other window events
	idris_constructor(ievent, vm, 8, 0, 0);
      }
      break;
    case SDL_QUIT:
      idris_constructor(ievent, vm, 7, 0, 0);
      break;
    default:
      idris_constructor(idris_event, vm, 0, 0, 0); // Nothing
      idris_doneAlloc(vm);
      return idris_event;
    }
    idris_constructor(idris_event, vm, 1, 1, 0);
    idris_setConArg(idris_event, 0, ievent); // Just ievent
  }
  
  idris_doneAlloc(vm);
  return idris_event;
}


void* pollEvent(VM* vm) 
{

  SDL_Event event; // = (SDL_Event *) GC_MALLOC(sizeof(SDL_Event));
  int r = SDL_PollEvent(&event);
  
  return processEvent(vm, r, &event);
}

void* waitEvent(VM* vm) 
{

  SDL_Event event; // = (SDL_Event *) GC_MALLOC(sizeof(SDL_Event));
  int r = SDL_WaitEvent(&event);
  
  return processEvent(vm, r, &event);
}

// -----------------------------------------------------------------------------
// TTF wrapper

void* ttfRenderTextSolid(SDL_Renderer* renderer, TTF_Font *font, const char *text, SDL_Color* col) {
  SDL_Surface* srf = TTF_RenderText_Solid(font, text, *col);
  if (srf == NULL) {
    return NULL;
  }

  SDL_Texture* tx = SDL_CreateTextureFromSurface(renderer, srf);
  SDL_FreeSurface(srf);

  return tx;
  
}

void renderTextSolid(SDL_Renderer* renderer, TTF_Font *font, const char *text, SDL_Color* col, int x, int y) {
  
  SDL_Texture* texture = ttfRenderTextSolid(renderer, font, text, col);
  /*
  if (renderer == NULL) {
    printf("renderer is null\n");
  }

  if (texture == NULL) {
    printf("texture is null\n");
  }

  if (font == NULL) {
    printf("font is null\n");
  }
  */
  SDL_Rect dst;
  SDL_QueryTexture(texture, NULL, NULL, &dst.w, &dst.h);
  dst.x = x;
  dst.y = y;

  SDL_RenderCopy(renderer, texture, NULL, &dst);

  SDL_DestroyTexture(texture);

}
