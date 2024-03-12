function cropMembraneImages(varargin)
%CROPMEMBRANEIMAGES  Interactively crops images of microarray membranes
%
%  CROPMEMBRANEIMAGES will open the File Selection dialog box to select the
%  image or images of interest. Multiple image files can be selected by
%  pressing CTRL (or CMD on a Mac) and clicking on the individual files.
%  Multiple instances of membranes can then be selected, one at a time. The
%  membranes will then be saved in the same input folder.
%
%  CROPMEMBRANEIMAGES(FILES) will process the specified files. FILES must
%  be either a single character array or a cell array of strings. The
%  string(s) should specify the path and the filename(s) to be processed.
%  If using a cell array of strings, each file path should be in its own
%  cell.
%
%  During the cropping procedure, the pointer will change into cross hairs
%  when you move it over the image. Using the mouse, specify the crop
%  rectangle by clicking and dragging the mouse. You can move or resize the
%  crop rectangle using the mouse. When you are finished sizing and
%  positioning the crop rectangle, create the cropped image by
%  double-clicking the left mouse button. You can also choose Crop Image
%  from the context menu. When you are done cropping membrane images, close
%  the figure window.
%
%  See also IMCROP

%  This toolbox was written by Dr. Jian Wei Tay (jian.tay@colorado.edu) at
%  the BioFrontiers Institute, University of Colorado Boulder.

%Validate the input
if numel(varargin) == 0

    [files, fpath] = uigetfile({'*.tif;*.tiff', 'TIFF files (*.tif; *.tiff)'; ...
        '*.*', 'All files (*.*)'}, 'Select image(s) to crop', 'MultiSelect', 'on');

    if isequal(files, 0)
        %Operation cancelled. Quit running.
        return;
    end

    if ~iscell(files)
        files = {files};
    end

    for iFile = 1:numel(files)
        files{iFile} = fullfile(fpath, files{iFile});
    end

elseif numel(varargin) > 1

    if ~iscell(varargin{1})
        files = {varargin{1}}; %#ok<NASGU>
    end

else
    error('cropMembraneImages:TooManyInputs', ...
        'Too many input arguments.')
end

%% Process the files

for iFile = 1:numel(files)

    I = imread(files{iFile});

    fileCtr = 0;  %Reset sub-file counter

    isDone = false;

    %Display image for cropping
    imshow(I)

    while ~isDone

        %Generate output image name
        [fpath, fname, fext] = fileparts(files{iFile});

        %Title the window folder
        title([fname, fext, ' - Currently cropping image ', int2str(fileCtr + 1)], ...
            'Interpreter', 'None')

        Icrop = imcrop;

        if isempty(Icrop)
            %If window is closed, Icrop will be empty
            break;
        end

        fileCtr = fileCtr + 1;

        %Create a new cropped folder if needed
        fpath = fullfile(fpath, 'cropped');
        if ~exist(fpath, 'dir')
            mkdir(fpath);
        end

        fname = [fname, '_m', int2str(fileCtr)];

        imwrite(Icrop, fullfile(fpath, [fname, fext]), ...
            'Compression', 'none');
    end

end


