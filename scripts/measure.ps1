# Motion measurement toolkit for reference videos (PowerShell 5.1 + inline C#; no Python needed).
# Dot-source it:  . "$env:USERPROFILE\.claude\skills\ae-motion-design\scripts\measure.ps1"
#
# Frames are PNGs named <prefix><frame>.png in one folder (export them with Export-Frames, below, or any tool).
#   [Motion]::DiffSeries(dir, prefix, f0, f1)        per-frame motion energy (largest 16x16 block mean |diff|)
#   [Motion]::Segments(series, f0, thr, minLen)      runs of motion / hold, rows [start, end, isMotion]
#   [Motion]::BgFit(png, cx, cy, R)                  radial background: grey g0 at (cx,cy) -> g1 at radius R; [g0, g1, rms]
#   [Motion]::ColorTrack(png, r, g, b, tol, x, y, w, h)   pixels within tol of a colour: [count, cx, cy, angleDeg, major, minor]
#   [Motion]::ArtTrack(png, g0, g1, R, tol, x, y, w, h)   pixels at least tol away from the radial background: same columns
#   [Motion]::Moves(values, minFrames, minTravel, rest)   one-way stretches that start and end near standstill: [start, end] rows
#   [Motion]::FitInfluence(values)                  AE influences for keys at rest: [out, in, rms, peakSpeedAt]
#   [Motion]::FitEase(values)                       normalise a move (first sample = 0, last = 1) and fit a CSS cubic-bezier:
#                                                   [x1, y1, x2, y2, rms, peakSpeedAt (0..1), overshoot]
#   Export-Frames -Comp -From -To -Dir              PNGs of an AE comp through claude-ae (waits for the async writes)
#   Get-Ease values label                           one-line reading: duration, influences, peak speed, overshoot
#
#   [Look]::Stats(png, cx, cy, R, tol, step)        colour / neutral shares, hue bins, art bounding box (see the C# comment)
#   [Look]::ColourSamples(...) + [Look]::KMeans(samples, k, iters, seed)   the palette of a piece: [r, g, b, count] per swatch
#   [Look]::Line(png, g0, g1, cx, cy, R, x0, y0, x1, y1, n)   art strength along a segment (stroke widths: Get-Bands)
#   [Look]::Blend(png, x0, y0, x1, y1, n, target rgb, bg rgb) blend fraction along a segment (edge ramps, motion blur: Get-Edge)
#   [Look]::Mean(png, x, y, r)                      mean RGB in a disc
#   [Look]::Blobs(png, g0, g1, cx, cy, R, tol, minArea, x, y, w, h)   connected art regions: [area, x0, y0, x1, y1] each
#   [Look]::RowCol(png, x, y, w, h, thr)            dark-pixel counts per row then per column (type: x-height, gaps)
#
#   [Audio]::ReadAiff(aif, [ref]rate)              mono samples of an AIFF (AE output template "AIFF 48kHz")
#   [Audio]::Onsets(samples, rate, fps)            [onset strength, loudness dB, low-band flux] per frame
#   [Audio]::Tempo(onsets, fps, minBpm, maxBpm)    [bestBpm, strength, then bpm/autocorrelation pairs]
#   [Audio]::Beats(onsets, fps, bpm, tightness)    beat times in seconds (dynamic-programming beat tracker)
#
# The fitted [x1,y1,x2,y2] goes straight into claude-ae's ae_set_keyframes `ease`, which converts it exactly into AE
# keyframe speed/influence. See references\measuring.md for the workflow and its traps.
if (-not ('Motion' -as [type])) {
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class Motion {
  static byte[] Bytes(string path, out int stride, out int w, out int h) {
    using (var bmp = new Bitmap(path)) {
      w = bmp.Width; h = bmp.Height;
      var d = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
      var buf = new byte[d.Stride * h]; Marshal.Copy(d.Scan0, buf, 0, buf.Length); stride = d.Stride; bmp.UnlockBits(d);
      return buf;
    }
  }

  static double BlockDiff(byte[] a, byte[] b, int stride, int w, int h) {
    double worst = 0;
    for (int by = 0; by + 16 <= h; by += 16) for (int bx = 0; bx + 16 <= w; bx += 16) {
      double s = 0;
      for (int y = by; y < by + 16; y++) { int o = y * stride + bx * 4; for (int x = 0; x < 16; x++, o += 4) s += Math.Abs(a[o] - b[o]) + Math.Abs(a[o + 1] - b[o + 1]) + Math.Abs(a[o + 2] - b[o + 2]); }
      s /= 16 * 16 * 3; if (s > worst) worst = s;
    }
    return worst;
  }

  // Motion energy of frames f0+1..f1: each frame against the one before it. Compression noise stays under ~3.
  public static double[] DiffSeries(string dir, string prefix, int f0, int f1) {
    var res = new List<double>(); int stride, w, h;
    var prev = Bytes(System.IO.Path.Combine(dir, prefix + f0 + ".png"), out stride, out w, out h);
    for (int f = f0 + 1; f <= f1; f++) { var cur = Bytes(System.IO.Path.Combine(dir, prefix + f + ".png"), out stride, out w, out h); res.Add(BlockDiff(cur, prev, stride, w, h)); prev = cur; }
    return res.ToArray();
  }

  // Runs of motion (energy >= thr) and holds; runs shorter than minLen join their neighbour. series[i] belongs to frame f0+1+i.
  public static int[][] Segments(double[] series, int f0, double thr, int minLen) {
    var runs = new List<int[]>();
    for (int i = 0; i < series.Length; i++) {
      int m = series[i] >= thr ? 1 : 0, f = f0 + 1 + i;
      if (runs.Count > 0 && runs[runs.Count - 1][2] == m) runs[runs.Count - 1][1] = f; else runs.Add(new[] { f, f, m });
    }
    bool changed = true;
    while (changed && runs.Count > 1) {
      changed = false;
      for (int i = 0; i < runs.Count; i++) {
        if (runs[i][1] - runs[i][0] + 1 >= minLen) continue;
        int j = i > 0 ? i - 1 : i + 1;
        runs[j][0] = Math.Min(runs[j][0], runs[i][0]); runs[j][1] = Math.Max(runs[j][1], runs[i][1]);
        runs.RemoveAt(i); changed = true; break;
      }
      for (int i = 1; i < runs.Count; i++) if (runs[i][2] == runs[i - 1][2]) { runs[i - 1][1] = runs[i][1]; runs.RemoveAt(i); changed = true; break; }
    }
    return runs.ToArray();
  }

  // Radial background fit (artwork rejected by iterative refitting). Returns [g0, g1, rms].
  public static double[] BgFit(string path, double cx, double cy, double R) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h);
    var ts = new List<double>(); var vs = new List<double>();
    for (int y = 4; y < h; y += 8) for (int x = 4; x < w; x += 8) {
      int o = y * stride + x * 4; double B = b[o], G = b[o + 1], Rr = b[o + 2];
      if (Math.Max(Rr, Math.Max(G, B)) - Math.Min(Rr, Math.Min(G, B)) > 6) continue;
      ts.Add(Math.Min(1, Math.Sqrt((x + 0.5 - cx) * (x + 0.5 - cx) + (y + 0.5 - cy) * (y + 0.5 - cy)) / R)); vs.Add((Rr + G + B) / 3);
    }
    var sorted = vs.ToArray(); Array.Sort(sorted);
    double g0 = sorted[sorted.Length / 2], g1 = g0, tol = 40, rms = 0;
    for (int it = 0; it < 6; it++) {
      double sx = 0, sy = 0, sxx = 0, sxy = 0; int n = 0;
      for (int i = 0; i < ts.Count; i++) { if (Math.Abs(vs[i] - (g0 + (g1 - g0) * ts[i])) > tol) continue; sx += ts[i]; sy += vs[i]; sxx += ts[i] * ts[i]; sxy += ts[i] * vs[i]; n++; }
      if (n < 50) break;
      double den = n * sxx - sx * sx;
      if (Math.Abs(den) < 1e-6) { g0 = g1 = sy / n; } else { double sl = (n * sxy - sx * sy) / den, ic = (sy - sl * sx) / n; g0 = ic; g1 = ic + sl; }
      double ss = 0; int m = 0;
      for (int i = 0; i < ts.Count; i++) { double d = vs[i] - (g0 + (g1 - g0) * ts[i]); if (Math.Abs(d) <= tol) { ss += d * d; m++; } }
      rms = Math.Sqrt(ss / Math.Max(1, m)); tol = Math.Max(4, 3 * rms);
    }
    return new[] { g0, g1, rms };
  }

  static double[] Moments(List<double> xs, List<double> ys) {
    int n = xs.Count; if (n == 0) return new double[] { 0, double.NaN, double.NaN, double.NaN, 0, 0 };
    double mx = 0, my = 0; for (int i = 0; i < n; i++) { mx += xs[i]; my += ys[i]; } mx /= n; my /= n;
    double sxx = 0, syy = 0, sxy = 0; for (int i = 0; i < n; i++) { double dx = xs[i] - mx, dy = ys[i] - my; sxx += dx * dx; syy += dy * dy; sxy += dx * dy; }
    sxx /= n; syy /= n; sxy /= n;
    double ang = 0.5 * Math.Atan2(2 * sxy, sxx - syy), tr = sxx + syy, det = sxx * syy - sxy * sxy, disc = Math.Sqrt(Math.Max(0, tr * tr / 4 - det));
    // major/minor: full extents of an equivalent uniform rectangle (sqrt(12 * variance))
    return new[] { n, mx, my, ang * 180 / Math.PI, Math.Sqrt(12 * (tr / 2 + disc)), Math.Sqrt(12 * Math.Max(0, tr / 2 - disc)) };
  }

  // Pixels within tol (RGB distance) of a colour inside [x, y, w, h]: [count, cx, cy, angleDeg, major, minor].
  public static double[] ColorTrack(string path, double r, double g, double bl, double tol, int x0, int y0, int w0, int h0) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h);
    var xs = new List<double>(); var ys = new List<double>();
    for (int y = Math.Max(0, y0); y < Math.Min(h, y0 + h0); y++) for (int x = Math.Max(0, x0); x < Math.Min(w, x0 + w0); x++) {
      int o = y * stride + x * 4; double d = Math.Sqrt((b[o + 2] - r) * (b[o + 2] - r) + (b[o + 1] - g) * (b[o + 1] - g) + (b[o] - bl) * (b[o] - bl));
      if (d <= tol) { xs.Add(x + 0.5); ys.Add(y + 0.5); }
    }
    return Moments(xs, ys);
  }

  // Pixels at least tol away from the radial background (centre of frame, g0 -> g1 at radius R): same columns.
  public static double[] ArtTrack(string path, double g0, double g1, double R, double tol, int x0, int y0, int w0, int h0) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h);
    var xs = new List<double>(); var ys = new List<double>(); double cx = w / 2.0, cy = h / 2.0;
    for (int y = Math.Max(0, y0); y < Math.Min(h, y0 + h0); y++) for (int x = Math.Max(0, x0); x < Math.Min(w, x0 + w0); x++) {
      double bg = g0 + (g1 - g0) * Math.Min(1, Math.Sqrt((x + 0.5 - cx) * (x + 0.5 - cx) + (y + 0.5 - cy) * (y + 0.5 - cy)) / R);
      int o = y * stride + x * 4; double d = Math.Sqrt((b[o + 2] - bg) * (b[o + 2] - bg) + (b[o + 1] - bg) * (b[o + 1] - bg) + (b[o] - bg) * (b[o] - bg));
      if (d >= tol) { xs.Add(x + 0.5); ys.Add(y + 0.5); }
    }
    return Moments(xs, ys);
  }

  // Complete moves in a per-frame series: stretches where the value travels one way, starting and ending at a near-
  // standstill (speed under `rest` x the move's peak speed), at least minFrames long and minTravel in size.
  // Returns [startIndex, endIndex] rows (both ends at rest), ready for FitEase on values[start..end].
  public static int[][] Moves(double[] v, int minFrames, double minTravel, double rest) {
    int n = v.Length; var res = new List<int[]>(); if (n < 3) return res.ToArray();
    var sp = new double[n]; for (int i = 1; i < n - 1; i++) sp[i] = (v[i + 1] - v[i - 1]) / 2; sp[0] = v[1] - v[0]; sp[n - 1] = v[n - 1] - v[n - 2];
    int k = 0;
    while (k < n - 1) {
      // next frame that is clearly moving
      int a = k; while (a < n - 1 && Math.Abs(sp[a]) < 1e-9) a++;
      if (a >= n - 1) break;
      int dir = Math.Sign(sp[a]);
      int b = a; double peak = 0;
      while (b < n - 1 && Math.Sign(sp[b + 1]) == dir) { b++; peak = Math.Max(peak, Math.Abs(sp[b])); }
      peak = Math.Max(peak, Math.Abs(sp[a]));
      // trim to where the speed is under rest * peak at both ends
      int s = a; while (s > 0 && Math.Abs(sp[s]) > rest * peak && Math.Sign(sp[s - 1]) == dir) s--;
      while (s < b && Math.Abs(sp[s + 1]) < rest * peak) s++;
      int e = b; while (e > s && Math.Abs(sp[e - 1]) < rest * peak) e--;
      while (e < n - 1 && Math.Abs(sp[e]) > rest * peak) e++;
      if (e - s + 1 >= minFrames && Math.Abs(v[e] - v[s]) >= minTravel) res.Add(new[] { s, e });
      k = b + 1;
    }
    return res.ToArray();
  }

  // CSS cubic-bezier timing: progress at time t for control points (x1,y1),(x2,y2).
  public static double Bezier(double x1, double y1, double x2, double y2, double t) {
    double s = t;
    for (int i = 0; i < 12; i++) {
      double x = 3 * (1 - s) * (1 - s) * s * x1 + 3 * (1 - s) * s * s * x2 + s * s * s - t;
      double dx = 3 * (1 - s) * (1 - s) * x1 + 6 * (1 - s) * s * (x2 - x1) + 3 * s * s * (1 - x2);
      if (Math.Abs(dx) < 1e-6) break; s -= x / dx; if (s < 0) s = 0; if (s > 1) s = 1;
    }
    double lo = 0, hi = 1;
    for (int i = 0; i < 30; i++) { double x = 3 * (1 - s) * (1 - s) * s * x1 + 3 * (1 - s) * s * s * x2 + s * s * s; if (Math.Abs(x - t) < 1e-7) break; if (x < t) lo = s; else hi = s; s = (lo + hi) / 2; }
    return 3 * (1 - s) * (1 - s) * s * y1 + 3 * (1 - s) * s * s * y2 + s * s * s;
  }

  // Fit a move as an After Effects ease between two keys at rest (speed 0 at both): the outgoing influence of the
  // first key and the incoming influence of the second (0..1), i.e. cubic-bezier(out, 0, 1 - in, 1).
  // Returns [outInfluence, inInfluence, rms, peakSpeedAt]. Overshooting moves need FitEase instead.
  public static double[] FitInfluence(double[] values) {
    int n = values.Length; if (n < 4) return new double[] { double.NaN, 0, 0, 0 };
    double v0 = values[0], span = values[n - 1] - v0;
    var t = new double[n]; var p = new double[n];
    for (int i = 0; i < n; i++) { t[i] = (double)i / (n - 1); p[i] = Math.Abs(span) < 1e-9 ? 0 : (values[i] - v0) / span; }
    double ba = 0.33, bb = 0.33, bc = double.MaxValue;
    for (double a = 0.01; a <= 1.0001; a += 0.01) for (double b = 0.01; b <= 1.0001; b += 0.01) {
      double s = 0; for (int i = 0; i < n; i++) { double d = Bezier(a, 0, 1 - b, 1, t[i]) - p[i]; s += d * d; }
      if (s < bc) { bc = s; ba = a; bb = b; }
    }
    double peakT = 0, peakV = -1;
    for (int i = 0; i <= 200; i++) { double tt = i / 200.0, v = Bezier(ba, 0, 1 - bb, 1, Math.Min(1, tt + 0.0025)) - Bezier(ba, 0, 1 - bb, 1, Math.Max(0, tt - 0.0025)); if (v > peakV) { peakV = v; peakT = tt; } }
    return new[] { ba, bb, Math.Sqrt(bc / n), peakT };
  }

  // Fit a move: values sampled once per frame from the start pose to the end pose (both included).
  // Returns [x1, y1, x2, y2, rms, peakSpeedAt, overshoot]; peakSpeedAt 0.5 = symmetric, < 0.35 = fast start (ease-out).
  public static double[] FitEase(double[] values) {
    int n = values.Length; if (n < 4) return new double[] { double.NaN, 0, 0, 0, 0, 0, 0 };
    double v0 = values[0], v1 = values[n - 1], span = v1 - v0;
    var t = new double[n]; var p = new double[n]; double over = 0;
    for (int i = 0; i < n; i++) { t[i] = (double)i / (n - 1); p[i] = Math.Abs(span) < 1e-9 ? 0 : (values[i] - v0) / span; over = Math.Max(over, p[i] - 1); }
    Func<double[], double> cost = (q) => { double s = 0; for (int i = 0; i < n; i++) { double d = Bezier(q[0], q[1], q[2], q[3], t[i]) - p[i]; s += d * d; } return s; };
    double[] best = null; double bc = double.MaxValue;
    for (double x1 = 0; x1 <= 1.0001; x1 += 0.1) for (double x2 = 0; x2 <= 1.0001; x2 += 0.1)
      for (double y1 = -0.3; y1 <= 1.3001; y1 += 0.1) for (double y2 = -0.3; y2 <= 1.3001; y2 += 0.1) {
        var q = new[] { x1, y1, x2, y2 }; double c = cost(q); if (c < bc) { bc = c; best = q; }
      }
    double step = 0.05;
    for (int round = 0; round < 40 && step > 0.001; round++) {
      bool improved = false;
      for (int k = 0; k < 4; k++) foreach (double d in new[] { step, -step }) {
        var q = (double[])best.Clone(); q[k] += d; if (k == 0 || k == 2) q[k] = Math.Min(1, Math.Max(0, q[k]));
        double c = cost(q); if (c < bc) { bc = c; best = q; improved = true; }
      }
      if (!improved) step /= 2;
    }
    double peakT = 0, peakV = -1;
    for (int i = 0; i <= 200; i++) { double tt = i / 200.0, v = (Bezier(best[0], best[1], best[2], best[3], Math.Min(1, tt + 0.0025)) - Bezier(best[0], best[1], best[2], best[3], Math.Max(0, tt - 0.0025))); if (v > peakV) { peakV = v; peakT = tt; } }
    return new[] { best[0], best[1], best[2], best[3], Math.Sqrt(bc / n), peakT, over };
  }
}

// Music: read an AIFF (AE's "AIFF 48kHz" output template), onset strength, tempo and beats.
public static class Audio {
  static int U16(byte[] b, int o) { return (b[o] << 8) | b[o + 1]; }
  static int I16(byte[] b, int o) { return (short)((b[o] << 8) | b[o + 1]); }
  static long U32(byte[] b, int o) { return ((long)b[o] << 24) | ((long)b[o + 1] << 16) | ((long)b[o + 2] << 8) | b[o + 3]; }

  // Mono samples (-1..1) of a 16- or 24-bit PCM AIFF; sampleRate is returned through `rate`.
  public static float[] ReadAiff(string path, out double rate) {
    var b = System.IO.File.ReadAllBytes(path); int ch = 2, bits = 16; long frames = 0; rate = 48000; int data = -1;
    int p = 12;
    while (p + 8 <= b.Length) {
      string id = System.Text.Encoding.ASCII.GetString(b, p, 4); int size = (int)U32(b, p + 4);
      if (id == "COMM") {
        ch = U16(b, p + 8); frames = U32(b, p + 10); bits = U16(b, p + 14);
        int e = ((b[p + 16] & 0x7F) << 8) | b[p + 17]; ulong m = 0; for (int i = 0; i < 8; i++) m = (m << 8) | b[p + 18 + i];
        rate = m * Math.Pow(2, e - 16383 - 63);
      } else if (id == "SSND") { data = p + 16 + (int)U32(b, p + 8); }
      p += 8 + size + (size & 1);
    }
    int bps = bits / 8; var res = new float[frames];
    for (long f = 0; f < frames; f++) {
      double s = 0;
      for (int c = 0; c < ch; c++) {
        int o = data + (int)((f * ch + c) * bps);
        s += bits == 24 ? ((b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8)) / 2147483648.0 : I16(b, o) / 32768.0;
      }
      res[f] = (float)(s / ch);
    }
    return res;
  }

  static void Fft(double[] re, double[] im) {
    int n = re.Length;
    for (int i = 1, j = 0; i < n; i++) { int bit = n >> 1; for (; (j & bit) != 0; bit >>= 1) j ^= bit; j ^= bit; if (i < j) { double t = re[i]; re[i] = re[j]; re[j] = t; t = im[i]; im[i] = im[j]; im[j] = t; } }
    for (int len = 2; len <= n; len <<= 1) {
      double ang = -2 * Math.PI / len, wr = Math.Cos(ang), wi = Math.Sin(ang);
      for (int i = 0; i < n; i += len) {
        double cr = 1, ci = 0;
        for (int k = 0; k < len / 2; k++) {
          int a = i + k, bb = i + k + len / 2; double xr = re[bb] * cr - im[bb] * ci, xi = re[bb] * ci + im[bb] * cr;
          re[bb] = re[a] - xr; im[bb] = im[a] - xi; re[a] += xr; im[a] += xi;
          double nr = cr * wr - ci * wi; ci = cr * wi + ci * wr; cr = nr;
        }
      }
    }
  }

  // Onset strength at `fps` frames per second: log-magnitude spectral flux (2048-point frames), with a local mean
  // removed. Also returns per-frame loudness (dB) and low-band (< 150 Hz) flux, interleaved: [onset, loudnessDb, lowFlux] x frames.
  public static double[] Onsets(float[] x, double rate, double fps) {
    int n = 2048, frames = (int)(x.Length / rate * fps); var win = new double[n];
    for (int i = 0; i < n; i++) win[i] = 0.5 - 0.5 * Math.Cos(2 * Math.PI * i / n);
    int kMax = (int)(8000.0 * n / rate), kLow = (int)(150.0 * n / rate);
    var prev = new double[kMax + 1]; var flux = new double[frames]; var low = new double[frames]; var loud = new double[frames];
    var re = new double[n]; var im = new double[n];
    for (int f = 0; f < frames; f++) {
      long c = (long)(f / fps * rate) - n / 2; double e = 0;
      for (int i = 0; i < n; i++) { long s = c + i; double v = s >= 0 && s < x.Length ? x[s] : 0; e += v * v; re[i] = v * win[i]; im[i] = 0; }
      Fft(re, im); double fl = 0, lf = 0;
      for (int k = 1; k <= kMax; k++) {
        double m = Math.Log(1 + 100 * Math.Sqrt(re[k] * re[k] + im[k] * im[k])), d = m - prev[k];
        if (d > 0) { fl += d; if (k <= kLow) lf += d; }
        prev[k] = m;
      }
      flux[f] = fl; low[f] = lf; loud[f] = 10 * Math.Log10(e / n + 1e-12);
    }
    var res = new double[3 * frames]; int w = (int)Math.Round(fps / 2);
    for (int f = 0; f < frames; f++) {
      double mean = 0; int cnt = 0; for (int j = Math.Max(0, f - w); j <= Math.Min(frames - 1, f + w); j++) { mean += flux[j]; cnt++; }
      res[3 * f] = Math.Max(0, flux[f] - mean / cnt); res[3 * f + 1] = loud[f]; res[3 * f + 2] = low[f];
    }
    return res;
  }

  // Autocorrelation tempo of an onset envelope: [bestBpm, strength] followed by [bpm, ac] pairs for minBpm..maxBpm.
  public static double[] Tempo(double[] o, double fps, double minBpm, double maxBpm) {
    int n = o.Length; double mean = 0; foreach (var v in o) mean += v; mean /= n;
    var res = new List<double>(); double best = 0, bestBpm = 0;
    for (double bpm = minBpm; bpm <= maxBpm + 1e-9; bpm += 0.25) {
      double lag = 60 * fps / bpm, s = 0; int cnt = 0;
      for (int i = 0; i + lag + 1 < n; i++) { int j = (int)(i + lag); double fr = i + lag - j, v = o[j] * (1 - fr) + o[j + 1] * fr; s += (o[i] - mean) * (v - mean); cnt++; }
      s /= cnt; res.Add(bpm); res.Add(s); if (s > best) { best = s; bestBpm = bpm; }
    }
    res.Insert(0, best); res.Insert(0, bestBpm);
    return res.ToArray();
  }

  // Dynamic-programming beat tracker (Ellis 2007) on an onset envelope: beat times in seconds.
  public static double[] Beats(double[] o, double fps, double bpm, double tightness) {
    int n = o.Length; double period = 60 * fps / bpm; var score = new double[n]; var back = new int[n];
    double sd = 0, mean = 0; foreach (var v in o) mean += v; mean /= n; foreach (var v in o) sd += (v - mean) * (v - mean); sd = Math.Sqrt(sd / n) + 1e-9;
    for (int t = 0; t < n; t++) {
      double best = double.NegativeInfinity; int arg = -1;
      for (int p = t - (int)Math.Round(2 * period); p <= t - (int)Math.Round(period / 2); p++) {
        if (p < 0) continue; double pen = Math.Log((t - p) / period); double s = score[p] - tightness * pen * pen;
        if (s > best) { best = s; arg = p; }
      }
      score[t] = o[t] / sd + (arg >= 0 ? best : 0); back[t] = arg;
    }
    int end = n - 1; double bs = double.NegativeInfinity;
    for (int t = (int)(n - period); t < n; t++) if (t >= 0 && score[t] > bs) { bs = score[t]; end = t; }
    var beats = new List<double>(); for (int t = end; t >= 0; t = back[t]) { beats.Add(t / fps); if (back[t] < 0) break; }
    beats.Reverse(); return beats.ToArray();
  }
}

// Colour, layout, stroke and blur measurements.
public static class Look {
  static byte[] Bytes(string path, out int stride, out int w, out int h) {
    using (var bmp = new Bitmap(path)) {
      w = bmp.Width; h = bmp.Height;
      var d = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
      var buf = new byte[d.Stride * h]; Marshal.Copy(d.Scan0, buf, 0, buf.Length); stride = d.Stride; bmp.UnlockBits(d);
      return buf;
    }
  }

  static double Bg(double g0, double g1, double R, double cx, double cy, double x, double y) {
    return g0 + (g1 - g0) * Math.Min(1, Math.Sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy)) / R);
  }

  public static void Hsl(double R, double G, double B, out double hue, out double sat, out double light) {
    double r = R / 255, g = G / 255, b = B / 255, mx = Math.Max(r, Math.Max(g, b)), mn = Math.Min(r, Math.Min(g, b)), d = mx - mn;
    light = (mx + mn) / 2; sat = d < 1e-9 ? 0 : d / (1 - Math.Abs(2 * light - 1)); hue = 0;
    if (d > 1e-9) { if (mx == r) hue = 60 * (((g - b) / d) % 6); else if (mx == g) hue = 60 * ((b - r) / d + 2); else hue = 60 * ((r - g) / d + 4); }
    if (hue < 0) hue += 360;
  }

  // Per-frame look statistics. The radial grey background is fitted first (centre cx, cy; radius R); "art" is every
  // pixel more than tol (RGB distance) away from it, sampled every `step` pixels. Neutral art (chroma < 15) splits into
  // dark (< 90), grey and white (> 200); chroma 15-40 counts as a tint; chroma >= 40 as colour.
  // Returns [g0, g1, bgRms, artShare, colourShare, tintShare, darkShare, greyShare, whiteShare (shares of art),
  //          x2, y2, x98, y98 (2nd/98th percentile of art x and y), artCx, artCy,
  //          12 hue bins (share of colour pixels; bin k is centred on 30k degrees: red, orange, yellow, ...),
  //          mean saturation and lightness of colour pixels (0..1), mean level of dark and of white art (0..255)]
  public static double[] Stats(string path, double cx, double cy, double R, double tol, int step) {
    var fit = Motion.BgFit(path, cx, cy, R);
    int stride, w, h; var b = Bytes(path, out stride, out w, out h);
    double g0 = fit[0], g1 = fit[1];
    double n = 0, art = 0, col = 0, tint = 0, dark = 0, grey = 0, white = 0, sx = 0, sy = 0, sS = 0, sL = 0, dl = 0, wl = 0;
    var hx = new double[w]; var hy = new double[h]; var hue = new double[12];
    for (int y = 0; y < h; y += step) for (int x = 0; x < w; x += step) {
      n++;
      int o = y * stride + x * 4; double B = b[o], G = b[o + 1], Rr = b[o + 2], bg = Bg(g0, g1, R, cx, cy, x + 0.5, y + 0.5);
      if (Math.Sqrt((Rr - bg) * (Rr - bg) + (G - bg) * (G - bg) + (B - bg) * (B - bg)) < tol) continue;
      art++; hx[x]++; hy[y]++; sx += x; sy += y;
      double mx = Math.Max(Rr, Math.Max(G, B)), mn = Math.Min(Rr, Math.Min(G, B)), c = mx - mn;
      if (c >= 40) { col++; double hh, ss, ll; Hsl(Rr, G, B, out hh, out ss, out ll); hue[(int)(((hh + 15) % 360) / 30) % 12]++; sS += ss; sL += ll; }
      else if (c >= 15) tint++;
      else { double L = (mx + mn) / 2; if (L < 90) { dark++; dl += L; } else if (L > 200) { white++; wl += L; } else grey++; }
    }
    var res = new double[33];
    res[0] = g0; res[1] = g1; res[2] = fit[2]; res[3] = art / n;
    if (art > 0) {
      res[4] = col / art; res[5] = tint / art; res[6] = dark / art; res[7] = grey / art; res[8] = white / art;
      res[9] = Pct(hx, art, 0.02); res[10] = Pct(hy, art, 0.02); res[11] = Pct(hx, art, 0.98); res[12] = Pct(hy, art, 0.98);
      res[13] = sx / art; res[14] = sy / art;
    }
    for (int k = 0; k < 12; k++) res[15 + k] = col > 0 ? hue[k] / col : 0;
    res[27] = col > 0 ? sS / col : 0; res[28] = col > 0 ? sL / col : 0; res[29] = dark > 0 ? dl / dark : 0; res[30] = white > 0 ? wl / white : 0;
    res[31] = n; res[32] = art;
    return res;
  }

  static double Pct(double[] hist, double total, double q) {
    double acc = 0, target = q * total;
    for (int i = 0; i < hist.Length; i++) { acc += hist[i]; if (acc >= target) return i; }
    return hist.Length - 1;
  }

  // RGB of colour pixels (chroma >= minChroma, away from the fitted background), every `step` pixels: flat [r, g, b, ...].
  public static double[] ColourSamples(string path, double cx, double cy, double R, double tol, double minChroma, int step) {
    var fit = Motion.BgFit(path, cx, cy, R);
    int stride, w, h; var b = Bytes(path, out stride, out w, out h); var res = new List<double>();
    for (int y = 0; y < h; y += step) for (int x = 0; x < w; x += step) {
      int o = y * stride + x * 4; double B = b[o], G = b[o + 1], Rr = b[o + 2], bg = Bg(fit[0], fit[1], R, cx, cy, x + 0.5, y + 0.5);
      if (Math.Sqrt((Rr - bg) * (Rr - bg) + (G - bg) * (G - bg) + (B - bg) * (B - bg)) < tol) continue;
      if (Math.Max(Rr, Math.Max(G, B)) - Math.Min(Rr, Math.Min(G, B)) < minChroma) continue;
      res.Add(Rr); res.Add(G); res.Add(B);
    }
    return res.ToArray();
  }

  static double D2(double[] p, int i, double[] c, int m) {
    double a = p[3 * i] - c[3 * m], b = p[3 * i + 1] - c[3 * m + 1], d = p[3 * i + 2] - c[3 * m + 2]; return a * a + b * b + d * d;
  }

  // k-means++ on flat RGB samples: flat [r, g, b, count] per cluster.
  public static double[] KMeans(double[] p, int k, int iters, int seed) {
    int n = p.Length / 3; var rnd = new Random(seed); var c = new double[3 * k]; var dist = new double[n];
    int f0 = rnd.Next(n); c[0] = p[3 * f0]; c[1] = p[3 * f0 + 1]; c[2] = p[3 * f0 + 2];
    for (int j = 1; j < k; j++) {
      double sum = 0;
      for (int i = 0; i < n; i++) { double best = double.MaxValue; for (int m = 0; m < j; m++) best = Math.Min(best, D2(p, i, c, m)); dist[i] = best; sum += best; }
      double r = rnd.NextDouble() * sum; int pick = n - 1;
      for (int i = 0; i < n; i++) { r -= dist[i]; if (r <= 0) { pick = i; break; } }
      c[3 * j] = p[3 * pick]; c[3 * j + 1] = p[3 * pick + 1]; c[3 * j + 2] = p[3 * pick + 2];
    }
    var cnt = new double[k];
    for (int it = 0; it < iters; it++) {
      var acc = new double[3 * k]; Array.Clear(cnt, 0, k);
      for (int i = 0; i < n; i++) {
        int bm = 0; double bd = double.MaxValue;
        for (int m = 0; m < k; m++) { double d = D2(p, i, c, m); if (d < bd) { bd = d; bm = m; } }
        cnt[bm]++; acc[3 * bm] += p[3 * i]; acc[3 * bm + 1] += p[3 * i + 1]; acc[3 * bm + 2] += p[3 * i + 2];
      }
      for (int m = 0; m < k; m++) if (cnt[m] > 0) { c[3 * m] = acc[3 * m] / cnt[m]; c[3 * m + 1] = acc[3 * m + 1] / cnt[m]; c[3 * m + 2] = acc[3 * m + 2] / cnt[m]; }
    }
    var res = new double[4 * k];
    for (int m = 0; m < k; m++) { res[4 * m] = c[3 * m]; res[4 * m + 1] = c[3 * m + 1]; res[4 * m + 2] = c[3 * m + 2]; res[4 * m + 3] = cnt[m]; }
    return res;
  }

  static void Sample(byte[] b, int stride, int w, int h, double x, double y, out double R, out double G, out double B) {
    x -= 0.5; y -= 0.5; int xi = (int)Math.Floor(x), yi = (int)Math.Floor(y); double fx = x - xi, fy = y - yi; R = G = B = 0;
    for (int dy = 0; dy <= 1; dy++) for (int dx = 0; dx <= 1; dx++) {
      int xx = Math.Min(w - 1, Math.Max(0, xi + dx)), yy = Math.Min(h - 1, Math.Max(0, yi + dy));
      double wt = (dx == 1 ? fx : 1 - fx) * (dy == 1 ? fy : 1 - fy); int o = yy * stride + xx * 4;
      B += wt * b[o]; G += wt * b[o + 1]; R += wt * b[o + 2];
    }
  }

  // Art strength along a segment: RGB distance from the radial background at n + 1 evenly spaced points (bilinear).
  public static double[] Line(string path, double g0, double g1, double cx, double cy, double R, double x0, double y0, double x1, double y1, int n) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h); var res = new double[n + 1];
    for (int i = 0; i <= n; i++) {
      double x = x0 + (x1 - x0) * i / n, y = y0 + (y1 - y0) * i / n, Rr, G, B; Sample(b, stride, w, h, x, y, out Rr, out G, out B);
      double bg = Bg(g0, g1, R, cx, cy, x, y); res[i] = Math.Sqrt((Rr - bg) * (Rr - bg) + (G - bg) * (G - bg) + (B - bg) * (B - bg));
    }
    return res;
  }

  // Blend fraction along a segment between a background colour and a target colour: the projection of each sample
  // onto (target - background); 0 = background, 1 = target. Motion blur and anti-aliasing are such blends.
  public static double[] Blend(string path, double x0, double y0, double x1, double y1, int n, double tR, double tG, double tB, double bR, double bG, double bB) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h); var res = new double[n + 1];
    double dR = tR - bR, dG = tG - bG, dB = tB - bB, dd = dR * dR + dG * dG + dB * dB;
    for (int i = 0; i <= n; i++) {
      double x = x0 + (x1 - x0) * i / n, y = y0 + (y1 - y0) * i / n, Rr, G, B; Sample(b, stride, w, h, x, y, out Rr, out G, out B);
      res[i] = ((Rr - bR) * dR + (G - bG) * dG + (B - bB) * dB) / dd;
    }
    return res;
  }

  // Mean RGB inside a disc (for picking target and background colours).
  public static double[] Mean(string path, double x, double y, double r) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h); double R = 0, G = 0, B = 0, n = 0;
    for (int yy = (int)(y - r); yy <= (int)(y + r); yy++) for (int xx = (int)(x - r); xx <= (int)(x + r); xx++) {
      if (xx < 0 || yy < 0 || xx >= w || yy >= h || (xx + 0.5 - x) * (xx + 0.5 - x) + (yy + 0.5 - y) * (yy + 0.5 - y) > r * r) continue;
      int o = yy * stride + xx * 4; B += b[o]; G += b[o + 1]; R += b[o + 2]; n++;
    }
    return new[] { R / n, G / n, B / n };
  }

  // Connected regions (4-neighbour) of art pixels inside a region, largest first: flat [area, x0, y0, x1, y1] per blob.
  public static double[] Blobs(string path, double g0, double g1, double cx, double cy, double R, double tol, int minArea, int rx, int ry, int rw, int rh) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h);
    int x0 = Math.Max(0, rx), y0 = Math.Max(0, ry), x1 = Math.Min(w, rx + rw), y1 = Math.Min(h, ry + rh), W = x1 - x0, H = y1 - y0;
    var on = new bool[W * H]; var seen = new bool[W * H];
    for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
      int o = (y + y0) * stride + (x + x0) * 4; double B = b[o], G = b[o + 1], Rr = b[o + 2], bg = Bg(g0, g1, R, cx, cy, x + x0 + 0.5, y + y0 + 0.5);
      on[y * W + x] = Math.Sqrt((Rr - bg) * (Rr - bg) + (G - bg) * (G - bg) + (B - bg) * (B - bg)) >= tol;
    }
    var blobs = new List<double[]>(); var stack = new int[W * H];
    for (int s = 0; s < W * H; s++) {
      if (!on[s] || seen[s]) continue;
      int sp = 0; stack[sp++] = s; seen[s] = true; double area = 0; int bx0 = W, by0 = H, bx1 = 0, by1 = 0;
      while (sp > 0) {
        int q = stack[--sp], qx = q % W, qy = q / W; area++;
        if (qx < bx0) bx0 = qx; if (qx > bx1) bx1 = qx; if (qy < by0) by0 = qy; if (qy > by1) by1 = qy;
        if (qx > 0 && on[q - 1] && !seen[q - 1]) { seen[q - 1] = true; stack[sp++] = q - 1; }
        if (qx < W - 1 && on[q + 1] && !seen[q + 1]) { seen[q + 1] = true; stack[sp++] = q + 1; }
        if (qy > 0 && on[q - W] && !seen[q - W]) { seen[q - W] = true; stack[sp++] = q - W; }
        if (qy < H - 1 && on[q + W] && !seen[q + W]) { seen[q + W] = true; stack[sp++] = q + W; }
      }
      if (area >= minArea) blobs.Add(new double[] { area, bx0 + x0, by0 + y0, bx1 + x0, by1 + y0 });
    }
    blobs.Sort((p, q) => q[0].CompareTo(p[0]));
    var res = new List<double>(); foreach (var bl in blobs) res.AddRange(bl);
    return res.ToArray();
  }

  // Dark-pixel counts (mean of R, G, B below thr) per row, then per column, inside a region: h0 + w0 values.
  public static double[] RowCol(string path, int x0, int y0, int w0, int h0, double thr) {
    int stride, w, h; var b = Bytes(path, out stride, out w, out h); var res = new double[h0 + w0];
    for (int y = 0; y < h0; y++) for (int x = 0; x < w0; x++) {
      int xx = x0 + x, yy = y0 + y; if (xx < 0 || yy < 0 || xx >= w || yy >= h) continue;
      int o = yy * stride + xx * 4; if ((b[o] + b[o + 1] + b[o + 2]) / 3.0 < thr) { res[y]++; res[h0 + x]++; }
    }
    return res;
  }
}
'@
}

# Export frames f0..f1 of a comp to <dir>\<prefix><f>.png through claude-ae (AE must be running with the bridge).
# saveFrameToPng is asynchronous: this waits until every file exists. Keep a batch under ~800 frames per call.
function Export-Frames([string]$Comp, [int]$From, [int]$To, [string]$Dir, [string]$Prefix = 'ref_', [double]$Fps = 30,
                       [string]$Exe = 'C:\Users\user\source\claude-ae\server\dist\claude-ae.exe') {
  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  $d = $Dir.Replace('\', '/')
  $js = "var c = CB.findComp('$Comp'), n = 0; for (var f = $From; f <= $To; f++) { var file = new File('$d/$Prefix' + f + '.png'); if (file.exists && file.length > 1000) continue; c.saveFrameToPng(f / $Fps, file); n++; } return 'queued ' + n;"
  @{ script = $js } | ConvertTo-Json -Compress | & $Exe --call ae_eval
  $deadline = (Get-Date).AddSeconds(110)
  while ((Get-Date) -lt $deadline) {
    $left = @($From..$To | Where-Object { $p = Join-Path $Dir "$Prefix$_.png"; -not ((Test-Path $p) -and (Get-Item $p).Length -gt 1000) }).Count
    if ($left -eq 0) { break }; Start-Sleep -Seconds 1
  }
  "missing: $left"
}

# Fit the ease of one move from a per-frame series (e.g. a ColorTrack column), sampled from rest to rest. Prints the
# After Effects influences (keys at rest), and the free cubic-bezier when the move overshoots.
function Get-Ease([double[]]$Values, [string]$Label = 'move', [double]$Fps = 30) {
  $i = [Motion]::FitInfluence($Values); $r = [Motion]::FitEase($Values)
  $read = if ($r[6] -gt 0.02) { 'overshoots' } elseif ($i[3] -lt 0.35) { 'fast start, long settle' } elseif ($i[3] -gt 0.65) { 'slow start, hard arrival' } else { 'eases in and out' }
  $s = '{0}: {1} frames ({2:0.00} s), AE influence out {3:0}% / in {4:0}% (rms {5:0.000}), peak speed at {6:0.00} -> {7}' -f $Label, $Values.Count, (($Values.Count - 1) / $Fps), (100 * $i[0]), (100 * $i[1]), $i[2], $i[3], $read
  if ($r[6] -gt 0.02) { $s += '; overshoot {0:0}%, cubic-bezier({1:0.00}, {2:0.00}, {3:0.00}, {4:0.00})' -f (100 * $r[6]), $r[0], $r[1], $r[2], $r[3] }
  $s
}

# Bands in a profile (e.g. [Look]::Line across a stroke): runs at or above $Frac of their own peak, with sub-sample
# crossings. $Step = distance between samples (px). Returns objects {Start, End, Width, Peak} in px along the profile.
function Get-Bands([double[]]$P, [double]$Step = 1, [double]$Frac = 0.5, [double]$MinPeak = 20) {
  $max = ($P | Measure-Object -Maximum).Maximum; if ($max -lt $MinPeak) { return }
  $i = 0; $n = $P.Count
  while ($i -lt $n) {
    if ($P[$i] -lt $MinPeak) { $i++; continue }
    $j = $i; $peak = $P[$i]; while ($j + 1 -lt $n -and $P[$j + 1] -ge $MinPeak / 2) { $j++; if ($P[$j] -gt $peak) { $peak = $P[$j] } }
    $t = $Frac * $peak; $a = $i; while ($a -lt $j -and $P[$a] -lt $t) { $a++ }; $b = $j; while ($b -gt $a -and $P[$b] -lt $t) { $b-- }
    $l = $a; if ($a -gt 0 -and $P[$a] -ne $P[$a - 1]) { $l = $a - ($P[$a] - $t) / ($P[$a] - $P[$a - 1]) }
    $r = $b; if ($b -lt $n - 1 -and $P[$b] -ne $P[$b + 1]) { $r = $b + ($P[$b] - $t) / ($P[$b] - $P[$b + 1]) }
    [pscustomobject]@{ Start = $l * $Step; End = $r * $Step; Width = ($r - $l) * $Step; Peak = $peak }
    $i = $j + 1
  }
}

# An edge in a blend profile that runs from inside (about 1) to outside (about 0): where it first falls through 0.9,
# 0.5 and 0.1, in px from the start ($Step px per sample). The 10-90% ramp of a moving edge grows by 0.8 x the
# distance it travels while the shutter is open, so shutter angle ~ 360 * (ramp - rampAtRest) / 0.8 / speedPerFrame.
function Get-Edge([double[]]$P, [double]$Step = 1) {
  $cross = { param($t) for ($i = 1; $i -lt $P.Count; $i++) { if ($P[$i - 1] -ge $t -and $P[$i] -lt $t) { return ($i - 1 + ($P[$i - 1] - $t) / ($P[$i - 1] - $P[$i])) * $Step } }; return [double]::NaN }
  $r90 = & $cross 0.9; $r50 = & $cross 0.5; $r10 = & $cross 0.1
  [pscustomobject]@{ R90 = $r90; R50 = $r50; R10 = $r10; Ramp = $r10 - $r90 }
}
