function fname = spmup_resize(P,bb,vs)

% routine that resize an image to match the desired bounding box and voxel
% size
%
% FORMAT: fname = spmup_resize(P,bb,vs)
% IMPUT:  P is a cell string with images to resize (see spm_select)
%         bb is the bounding box (default is [-78 -112 -70; 78 76 86])
%         vs is the voxel size (default is [2 2 2])
%
% OUTPUT fname is the name of the file
%
% Cyril Pernet - The university of Edinburgh
% -----------------------------------------------------------------------
% Copyright (C) spmup team 2016

if nargin ==0
    help spmup_resize
    return
end

% defaults
if nargin == 1
    bb = [-78 -112 -70; 78 76 86];
    vs = [2 2 2];
end

% resize
vols = spm_vol(P);
for v=1:size(vols,1)
    V = vols(v);
    bbmn = bb(1,:);
    bbmx = bb(2,:);
    newdim = [length(bbmn(1):vs(1):bbmx(1)) length(bbmn(2):vs(2):bbmx(2)) length(bbmn(3):vs(3):bbmx(3))];
    
    if any(V.dim~=newdim)
        % voxel [1 1 1] of output should map to BB mn
        % (the combination of matrices below first maps [1 1 1] to [0 0 0])
        mat = spm_matrix([bbmn 0 0 0 vs])*spm_matrix([-1 -1 -1]);
        % voxel-coords of BB mx gives number of voxels required (now round up)
        imgdim = abs(ceil(mat \ [bbmx 1]')');
        if spm_flip_analyze_images; mat = diag([-1 1 1 1])*mat; end;
        
        % reflect in x if required
        
        % output image
        V0            = V;
        [pth,nam,ext] = fileparts(V0.fname);
        fname{v}      = fullfile(pth,['r' nam ext]);
        V0.fname      = fname{v};
        V0.dim(1:3)   = imgdim(1:3);
        V0.mat        = mat;
        V0 = spm_create_vol(V0);
        for i = 1:imgdim(3)
            M = inv(spm_matrix([0 0 -i])*inv(V0.mat)*V.mat);
            img = spm_slice_vol(V, M, imgdim(1:2), 1);
            spm_write_plane(V0, img, i);
        end
    else
        disp('dimension alreay match - nothing done')
    end
end
