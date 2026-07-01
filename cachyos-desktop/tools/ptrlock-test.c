#include <SDL2/SDL.h>
#include <stdio.h>

#define JUMP_THRESHOLD 200

int main(void) {
    SDL_Init(SDL_INIT_VIDEO);
    SDL_Window *win = SDL_CreateWindow(
        "Pointer Lock Test — click to grab, ESC to release",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        640, 480, SDL_WINDOW_SHOWN);
    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, 0);

    int grabbed = 0;
    int total_x = 0, total_y = 0;
    Uint32 start_ticks = SDL_GetTicks();
    SDL_Event e;

    printf("Click window to grab pointer. ESC to release. Ctrl-C to quit.\n");
    fflush(stdout);

    while (1) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) goto done;
            if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) {
                SDL_SetRelativeMouseMode(SDL_FALSE);
                grabbed = 0;
                printf("[%6u ms] Released\n", SDL_GetTicks() - start_ticks);
                fflush(stdout);
            }
            if (e.type == SDL_MOUSEBUTTONDOWN && e.button.button == SDL_BUTTON_LEFT) {
                if (SDL_SetRelativeMouseMode(SDL_TRUE) == 0) {
                    grabbed = 1;
                    total_x = total_y = 0;
                    printf("[%6u ms] Grabbed\n", SDL_GetTicks() - start_ticks);
                } else {
                    printf("[%6u ms] Grab failed: %s\n", SDL_GetTicks() - start_ticks, SDL_GetError());
                }
                fflush(stdout);
            }
            if (e.type == SDL_MOUSEMOTION && grabbed) {
                int ax = e.motion.xrel < 0 ? -e.motion.xrel : e.motion.xrel;
                int ay = e.motion.yrel < 0 ? -e.motion.yrel : e.motion.yrel;
                int jump = ax > JUMP_THRESHOLD || ay > JUMP_THRESHOLD;
                total_x += e.motion.xrel;
                total_y += e.motion.yrel;
                printf("[%6u ms] %srel(%d, %d)  total(%d, %d)\n",
                    SDL_GetTicks() - start_ticks,
                    jump ? "*** JUMP *** " : "",
                    e.motion.xrel, e.motion.yrel, total_x, total_y);
                fflush(stdout);
            }
        }

        SDL_SetRenderDrawColor(ren,
            grabbed ? 0 : 40,
            grabbed ? 120 : 40,
            0, 255);
        SDL_RenderClear(ren);
        SDL_RenderPresent(ren);
        SDL_Delay(16);
    }
done:
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    return 0;
}
