module Graphics.SDL2.SDLTTF

import Graphics.Color
import Graphics.SDL2.SDL
import Graphics.SDL2.Config

%include C "sdlrun2.h"
%include C "SDL2/SDL.h"
%include C "SDL2/SDL_ttf.h"
%link C "sdlrun2.o"
%lib C "SDL2_ttf"

%access public export

data SDLFont = MkFont Ptr


||| Open a font file and create a font of the specified point size.
||| Some .fon fonts will have several sizes embedded in the file, so the
||| point size becomes the index of choosing which size.  If the value
||| is too high, the last indexed size will be the default.
ttfOpenFont : (fontname: String) -> (fontsize: Int) -> IO SDLFont
ttfOpenFont fontname fontsize 
  = do ptr <- foreign FFI_C "TTF_OpenFont" (String -> Int -> IO Ptr) fontname fontsize
       np <- nullPtr ptr
       err <- ttfGetError
       putStrLn $ if np then fontname ++ " = null: " ++ err else fontname ++ " loaded"
       return (MkFont ptr)

--extern DECLSPEC TTF_Font * SDLCALL TTF_OpenFontIndex(const char *file, int ptsize, long index);
--extern DECLSPEC TTF_Font * SDLCALL TTF_OpenFontRW(SDL_RWops *src, int freesrc, int ptsize);
--extern DECLSPEC TTF_Font * SDLCALL TTF_OpenFontIndexRW(SDL_RWops *src, int freesrc, int ptsize, long index);



ttfCloseFont : SDLFont -> IO ()
ttfCloseFont (MkFont ptr) = foreign FFI_C "TTF_CloseFont" (Ptr -> IO ()) ptr


||| Create an 8-bit palettized surface and render the given text at
|||   fast quality with the given font and color.  The 0 pixel is the
|||   colorkey, giving a transparent background, and the 1 pixel is set
|||   to the text color.
|||   This function returns the new surface, or NULL if there was an error.
ttfRenderTextSolid : SDLRenderer -> SDLFont -> String -> SDLColor -> IO SDLTexture
ttfRenderTextSolid (MkRenderer r) (MkFont f) txt (MkColor c) 
  = do ptr <- foreign FFI_C "ttfRenderTextSolid" (Ptr -> Ptr -> String -> Ptr -> IO Ptr) r f txt c 
       return (MkTexture ptr)

renderTextSolid : SDLRenderer -> SDLFont -> String -> Color -> Int -> Int -> IO ()
renderTextSolid (MkRenderer r) (MkFont f) txt col x y
  = do (MkColor c) <- color col
       foreign FFI_C "renderTextSolid" (Ptr -> Ptr -> String -> Ptr -> Int -> Int -> IO ()) r f txt c x y
       return ()

--extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Solid(TTF_Font *font, const char *text, SDL_Color fg);
--extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Solid(TTF_Font *font, const Uint16 *text, SDL_Color fg);






{--
#ifndef _SDL_TTF_H
#define _SDL_TTF_H

#include "SDL.h"
#include "begin_code.h"

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

/* Printable format: "%d.%d.%d", MAJOR, MINOR, PATCHLEVEL
*/
#define SDL_TTF_MAJOR_VERSION   2
#define SDL_TTF_MINOR_VERSION   0
#define SDL_TTF_PATCHLEVEL      12

/* This macro can be used to fill a version structure with the compile-time
 * version of the SDL_ttf library.
 */
#define SDL_TTF_VERSION(X)                          \
{                                                   \
    (X)->major = SDL_TTF_MAJOR_VERSION;             \
    (X)->minor = SDL_TTF_MINOR_VERSION;             \
    (X)->patch = SDL_TTF_PATCHLEVEL;                \
}

/* Backwards compatibility */
#define TTF_MAJOR_VERSION   SDL_TTF_MAJOR_VERSION
#define TTF_MINOR_VERSION   SDL_TTF_MINOR_VERSION
#define TTF_PATCHLEVEL      SDL_TTF_PATCHLEVEL
#define TTF_VERSION(X)      SDL_TTF_VERSION(X)

/* This function gets the version of the dynamically linked SDL_ttf library.
   it should NOT be used to fill a version structure, instead you should
   use the SDL_TTF_VERSION() macro.
 */
extern DECLSPEC const SDL_version * SDLCALL TTF_Linked_Version(void);

/* ZERO WIDTH NO-BREAKSPACE (Unicode byte order mark) */
#define UNICODE_BOM_NATIVE  0xFEFF
#define UNICODE_BOM_SWAPPED 0xFFFE

/* This function tells the library whether UNICODE text is generally
   byteswapped.  A UNICODE BOM character in a string will override
   this setting for the remainder of that string.
*/
extern DECLSPEC void SDLCALL TTF_ByteSwappedUNICODE(int swapped);

/* The internal structure containing font information */
typedef struct _TTF_Font TTF_Font;



/* Set and retrieve the font style */
#define TTF_STYLE_NORMAL        0x00
#define TTF_STYLE_BOLD          0x01
#define TTF_STYLE_ITALIC        0x02
#define TTF_STYLE_UNDERLINE     0x04
#define TTF_STYLE_STRIKETHROUGH 0x08
extern DECLSPEC int SDLCALL TTF_GetFontStyle(const TTF_Font *font);
extern DECLSPEC void SDLCALL TTF_SetFontStyle(TTF_Font *font, int style);
extern DECLSPEC int SDLCALL TTF_GetFontOutline(const TTF_Font *font);
extern DECLSPEC void SDLCALL TTF_SetFontOutline(TTF_Font *font, int outline);

/* Set and retrieve FreeType hinter settings */
#define TTF_HINTING_NORMAL    0
#define TTF_HINTING_LIGHT     1
#define TTF_HINTING_MONO      2
#define TTF_HINTING_NONE      3
extern DECLSPEC int SDLCALL TTF_GetFontHinting(const TTF_Font *font);
extern DECLSPEC void SDLCALL TTF_SetFontHinting(TTF_Font *font, int hinting);

/* Get the total height of the font - usually equal to point size */
extern DECLSPEC int SDLCALL TTF_FontHeight(const TTF_Font *font);

/* Get the offset from the baseline to the top of the font
   This is a positive value, relative to the baseline.
 */
extern DECLSPEC int SDLCALL TTF_FontAscent(const TTF_Font *font);

/* Get the offset from the baseline to the bottom of the font
   This is a negative value, relative to the baseline.
 */
extern DECLSPEC int SDLCALL TTF_FontDescent(const TTF_Font *font);

/* Get the recommended spacing between lines of text for this font */
extern DECLSPEC int SDLCALL TTF_FontLineSkip(const TTF_Font *font);

/* Get/Set whether or not kerning is allowed for this font */
extern DECLSPEC int SDLCALL TTF_GetFontKerning(const TTF_Font *font);
extern DECLSPEC void SDLCALL TTF_SetFontKerning(TTF_Font *font, int allowed);

/* Get the number of faces of the font */
extern DECLSPEC long SDLCALL TTF_FontFaces(const TTF_Font *font);

/* Get the font face attributes, if any */
extern DECLSPEC int SDLCALL TTF_FontFaceIsFixedWidth(const TTF_Font *font);
extern DECLSPEC char * SDLCALL TTF_FontFaceFamilyName(const TTF_Font *font);
extern DECLSPEC char * SDLCALL TTF_FontFaceStyleName(const TTF_Font *font);

/* Check wether a glyph is provided by the font or not */
extern DECLSPEC int SDLCALL TTF_GlyphIsProvided(const TTF_Font *font, Uint16 ch);

/* Get the metrics (dimensions) of a glyph
   To understand what these metrics mean, here is a useful link:
    http://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html
 */
extern DECLSPEC int SDLCALL TTF_GlyphMetrics(TTF_Font *font, Uint16 ch,
                     int *minx, int *maxx,
                                     int *miny, int *maxy, int *advance);

/* Get the dimensions of a rendered string of text */
extern DECLSPEC int SDLCALL TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h);
extern DECLSPEC int SDLCALL TTF_SizeUTF8(TTF_Font *font, const char *text, int *w, int *h);
extern DECLSPEC int SDLCALL TTF_SizeUNICODE(TTF_Font *font, const Uint16 *text, int *w, int *h);

/* Create an 8-bit palettized surface and render the given glyph at
   fast quality with the given font and color.  The 0 pixel is the
   colorkey, giving a transparent background, and the 1 pixel is set
   to the text color.  The glyph is rendered without any padding or
   centering in the X direction, and aligned normally in the Y direction.
   This function returns the new surface, or NULL if there was an error.
*/
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderGlyph_Solid(TTF_Font *font,
                    Uint16 ch, SDL_Color fg);

/* Create an 8-bit palettized surface and render the given text at
   high quality with the given font and colors.  The 0 pixel is background,
   while other pixels have varying degrees of the foreground color.
   This function returns the new surface, or NULL if there was an error.
*/
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderText_Shaded(TTF_Font *font,
                const char *text, SDL_Color fg, SDL_Color bg);
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Shaded(TTF_Font *font,
                const char *text, SDL_Color fg, SDL_Color bg);
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Shaded(TTF_Font *font,
                const Uint16 *text, SDL_Color fg, SDL_Color bg);

/* Create an 8-bit palettized surface and render the given glyph at
   high quality with the given font and colors.  The 0 pixel is background,
   while other pixels have varying degrees of the foreground color.
   The glyph is rendered without any padding or centering in the X
   direction, and aligned normally in the Y direction.
   This function returns the new surface, or NULL if there was an error.
*/
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderGlyph_Shaded(TTF_Font *font,
                Uint16 ch, SDL_Color fg, SDL_Color bg);

/* Create a 32-bit ARGB surface and render the given text at high quality,
   using alpha blending to dither the font with the given color.
   This function returns the new surface, or NULL if there was an error.
*/
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderText_Blended(TTF_Font *font,
                const char *text, SDL_Color fg);
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Blended(TTF_Font *font,
                const char *text, SDL_Color fg);
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Blended(TTF_Font *font,
                const Uint16 *text, SDL_Color fg);


/* Create a 32-bit ARGB surface and render the given text at high quality,
   using alpha blending to dither the font with the given color.
   Text is wrapped to multiple lines on line endings and on word boundaries
   if it extends beyond wrapLength in pixels.
   This function returns the new surface, or NULL if there was an error.
*/
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderText_Blended_Wrapped(TTF_Font *font,
                const char *text, SDL_Color fg, Uint32 wrapLength);
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUTF8_Blended_Wrapped(TTF_Font *font,
                const char *text, SDL_Color fg, Uint32 wrapLength);
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderUNICODE_Blended_Wrapped(TTF_Font *font,
                const Uint16 *text, SDL_Color fg, Uint32 wrapLength);

/* Create a 32-bit ARGB surface and render the given glyph at high quality,
   using alpha blending to dither the font with the given color.
   The glyph is rendered without any padding or centering in the X
   direction, and aligned normally in the Y direction.
   This function returns the new surface, or NULL if there was an error.
*/
extern DECLSPEC SDL_Surface * SDLCALL TTF_RenderGlyph_Blended(TTF_Font *font,
                        Uint16 ch, SDL_Color fg);

/* For compatibility with previous versions, here are the old functions */
#define TTF_RenderText(font, text, fg, bg)  \
    TTF_RenderText_Shaded(font, text, fg, bg)
#define TTF_RenderUTF8(font, text, fg, bg)  \
    TTF_RenderUTF8_Shaded(font, text, fg, bg)
#define TTF_RenderUNICODE(font, text, fg, bg)   \
    TTF_RenderUNICODE_Shaded(font, text, fg, bg)

/* Close an opened font file */
extern DECLSPEC void SDLCALL TTF_CloseFont(TTF_Font *font);

/* De-initialize the TTF engine */
extern DECLSPEC void SDLCALL TTF_Quit(void);

/* Check if the TTF engine is initialized */
extern DECLSPEC int SDLCALL TTF_WasInit(void);

/* Get the kerning size of two glyphs */
extern DECLSPEC int TTF_GetFontKerningSize(TTF_Font *font, int prev_index, int index);

/* We'll use SDL for reporting errors */
#define TTF_SetError    SDL_SetError
#define TTF_GetError    SDL_GetError

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif
#include "close_code.h"

#endif /* _SDL_TTF_H */

--}
