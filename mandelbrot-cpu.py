import numpy as np
import pygame
import matplotlib
from numba import njit, prange
from math import log, atan2, pi

# parameters
win_w, win_h = 1000, 1000
maxit = 500
view  = {'cx': -0.5, 'cy': 0.0, 'zoom': 1.0}
drag  = {'active': False, 'x0': 0, 'y0': 0, 'cx0': 0.0, 'cy0': 0.0}

log2 = log(2.0)
inv_2pi = 1.0 / (2.0 * pi)

@njit(parallel=True, cache=True, fastmath=True)
def mandelbrot_kernel(w, h, maxit, cx, cy, zoom):
    mask        = np.zeros(w * h, dtype=np.uint16)
    smooth_mask = np.zeros(w * h, dtype=np.float32)
    angle_grid  = np.zeros(w * h, dtype=np.uint8)

    s = min(w, h)
    inv_s = 4.0 / (s * zoom)
    half_height = 0.5 * h
    half_width  = 0.5 * w
    
    for iy in prange(h):
        ci = cy + (iy - half_height) * inv_s
        for ix in prange(w):
            # i is the pixel index
            # conversion from pixel index to space coordinate
            i = iy * w + ix
            cr = cx + (ix - half_width) * inv_s
    
            # main bulb and interior region skips; points here won't ever escape
            a  = cr - 0.25
            r2 = a*a + ci*ci
            skip = (
                ((cr + 1.0)*(cr + 1.0) + ci*ci) < 0.0625
                or (r2*r2 + a*r2 - 0.0625*ci*ci) < 0
                or ((cr + 1.308)*(cr + 1.308) + ci*ci) < 0.003
                or ((cr + 0.125)*(cr + 0.125) + (ci + 0.745)*(ci + 0.745)) < 0.008
                or ((cr + 0.125)*(cr + 0.125) + (ci - 0.745)*(ci - 0.745)) < 0.008
            )
            if skip:
                mask[i]        = maxit
                smooth_mask[i] = maxit
                angle_grid[i]  = 0
            else:
                # MAIN LOOP
                zr = 0.0; zi = 0.0           # real, imag
                prev_zr = 0.0; prev_zi = 0.0 # z before the escape step
                zr_old = 0.0; zi_old = 0.0   # old_real, old_imag for periodicity checks
                it = 0                       # current iteration
                period = 1                   # current cycle length being tested
                countdown = 1                # iterations until next reference update
                escaped = False
    
                while it < maxit:
                    it += 1
    
                    # snapshot z before update
                    prev_zr = zr
                    prev_zi = zi
    
                    # compute z --> z^2 + c
                    zr2 = zr*zr; zi2 = zi*zi
                    zr_new = zr2 - zi2 + cr
                    zi     = 2.0*zr*zi + ci
                    zr     = zr_new
    
                    # if out of bounds, break
                    if zr2 + zi2 > 4.0:
                        # angle of the step from prev_z to new z
                        dz_r = zr - prev_zr
                        dz_i = zi - prev_zi
    
                        # compute cmap index internally
                        angle_grid[i]  = np.uint8((atan2(dz_i, dz_r) + np.pi) * inv_2pi * 255)
    
                        log_zn         = log(zr*zr + zi*zi) * 0.5
                        nu             = log(log_zn) / log2 - 1.0
                        smooth_mask[i] = np.float32(it - nu)  # fractional, continuous across boundaries
                        mask[i]        = it
                        escaped        = True
                        break
    
                    # if periodic, break
                    if zr == zr_old and zi == zi_old:
                        mask[i] = maxit; angle_grid[i] = 0; smooth_mask[i] = maxit
                        break
    
                    # Brent's Cycle detection algorithm
                    countdown -= 1
                    if countdown == 0:
                        zr_old    = zr
                        zi_old    = zi
                        period    *= 2      # double the window each time
                        countdown = period  # reset countdown to new period
    
                if not escaped and mask[i] == 0:
                    mask[i] = maxit; angle_grid[i] = 0; smooth_mask[i] = maxit

    return mask, smooth_mask, angle_grid

# set colormap lut
cmap   = matplotlib.colormaps['inferno'].resampled(256)
lut    = (cmap(np.linspace(0, 1, 256))[:, :3] * 255).astype(np.uint8)  # (256, 3)

cmap_angle   = matplotlib.colormaps['twilight_shifted'].resampled(256)
lut_angle    = (cmap_angle(np.linspace(0, 1, 256))[:, :3] * 255).astype(np.uint8)

def render_rgb(show_angle=False, smooth=False):
    mask, smooth_mask, angle_grid = mandelbrot_kernel(
        win_w, win_h, maxit,
        view['cx'], view['cy'], view['zoom']
    )

    if show_angle:
        a = angle_grid.reshape(win_h, win_w)
        return lut_angle[a]  # angle [-pi, pi] --> 0-255

    else:
        if smooth: m = smooth_mask.reshape(win_h, win_w)
        else:      m = mask.reshape(win_h, win_w)

        m = np.log1p(m)
        m = (m / m.max() * 255).astype(np.uint8)
        return lut[m]

# pygame setup
pygame.init()
screen = pygame.display.set_mode((win_w, win_h), pygame.RESIZABLE)
pygame.display.set_caption("Mandelbrot")
font = pygame.font.SysFont('monospace', 14)
clock = pygame.time.Clock()

def blit_frame(rgb):
    # pygame expects (width, height, 3) with axes transposed
    surf = pygame.surfarray.make_surface(rgb.transpose(1, 0, 2))
    screen.blit(pygame.transform.scale(surf, screen.get_size()), (0, 0))
    txt = font.render(
        f"cx={view['cx']:.6f}  cy={view['cy']:.6f}  zoom={view['zoom']:.4e}  maxit={maxit}  {win_w}x{win_h}",
        True, (255, 255, 255)
    )
    screen.blit(txt, (8, 8))
    pygame.display.flip()

# loading numba beforehand
mandelbrot_kernel(64, 64, 10, -0.5, 0.0, 1.0)

# render
running = True
show_angle = False
smooth = False
blit_frame(render_rgb(show_angle, smooth))

while running:
    clock.tick(165)  # cap fps

    needs_render = False

    # get mouse & key inputs
    for event in pygame.event.get():
        if event.type == pygame.QUIT: running = False

        elif event.type == pygame.WINDOWRESIZED:
            win_w, win_h = event.x, event.y
            needs_render = True

        elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            drag['active'] = True
            drag['x0']  = event.pos[0]
            drag['y0']  = event.pos[1]
            drag['cx0'] = view['cx']
            drag['cy0'] = view['cy']

        elif event.type == pygame.MOUSEBUTTONUP and event.button == 1:
            drag['active'] = False
            needs_render = True

        elif event.type == pygame.MOUSEMOTION and drag['active']:
            s = min(win_w, win_h)
            dx = (event.pos[0] - drag['x0']) * 4.0 / (s * view['zoom'])
            dy = (event.pos[1] - drag['y0']) * 4.0 / (s * view['zoom'])
            view['cx'] = drag['cx0'] - dx
            view['cy'] = drag['cy0'] - dy
            needs_render = True

        elif event.type == pygame.MOUSEWHEEL:
            mx, my = pygame.mouse.get_pos()
            s = min(win_w, win_h)
            factor = 2.0 if event.y > 0 else 0.5
            view['cx'] += (mx - win_w/2) * 4.0 / (s * view['zoom']) * (1 - 1/factor)
            view['cy'] += (my - win_h/2) * 4.0 / (s * view['zoom']) * (1 - 1/factor)
            view['zoom'] *= factor
            needs_render = True

        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_r:
                view.update({'cx': -0.5, 'cy': 0.0, 'zoom': 1.0})
                maxit = 500
                smooth, show_angle = False, False
            elif event.key == pygame.K_EQUALS: maxit = min(int(maxit * 1.5), 65535)
            elif event.key == pygame.K_MINUS:  maxit = max(int(maxit / 1.5), 1)
            elif event.key == pygame.K_a:      show_angle = not show_angle
            elif event.key == pygame.K_s:      smooth     = not smooth
            needs_render = True

    if needs_render: blit_frame(render_rgb(show_angle, smooth))

pygame.quit()
