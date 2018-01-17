function [] = main()

disp('Loading paths...')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/fine'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))

% load my own config.json
config = loadjson('config.json');

% create output directory
mkdir('output');

% create cache dir
mkdir('cache');

% create the labels
labels = feInflateLabels(config.shen, 3, 'vert', './output/shen278_labels.nii.gz');

% run the network generation process
[ pconn, rois, conn, indx ] = fnDorsalAttentionNetwork_brainlife(config.fe, labels, 4, './cache');

% save the outputs
save('output/conn.mat', 'conn');
save('output/indx.mat', 'ind');
save('output/pconn.mat', 'pconn');
save('output/rois.mat', 'rois');

