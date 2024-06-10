#include <stdlib.h>
#include <sys/types.h>
#include <libgte.h>
#include <libetc.h>
#include <libgpu.h>

#define VIDEO_MODE 0
#define SCREEN_RES_X 320
#define SCREEN_RES_Y 240
#define SCREEN_CENTER_X (SCREEN_RES_X >> 1)
#define SCREEN_CENTER_Y (SCREEN_RES_Y >> 1)
#define SCREEN_Z 400

#define OT_LENGTH 16

///////////////////////////////////////////////////////////////////////////////
// Declarations and global variables
///////////////////////////////////////////////////////////////////////////////
typedef struct {
    DRAWENV draw[2];
    DISPENV disp[2];
} DoubleBuff;

DoubleBuff screen;           // Struct to hold the display & draw buffers
u_short currbuff;            // Holds the current buffer number (0 or 1)

u_long ot[2][OT_LENGTH];     // Ordering table holding pointers to sorted primitives

char primbuff[2][2048];      // Primitive buffer that holds the actual data for each primitive
char *nextprim;              // Pointer to the next primitive in the primitive buffer

POLY_F3 *polyf3;             // Flat-shaded triangle
TILE *tile;                  // Flat-shaded rectangular tile
POLY_G4 *quadg4;             // Gouraud-shaded quad

///////////////////////////////////////////////////////////////////////////////
// Initialize the display mode and setup double buffering
///////////////////////////////////////////////////////////////////////////////
void ScreenInit(void) {
    // Reset GPU
    ResetGraph(0);

    // Set the display area of the first buffer
    SetDefDispEnv(&screen.disp[0], 0,   0, SCREEN_RES_X, SCREEN_RES_Y);
    SetDefDrawEnv(&screen.draw[0], 0, 240, SCREEN_RES_X, SCREEN_RES_Y);

    // Set the display area of the second buffer
    SetDefDispEnv(&screen.disp[1], 0, 240, SCREEN_RES_X, SCREEN_RES_Y);
    SetDefDrawEnv(&screen.draw[1], 0,   0, SCREEN_RES_X, SCREEN_RES_Y);

    // Set the back/drawing buffer
    screen.draw[0].isbg = 1;
    screen.draw[1].isbg = 1;

    // Set the background clear color
    setRGB0(&screen.draw[0], 63, 0, 127); // dark purple
    setRGB0(&screen.draw[1], 63, 0, 127); // dark purple

    // Set the current initial buffer
    currbuff = 0;
    PutDispEnv(&screen.disp[currbuff]);
    PutDrawEnv(&screen.draw[currbuff]);

    // Initialize and setup the GTE geometry offsets
    InitGeom();
    SetGeomOffset(SCREEN_CENTER_X, SCREEN_CENTER_Y);
    SetGeomScreen(SCREEN_Z);

    // Enable display
    SetDispMask(1);
}

///////////////////////////////////////////////////////////////////////////////
// Draw the current frame primitives in the ordering table
///////////////////////////////////////////////////////////////////////////////
void DisplayFrame(void) {
    // Sync and wait for vertical blank
    DrawSync(0);
    VSync(0);

    // Set the current display & draw buffers
    PutDispEnv(&screen.disp[currbuff]);
    PutDrawEnv(&screen.draw[currbuff]);

    // Draw the ordering table for the current buffer
    DrawOTag(ot[currbuff] + OT_LENGTH - 1);

    // Swap current buffer
    currbuff = !currbuff;

    // Reset next primitive pointer to the start of the primitive buffer
    nextprim = primbuff[currbuff];
}

///////////////////////////////////////////////////////////////////////////////
// Setup function that is called once at the beginning of the execution
///////////////////////////////////////////////////////////////////////////////
void Setup(void) {
    // Setup the display environment
    ScreenInit();

    // Reset next primitive pointer to the start of the primitive buffer
    nextprim = primbuff[currbuff];
}

///////////////////////////////////////////////////////////////////////////////
// Setup function that is called once at the beginning of the execution
///////////////////////////////////////////////////////////////////////////////
void Update(void) {
    // Empty the Ordering Table
    ClearOTagR(ot[currbuff], OT_LENGTH);

    tile = (TILE*) nextprim;                             // Cast next primitive
    setTile(tile);                                       // Initialize primitive
    setXY0(tile, 82, 32);                                // Set primitive (x,y) position
    setWH(tile, 64, 64);                                 // Set primitive width and height size
    setRGB0(tile, 0, 255, 0);                            // Set primitive color
    addPrim(ot[currbuff], tile);                         // Add & sort primitive into ordering table
    nextprim += sizeof(TILE);                            // Advance nextprim pointer

    polyf3 = (POLY_F3*) nextprim;                        // Cast next primitive
    setPolyF3(polyf3);                                   // Initialize primitive
    setXY3(polyf3, 64, 100, 200, 150, 50, 220);          // Set primitive vertices (x0,y0), (x1,y1), (x2,y2)
    setRGB0(polyf3, 255, 0, 255);                        // Set primitive color
    addPrim(ot[currbuff], polyf3);                       // Add & sort primitive into ordering table
    nextprim += sizeof(POLY_F3);                         // Advance nextprim pointer

    quadg4 = (POLY_G4*) nextprim;
    setPolyG4(quadg4);
    setXY4(quadg4, 82 + 128, 32, 82 + 128 + 64, 32, 82 + 128, 64, 82 + 128 + 64, 64);
    setRGB0(quadg4, 255, 255, 255);
    setRGB1(quadg4, 0, 255, 255);
    setRGB2(quadg4, 255, 0, 255);
    setRGB3(quadg4, 255, 255, 0);
    addPrim(ot[currbuff], quadg4);
    nextprim += sizeof(POLY_G4);
}

///////////////////////////////////////////////////////////////////////////////
// Render function that invokes the draw of the current frame
///////////////////////////////////////////////////////////////////////////////
void Render(void) {
    DisplayFrame();
}

///////////////////////////////////////////////////////////////////////////////
// Main function
///////////////////////////////////////////////////////////////////////////////
int main(void) {
    Setup();
    while (1) {
        Update();
        Render();
    }
    return 0;
}
