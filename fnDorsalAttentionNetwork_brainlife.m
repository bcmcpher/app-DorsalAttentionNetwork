function [ pconn, rois, conn, indx ] = fnDorsalAttentionNetwork_brainlife(fe, labels, nclust, cacheDir)
% fnBuildNetworks creates all the network data from any fit fe and parcellation.
%
% INPUTS: all inputs are strings
%
%   fe       - string containing path name to .mat containing only a fit fe structure
%   labels   - string containing path to nifti of labeled ROIs
%   fa       - string containing path to fa volume for tract profiles
%   output   - string containing path to .mat to save network data
%   nclust   - number of cores for parpool
%   cacheDir - where parpool can be opened from qsub
%

%% load files

display('Loading data...');

% load fe structure
load(fe);

% extract all needed out of FE
fg               = feGet(fe,   'fg acpc'); 
fascicle_length  = fefgGet(fg, 'length');
fascicle_weights = feGet(fe,   'fiber weights');
%nTheta           = feGet(fe,   'nbvals');
%M                = feGet(fe,   'model');
%measured_dsig    = feGet(fe,   'dsigdemeaned by voxel');

clear fe

%% start parallel pool

display(['Opening parallel pool with ', num2str(nclust), ' cores...']);

% create parallel cluster object
clust = parcluster;

% set number of cores from arguments
clust.NumWorkers = nclust;

% set temporary cache directory
tmpdir = tempname(cacheDir);

% make cache dir
OK = mkdir(tmpdir);

% check and set cachedir location
if OK
    % set local storage for parpool
    clust.JobStorageLocation = tmpdir;
end

% start parpool - close parpool at end of fxn
pool = parpool(clust, nclust, 'IdleTimeout', 120);

clear tmpdir OK

%% create networks

display('Assigning labels...');

% assign streamline endpoints to labeled volume
[ pconn, rois ] = feCreatePairedConnections(labels, fg.fibers, fascicle_length, fascicle_weights);

% run virtual lesion
%pconn = feVirtualLesionPairedConnections(M, fascicle_weights, measured_dsig, nTheta, pconn, 'nzw');

%% find if the connections are empty

disp('');
disp('Finding connections...');

% pull the indices of the requested connections
[ indx(1), conn{1} ] = fnFindConnection(fg, pconn, 'nzw', 247, 250);
[ indx(2), conn{2} ] = fnFindConnection(fg, pconn, 'nzw', 102, 40);
[ indx(3), conn{3} ] = fnFindConnection(fg, pconn, 'nzw', 247, 242);
[ indx(4), conn{4} ] = fnFindConnection(fg, pconn, 'nzw', 102, 85);
[ indx(5), conn{5} ] = fnFindConnection(fg, pconn, 'nzw', 250, 242);
[ indx(6), conn{6} ] = fnFindConnection(fg, pconn, 'nzw', 40, 85);

disp('Connections found.');
disp('');

% print the number of streamlines for a sanity check
disp(['From lh-PITd to lh-IPS there are ' num2str(size(conn{1}.fibers, 1)) ' streamlines.']);
disp(['From rh-PITd to rh-IPS there are ' num2str(size(conn{2}.fibers, 1)) ' streamlines.']);
disp(['From lh-PITd to lh-FEF there are ' num2str(size(conn{3}.fibers, 1)) ' streamlines.']);
disp(['From rh-PITd to rh-FEF there are ' num2str(size(conn{4}.fibers, 1)) ' streamlines.']);
disp(['From lh-IPS  to lh-FEF there are ' num2str(size(conn{5}.fibers, 1)) ' streamlines.']);
disp(['From rh-IPS  to rh-FEF there are ' num2str(size(conn{6}.fibers, 1)) ' streamlines.']);

% remove parallel pool
delete(pool);

end
