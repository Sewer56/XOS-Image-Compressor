# XOS Image Compressor

An easy to use, very accessible and easy to use portable set of shell scripts that update directly from sources, compile for the target architecture of your machine and act as a wrapper for multiple external utilities performing optimisations on JPEGs and PNGs. Originally intended to compress Android application source code and other media projects as part of my work on halogenOS, named after XOS itself, the utility has been expanded to act as a user multipurpose friendly image compressor.

In short it's a PNG optimiser that makes use of other utilities, that tries to automatically keep those utilities up to date.

### Features
 * Multithreaded Parallel Image Compression (100% core usage if desired).
 * Clean & Nice presentation using user's own terminal palette, centering etc. *(Ricers are welcome, hello /r/unixporn)*.
 * Brute forcing of images using all present utilities with max compression settings, if you're really brave to wait a bit.
 * Multiple Architecture Support, given that the script is a shell script and most projects fetched are C/C++ based.
 * Multiple presets for fast, lossy and maximum (slow) compression using given tools.
 * Hands-free setup, run the updater and you're ready to go, no manual intervention required.
 * Well balanced profiles by default.

### Benchmarks (First Release Version / 0.69)

These are just a few test samples after a lot of testing it may have been worthwhile writing the results of, showing the difference between the presets of the utility, although you should really consolidate and try the individual tools and presets themselves. The real thing being evaluated here are the actual tools used really by great developers, although I do guess this can present how well multithreading works across different workloads.

I'm a realist, so these are realistic benchmarks of what you should really expect, nothing is cherrypicked here, this displays both the current successes and flaws. Many of the tools themselves don't have any benchmarks, so I guess writing this is worthwhile. More samples will probably be given in the future, this section is a bit barebones for now.

Tested with an i7 4790k CPU, overclocked to 4.5GHz (I know, pretty strong hardware at hand), those are all for lossless compression unless stated. These are Pingo-enabled benchmarks, thus in non-free mode.

Note: These benchmarks were taken while I was working more heavily in the background, the benchmark would be approximately 5~15% faster on an unoccupied CPU.

### __Benchmarks - Simple Graphics/Digital Artwork__

##### Random Data Set of Small (and few larger) Images

| Sample        | Preset       | Reduction %  | Time |
|:-------------:|:-------------:|:-----:|:-----:|
| Bluemerald-git/Bluemerald-standalone themes | --c1 (fast)     |   54.990% | 21.231s |
| Bluemerald-git/Bluemerald-standalone themes | --c2 (default)     |   55.010% | 28.001s |
| Bluemerald-git/Bluemerald-standalone themes | --c3 (maximum)    |   55.030% | 1m30.439s |
| Bluemerald-git/Bluemerald-standalone themes | --c4 (brute force) |   55.030% | 8m5.823s |

##### Large Images

I thought it would be worthwhile to add this, as with the expected behaviour of PNG compressors (unknown to some people), the time to crush images increases exponentially with both larger images and presets, it is recommended that you avoid using high profiles for very large images. The XOSTheme icon set is a set of 11 icons of 2300x2300 resolution, a deadly workload for image compressors. The original images here were saved by Photoshop, Slow PNG compression.

| Sample        | Preset       | Reduction %  | Time |
|:-------------:|:-------------:|:-----:|:-----:|
| XOSTheme Icon Set (6.5MB) | --c1 (fast) | 58.180% | 9.875s (Real) |
| XOSTheme Icon Set (6.5MB)  | --c2 (default) | 61.480% | 1m51.731s (Real) |
| XOSTheme Icon Set (6.5MB)  | --c3 (maximum) | 63.680% | 35m51.739s (Real) |
| XOSTheme Icon Set (6.5MB)  | --c4 (brute force) | 63.680% | A few hours |

Mode --c4 only exists for the brave...

##### JPEGs

JPEGs compress very quickly and very efficiently with the tools used, needless to say the settings for JPEGs are identical for every compression level. Here the images were first converted to JPEG with convert -quality 100 (part of imagemagick) and then tested against the same sample. The magic is mostly done by the fantastic utilities available at jpeg-archive (git).

| Sample        | Preset       | Reduction %  | Time |
|:-------------:|:-------------:|:-----:|:-----:|
| XOSTheme Icon Set (No Transparency) | Any | 45.980% | 6.066s (Real) |

In the end it should be notable that the actual JPEGs were larger than the PNGs made by the time-comparable --c1 preset for PNGs which also had to deal with transparency, although simple images are here at play which really is not the correct situation to test on JPEGs, for any image like a photo with a much deeper range of colours and complexity the JPEG format would win.

##### JPEG Lossy

Fancy going lossy? I can't deny, jpeg-archive and the projects that project is based on do this too well, you get your usual JPEG artifacts for a very strong reduction in size, which undercuts their lossless counterparts by a decent amount, although expected. This is still a high quality profile however despite being labelled as lossy as it targets approximately 93% quality, it should be transparent to the viewer unless the user specifically looks for JPEG artifacts which then simply become clear.

| Sample        | Preset       | Reduction %  | Time |
|:-------------:|:-------------:|:-----:|:-----:|
| XOSTheme Icon Set (No Transparency) | --jpeg-lossy | 89.450% | 4.263s (Real) |

\* XOSTheme Icon Set is a set of icons which I have self-made and redrawn for BluEmerald-Standalone, also known as XOSTheme, a fork of BluEmerald for the halogenOS Android ROM, they will be available for download in the future.

### __Benchmarks - Wallpapers/Complex Digital Artwork__

This benchmark consists of 575 1080p wallpapers found (mostly JPEG) in a [random Imgur album](http://imgur.com/a/akHsJ) weighing in at around 255MB (depending on conversions), the benchmarks are for pure PNG/JPEG here, so images not in format are converted losslessly to target test format with imagemagick.
No extra details will be given in this section apart from the necessary, I'll just let the benchmarks roll and give you results.

##### JPEGs - Lossless
Original Sample of JPEGs with the few PNG>JPEG conversions is 249512 Bytes.

| Sample        | Preset       | Reduction %  | Space Saved |  Time |
|:-------------:|:-------------:|:-----:|:-----:|:-----:|
| Random Sample of 575 Wallpapers | Any | 12.310% | ~29.93MiB | 5m0.309s (Real) |

##### JPEGs - Lossy
Original Sample of JPEGs with the few PNG>JPEG conversions here is also 249512 Bytes.
Target Quality = 93% (default JPEG lossy preset).

| Sample        | Preset       | Reduction %  | Space Saved | Time |
|:-------------:|:-------------:|:-----:|:-----:|:-----:|
| Random Sample of 575 Wallpapers | --jpeg-lossy | 21.680% | ~52.72MiB | 2m25.978s (Real) |

##### Wallpapers - PNG Lossless
Convertes Same Sample of PNGs with a lot of JPEG>PNG conversions. Size: 1380222 (~1.31GiB)
Few accidental duplicates making this a total of 581 images instead.

| Sample        | Preset       | Reduction %  | Space Saved | Time |
|:-------------:|:-------------:|:-----:|:-----:|:-----:|
| Random Sample of 575 Wallpapers | --c2 (Standard) | 10.550% | ~142.25MiB | 46m35s (Real) |

##### Wallpapers - PNG 'Lossy Transparent' (Not to be confused with Lossy Loose)

| Sample        | Preset       | Reduction %  | Space Saved | Time |
|:-------------:|:-------------:|:-----:|:-----:|:-----:|
| Random Sample of 575 Wallpapers | --c2 (Standard) --lossy-trans | 21.470% | ~289.35MiB | 35m48.321s (Real) |


### __XOS Image Compressor Screenshots__
Imgur Album: http://imgur.com/a/AUwth

### To Do
* Automatic benchmarking mode for different profiles and utilities.
* Potentially identification of complex images, optimising them as lossless JPEGs rather than PNGs, unless transparency is present to further reduce space.
* Automatic Optimisation of Android apps, how about decompiling, compressing and recompiling, sounds good to me.
* Auto mode to use low presets for large images.
* The future will tell me.

### Software Utilized/Which the script interacts with.
__Standard Modes__
* [Efficient-Compression-Tool](https://github.com/fhanau/Efficient-Compression-Tool) - [Contributors](https://github.com/fhanau/Efficient-Compression-Tool/graphs/contributors)
* [jpeg-recompress](https://github.com/danielgtaylor/jpeg-archive) - [Contributors](https://github.com/danielgtaylor/jpeg-archive/graphs/contributors)
* [PNGQuant](https://github.com/pornel/pngquant) - [Contributors](https://github.com/pornel/pngquant/graphs/contributors)

\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-
* [Pingo (In Early Development)]() - Cédric Louvrier, [Fork of Efficient-Compression-Tool](https://github.com/fhanau/Efficient-Compression-Tool) __[OPTIONAL]__ __[RECOMMENDED]__ __[CURRENTLY NON-FREE (To be changed in the future)]__


__Brute Force Modes__
* [ZopfliPNG](https://github.com/google/zopfli) - [Contributors](https://github.com/google/zopfli/blob/master/CONTRIBUTORS)
* [AdvanceMame](https://github.com/amadvance/advancemame) - [Contributors](https://github.com/amadvance/advancemame/graphs/contributors) & Others
* [PNGCrush](http://pmt.sourceforge.net/pngcrush/) - Glenn Randers-Pehrson
* [JPEGOptim](https://github.com/tjko/jpegoptim) - [Contributors](https://github.com/tjko/jpegoptim/graphs/contributors)
* [OptiPNG](http://optipng.sourceforge.net/) - [Contributors](http://optipng.sourceforge.net/authors.txt)

\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-
* [TruePNG](http://x128.ho.ua/pngutils.html) - x128  __[OPTIONAL]__ __[NON-FREE]__
* [PNGOUT](http://www.jonof.id.au/kenutils)  - Ken Silverman, Jonathon Fowler (Linux/OSX port) - __[OPTIONAL]__ __[NON-FREE]__ __[NON-REDISTRIBUTABLE*]__

\* You are bound to use, if installed or fetched by the script to follow the license as given by the utility (although not given with a copy of the utility, it is stated in the creator's website). As such please do not redistribute copies of XOS Image Compressor with the utility present in the /bin folder, thank you. Same idea follows with the other pieces of software downloaded by the script, please familliarise yourself with their licenses if you would wish to redistribute their binaries or sources along with the script.

__Unused Utilities/Modes (Disabled in Script)__
(You can enable those by manually editing the script to remove a few commented lines)
* [JPEGTran](http://www.infai.org/jpeg/) - Independent JPEG Group & Others

XOS Image Compressor does not redistribute any of these pieces of software, it automatically downloads them and interacts with them on user behalf, they do all the magic, the user is bound by their individual licenses.

### This set of scripts is free software, is licensed with GPL V3
*Additionally, for those who are pure advocates of free software, the script will by default avoid the downloading and usage
of any non-free (as in Stallman) software, while for best results it is advised to use the default Pingo (currently non free\*) and ECT (free) combination the user has no obligation to do so. In fact, there is very little benefit of the use of nonfree software optionally available as part of the script, the only actual benefit is Pingo, doing quick initial optimisations I would say there is in fact no benefit at all.*

![GPL v3](http://i.imgur.com/umYupOe.png)

*\*Free as in Stallman of course, but will have to become free due to original licesing given that the software is a fork of ECT, the author of the utility has previously stated that the software will become free once he is satisfied with it*

__Contributions to this script are kindly appreciated__
