import cupy as cp
import numpy as np
import pygame
import matplotlib.cm as cm

# parameters
win_w, win_h = 1000, 1000
maxit = 500
view  = {'cx': -0.5, 'cy': 0.0, 'zoom': 1.0}
drag  = {'active': False, 'x0': 0, 'y0': 0, 'cx0': 0.0, 'cy0': 0.0}

mandelbrot_kernel = cp.ElementwiseKernel(
    'int32 w, int32 h, int32 maxit, float64 cx, float64 cy, float64 zoom',  # input: image size, max iterations, central (x,y), zoom
    'uint16 mask, float32 angle',                                            # output: array containing iteration count
    '''
    // i is the pixel index, provided by CuPy
    // conversion from pixel index to space coordinate
    int ix = i % w;
    int iy = i / w;
    int s = min(w, h);

    // main bulb and interior region skips; points here won't ever escape
    double cr = cx + (4.0 * (ix - w * 0.5) / s) / zoom;
    double ci = cy + (4.0 * (iy - h * 0.5) / s) / zoom;
    double a  = cr - 0.25;
    double r2 = a*a + ci*ci;
    bool skip = (
        ((cr + 1.0)*(cr + 1.0) + ci*ci) < 0.0625
        || (r2*r2 + a*r2 - 0.0625*ci*ci) < 0
        || ((cr + 1.308)*(cr + 1.308)    + ci*ci) < 0.003
        || ((cr + 0.125)*(cr + 0.125)    + (ci + 0.745)*(ci + 0.745)) < 0.008
        || ((cr + 0.125)*(cr + 0.125)    + (ci - 0.745)*(ci - 0.745)) < 0.008
    );
    if (skip) {
        mask = maxit;
        angle = 0.0f;
    } else {
        // MAIN LOOP
        double zr = 0, zi = 0, tmp;      // real, imag, tmp
        double zr2, zi2;                 // real^2, imag^2
        double prev_zr = 0, prev_zi = 0; // z before the escape step
        double zr_old = 0, zi_old = 0;   // old_real, old_imag for periodicity checks
        int it = 0;                      // current iteration
        int period = 1;                  // current cycle length being tested
        int countdown = 1;               // iterations until next reference update
        
        while (it < maxit) {
            it++;

            // snapshot z before update
            prev_zr = zr; 
            prev_zi = zi;

            // compute z --> z^2 + c            
            zr2 = zr*zr; zi2 = zi*zi;
            tmp = zr2 - zi2 + cr;
            zi  = fma(2.0*zr, zi, ci);
            zr  = tmp;
  
            // if out of bounds, break
            if (zr2 + zi2 > 4.0) {
                // angle of the step from prev_z to new z
                double dz_r = zr - prev_zr;
                double dz_i = zi - prev_zi;
                angle = (float) atan2(dz_i, dz_r);  // range: [-pi, pi]
                mask = it; 
                break; 
            }

            // if periodic, break
            if (zr == zr_old && zi == zi_old) { mask = maxit; angle = 0.0f; break; }

            // Brent's Cycle detection algorithm
            countdown--;
            if (countdown == 0) {
                zr_old    = zr;
                zi_old    = zi;
                period    *= 2;      // double the window each time
                countdown = period;  // reset countdown to new period
            }
        }
        if (mask == 0) { mask = maxit; angle = 0.0f; }
    }
    ''',
    'mandelbrot'
)

# set colormap lut
cmap   = cm.get_cmap('inferno', 256)
lut    = (cmap(np.linspace(0, 1, 256))[:, :3] * 255).astype(np.uint8)  # (256, 3)
lut_cp = cp.asarray(lut) # on gpu

cmap_angle = cm.get_cmap('hsv', 256)
lut_angle  = (cmap_angle(np.linspace(0, 1, 256))[:, :3] * 255).astype(np.uint8)
lut_angle_cp = cp.asarray(lut_angle)

def render_rgb():
    mask = cp.zeros(win_w * win_h, dtype=cp.uint16)
    angle_grid = cp.zeros(win_w * win_h, dtype=cp.float32)
    
    mandelbrot_kernel(
        cp.int32(win_w), cp.int32(win_h), cp.int32(maxit),
        cp.float64(view['cx']), cp.float64(view['cy']), cp.float64(view['zoom']),
        mask, angle_grid
    )
    cp.cuda.Stream.null.synchronize()

    # logscale array
    m = mask.reshape(win_h, win_w).astype(cp.float32)
    m = cp.log1p(m)
    m = (m / m.max() * 255).astype(cp.uint8)
    
    # angle [-pi, pi] → 0-255 index into cyclic HSV colormap
    a = angle_grid.reshape(win_h, win_w)
    a = ((a + cp.float32(np.pi)) / cp.float32(2 * np.pi) * 255).astype(cp.uint8)

    # combine: use iteration count as brightness, angle as hue
    rgb_mask  = lut_cp[m].astype(cp.float32)        # inferno colour from iterations
    rgb_angle = lut_angle_cp[a].astype(cp.float32)  # hsv colour from angle

    # interior points (mask==maxit) keep iteration colour, escaped points blend both
    escaped = (mask.reshape(win_h, win_w) < maxit)[:, :, None]
    rgb = cp.where(escaped, (rgb_mask * 0.5 + rgb_angle * 0.5), rgb_mask)
    rgb = rgb.astype(cp.uint8)

    return cp.asnumpy(rgb)
    """
    rgb = lut_cp[m]
    return cp.asnumpy(rgb)
    """

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

# render
blit_frame(render_rgb())

running = True
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
            if event.key == pygame.K_r: view.update({'cx': -0.5, 'cy': 0.0, 'zoom': 1.0}); maxit = 500
            elif event.key == pygame.K_EQUALS: maxit = min(int(maxit * 1.5), 65535)
            elif event.key == pygame.K_MINUS: maxit = max(int(maxit / 1.5), 1)
            needs_render = True

    if needs_render: blit_frame(render_rgb())

pygame.quit()
