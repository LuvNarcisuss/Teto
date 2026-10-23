# Runtime media compression — 2026-10-23

Only images and videos under `Teto/Resources` were optimized. All Design source media and original brand artwork remain unchanged. Resource names, catalog IDs, dimensions, video frame counts, playback timestamps and practice cues are preserved.

| Runtime media | Files | Before | After | Reduction |
| --- | ---: | ---: | ---: | ---: |
| Videos | 46 | 332.1 MB | 167.8 MB | 49.5% |
| Images | 340 | 42.5 MB | 24.2 MB | 43.2% |
| Total | 386 | 374.6 MB | 192.0 MB | 48.7% |

Sizes use decimal MB and describe source resources, not a measured IPA or installed app. All 46 videos and 302 images became smaller; 38 images retained their existing bytes because optimization did not reduce size. Git history and Design originals are retained, so total repository storage does not shrink by the same amount.

Videos now use HEVC in MP4 with the `hvc1` tag, yuv420p and CRF 28. The 39 Live/Shorts clips use the x265 fast preset; seven practice films use veryfast. Audio streams were copied without re-encoding. The street practice film's original 0.033-second starting offset was restored by remuxing after encoding; all of its presentation timestamps match the original. Earlier documentation of H.264 runtime copies describes the pre-compression revision and is superseded by this record.

JPEG images use a quality ceiling of 85 and progressive optimization. Eligible PNG artwork uses pngquant quality 85–95 plus lossless optimization. AppIcon, TetoMark, TetoWordmark and all TetoIcon assets received only lossless optimization: the decoded RGBA pixels of all 177 protected assets are identical to their prior versions. Earlier descriptions of byte-identical runtime logo copies are superseded by pixel-identical lossless copies; the user's original logo file is unchanged.

Checks completed:

- Fully decoded all 46 videos with ffmpeg, and compared dimensions, sample aspect ratios, frame counts, average frame rates and every video presentation timestamp. Maximum timestamp difference is zero.
- Compared compressed audio payload hashes and audio packet timestamps/durations; they are unchanged.
- Decoded all 340 images and checked dimensions and transparency. Checked exact RGBA equality for the protected artwork.
- Visually compared every video at 10%, 50% and 90%, plus five representative images. This is representative visual inspection, not an every-frame review.
- Updated runtime hashes and processing records while preserving source licenses, source hashes and practice action cues.

Per-file sizes, hashes, methods and media checks are recorded in `Design/MediaOptimization/2026-10-23/manifest.json`; comparison sheets are in the same directory. No compilation, app execution, simulator or app tests were performed. Device playback and final IPA size remain unverified.
