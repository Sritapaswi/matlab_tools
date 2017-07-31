function [csq, pixelsize] = ReadPixirad(pfname, varargin)
% ReadPixirad - read Pixirad hexagonal grid file.
%
%   INPUT:
%
%   pfname
%       name of the Pixirad image file.
%
%   version
%       pixirad version. 'pixi1' is for 1 panel pixirad from the APS
%       detector pool. 'pixi2' is for 2 panel pixirad at APS 1-ID beamline.
%       In the case of 'pixi1', it is assumed that the images are saved with
%       correction already applied. In the case of 'pixi2', it is assumed
%       that the images are saved without the correction and the correction
%       is applied in this code. Only the 1 color mode correction is
%       implemented.
%
%   nc (optional - pixi1)
%       number of horizontal nodes (default = 476).
%
%   nr (optional - pixi1)
%       number of vertical nodes (default = 512).
%
%   nxsq (optional - pixi1)
%       number of pixels along x in the output square grid data. number of
%       pixels along y is computed based on this number to make the pixel
%       square.
%
%   display (optional - pixi1)
%       displays the sqaure grid image for confirmation (default = off).
%
%   pfname_ct (optional - pixi2)
%       full path and file name of the correction table. If not provided,
%       correction table located in
%       /home/beams/S1IDUSER/mnt/s1b/__eval/matlab_tools/image-processing is
%       loaded.
%
%   apply_ct (optional - pixi2)
%       applies correction table if 1.
%
%   pfname_bpt (optional - pixi2)
%       full path and file name of the bad pixel table. If not provided,
%       correction table located in
%       /home/beams/S1IDUSER/mnt/s1b/__eval/matlab_tools/image-processing is
%       loaded.
%
%   apply_bpt (optional - pixi2)
%       applies bad pixel table if 1.
%
%   OUTPUT:
%
%   csq
%       Pixirad image file information mapped to an image with square
%       pixels
%
%   pixelsize
%       Pixel size of the square pixels in mm. When nxsq is 476, resulting
%       pixel size of the square pixel is approximately 0.052 mm.
%       Ultimately, this needs to be found from optimization.

% default options
optcell = {...
    'version', 'pixi1', ...
    'nc', 476, ...
    'nr', 512, ...
    'nxsq', 476, ...
    'display', 'off', ...
    'pfname_ct', '/home/beams/S1IDUSER/mnt/s1b/__eval/matlab_tools/image-processing/correction_map.mat', ...
    'apply_ct', 0, ...
    'pfname_bpt', '/home/beams/S1IDUSER/mnt/s1b/__eval/matlab_tools/image-processing/badpixel_map.tif', ...
    'apply_bpt', 0, ...
    };

% update option
opts    = OptArgs(optcell, varargin);

if strcmpi(opts.version, 'pixi1')
    % read in image
    imdata      = double(imread(pfname));
    [nr, nc]    = size(imdata);
    
    if nc ~= opts.nc
        disp(sprintf('user input or default : %d', opts.nc))
        disp(sprintf('image size in x       : %d', nc))
        error('number of columns does not match')
    elseif nr ~= opts.nr
        disp(sprintf('user input or default : %d', opts.nr))
        disp(sprintf('image size in y       : %d', nr))
        error('number of rows does not match')
    else
        disp(sprintf('%d x %d image', nc, nr))
    end
    
    % WHEN nxsq == 476; pixelsize is 0.052 mm per pixel
    pixelsize   = opts.nxsq/476*0.052;
    
    pfname_xymap    = ['pixirad.map.nc.', num2str(nc), '.nr.', num2str(nr), '.mat'];
    if exist(pfname_xymap, 'file')
        load(pfname_xymap)
    else
        disp(sprintf('pixirad map %s does not exist!', pfname_xymap))
        disp(sprintf('creating %s.', pfname_xymap))
        x1  = 1:1:nc;
        x2  = 0.5:1:(nc-0.5);
        
        x   = [];
        y   = [];
        
        ct  = 1;
        for i = 1:1:nr
            if mod(i,2) == 1
                x   = [x; x1'];
                y   = [y; ct*ones(length(x1),1)./sind(60)];
            else
                x   = [x; x2'];
                y   = [y; ct*ones(length(x2),1)./sind(60)];
            end
            ct  = ct + 1;
        end
        save(pfname_xymap, 'x', 'y')
    end
    
    imdata  = imdata';
    imdata  = imdata(:);
    
    %%% CREATE INTERPOLATION
    F   = TriScatteredInterp(x, y, imdata);
    
    %%% GENERATE SQUARE GRID
    dx  = (max(x) - min(x))/(opts.nxsq - 1);
    dy  = dx;
    xsq = min(x):dx:max(x);
    ysq = min(y):dy:max(y);
    
    [xsq, ysq]  = meshgrid(xsq, ysq);
    
    %%% MAP HEX GRID DATA TO SQUARE GRID
    csq = F(xsq, ysq);
    
    if strcmpi(opts.display, 'on')
        figure(1000)
        subplot(1,3,1)
        imagesc(log(imdata))
        axis equal
        
        subplot(1,3,2)
        scatter(x, y, 10, log(imdata))
        axis equal tight
        
        subplot(1,3,3)
        scatter(xsq(:), ysq(:), 10, log(csq(:)))
        axis equal tight
    end
elseif strcmpi(opts.version, 'pixi2')
    % read in image
    csq = double(imread(pfname));
    
    % ONLY CRRM MODE (PIXEL MODE) SUPPORTED - THIS IS GENERATED BASED ON pixirad_jul17 DATA
    % ct  = load(opts.pfname_ct);
    % ct  = ct.correction_map;
    % ct  = fliplr(ct);
    
    % ONLY CRRM MODE (PIXEL MODE) SUPPORTED - THIS IS FROM THE VENDOR
    ct  = imread('/home/beams/S1IDUSER/mnt/s1a/misc/pixirad2/usb.after_repair/Calibrations/2010_crrm.tif');
    ct  = fliplr(ct');
    
    bpt = imread(opts.pfname_bpt);
    % bpt = fliplr(bpt);
    
    if opts.apply_ct
        % csq = csq./ct;
        csq = csq.*ct;
    end 
    if opts.apply_bpt
        [x_bpt, y_bpt]      = find(bpt == 1);
        Vq                  = interp2(csq, x_bpt, y_bpt);
        for i = 1:1:length(x_bpt)
            csq(x_bpt(i), y_bpt(i))   = Vq(i);
        end
    end
end
