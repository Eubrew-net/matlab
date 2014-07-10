function [ dat_ag, tim_ag, nb_dat ] = tim_agreg( time, dat, tstp, mode )
%tim_agreg  agregates a time series with a specific time granularity
%
% [ dat_ag, tim_ag, nb_dat ] = tim_agreg( time, dat, tstp, mode )
%     averages the time series ( time, dat ) with a given time granularity
%     The time stepping or granularity (time bins) is indicated with
%     tstp for which 0:10 means bins 0<=t1<1, 1<=t2<2, 2<=t3<3, etc. The
%     time steps can be irregular. This routine can work simultaneously on
%     multiple rows or columns. NaN values are recognized and treated.
%
%   Note: this routine uses histmulti5 for its speed. In case histmulti5 is
%     not available this routine will not work
%
%   Inputs:
%     time  : time in datenum or datevec format (dim similar to dat)
%     dat   : data value of time series (dim similar to time, eventually
%             with multiple rows or columns).
%     tstp  : time steps indicating time granularity ([0 1] means 0<=t<1).
%     mode  : character string indicating how the function works:
%             low_t : tim_ag is given as 0.0 for bin [0 1]       (default)
%             mid_t : tim_ag is given as 0.5 for bin [0 1]
%             hig_t : tim_ag is given as 1.0 for bin [0 1]
%             ave   : dat_ag is the average in the time bin      (default)
%             sum   : dat_ag is the sum in the time bin
%             var   : dat_ag is the variance in the time bin
%                     note unbiased var estimator, i.e., 1 / ( n-1 )
%             max   : dat_ag is the maximum in the time bin
%             min   : dat_ag is the minimum in the time bin
%             exnan : excludes NaN values from computation       (default)
%             innan : includes NaN values in computation: NaN in bin -> NaN
%             NB multiple key words is OK: default = 'low_t ave exNaN'
%
%   Outputs:
%     dat_ag : agregated data (one dimension corresponds to tim_ag)
%     tim_ag : time stamps corresponding to time steps tstp, datenum format
%     nb_dat : number of data points in each bin (recognizes and treats NaN)

%     Laurent Vuilleumier  15-MAY-2006 Created
%     MeteoSwiss
%     Les Invuardes
%     CH-1530 Payerne.

% Initialization

% Time stamps arrangement
time_mode_lst = { 'low_t' 'mid_t' 'hig_t' };
time_mode = logical( [ 1 0 0 ] );
% Type of output
outp_mode_lst = { 'ave' 'sum' 'var' 'max' 'min' };
outp_mode = logical( [ 1 0 0 0 0 ] );
% NaN treatment
tnan_mode_lst = { 'exnan' 'innan' };
tnan_mode = logical( [ 1 0 ] );
% Rejects date that are not between [1900 1 1] and now
time_beg = 693962; %time_end = now + 365;
time_end=datenum(2200,1,1);   % 11 1 2011, JG, need to be more tolerant.

% Tests input

if nargin < 3,
    error('Not enough arguments')
end

siz_tim = size( time );
if ~isnumeric( time ),
    error( 'Time should be numeric' )
elseif length( siz_tim ) > 2,
    error( 'Time should either be a datevec array or a datenum vector' )
elseif siz_tim( 2 ) ~= 3 & siz_tim( 2 ) ~= 6 & length( time ) ~= prod( siz_tim ),
    error( 'Time should either be a datevec array or a datenum vector' )
end

if length( time ) ~= prod( siz_tim ),
    time = datenum( time );
    if any( time(:) < time_beg | time_end < time(:) ),
        error( 'Invalid time' );
    end
else
    if any( time(:) < time_beg | time_end < time(:) ),
        time = datenum( time );
    end
    if any( time(:) < time_beg | time_end < time(:) ),
        error( 'Invalid time' );
    end
end

time = time(:);

% Re-order time if necessary

l_sort = ~issorted( time );
if l_sort,
    [ time, tim_ord ] = sort( time );
end

% Search in time series data, which dimension correspond to time

siz_dat = size( dat );
idimt = find( siz_dat == length( time ) );
idimt2 = find( siz_tim == length( time ) );
if ~isnumeric( dat ),
    error( 'Time series data values should be numeric' )
elseif length( idimt ) < 1,
    error( 'Incompatible size of time and time series values' )
elseif length( idimt ) > 1,
    if length( idimt2 ) == 1 & any( idimt2 == idimt ),
        idimt = idimt2;
    else
        error( 'Cannot find time dimension' )
    end
end

% Permute time series data dimension in order to get time aligned with
% dimension 1.

if idimt ~= 1,
    iper = 1 : length( siz_dat ); iper( idimt ) = []; iper = [ idimt iper ];
    dat = permute( dat, iper );
end

dat = dat( :, : );

if l_sort,
    dat = dat( tim_ord, : );
end

if any( isnan( time ) ),
    warning( 'NaN times were excluded from dataset' )
    ind = isnan( time );
    time( ind ) = [];
    dat( ind, : ) = [];
end

siz_tsp = size( tstp );
if ~isnumeric( tstp ),
    error( 'Time steps should be numeric' )
elseif length( siz_tsp ) > 2,
    error( 'Time steps should either be a datevec array or a datenum vector' )
elseif siz_tsp( 2 ) ~= 3 & siz_tsp( 2 ) ~= 6 & length( tstp ) ~= prod( siz_tsp ),
    error( 'Time steps should either be a datevec array or a datenum vector' )
end

if length( tstp ) ~= prod( siz_tsp ),
    tstp = datenum( tstp );
    if any( tstp(:) < time_beg | time_end < tstp(:) ),
        error( 'Invalid time steps' );
    end
else
    if any( tstp(:) < time_beg | time_end < tstp(:) ),
        tstp = datenum( tstp );
    end
    if any( tstp(:) < time_beg | time_end < tstp(:) ),
        error( 'Invalid time steps' );
    end
end

len_tstp = length( tstp );
if any( isnan( tstp ) ),
    warning( 'NaN time steps were excluded from dataset' )
    ind = isnan( tstp );
    tstp( ind ) = [];
end

if ~issorted( tstp ),
    tstp = sort( tstp );
    warning( 'Time steps were not ordered' )
end

tstp = tstp(:);

% Decodes key words

if nargin > 3,
    if ~ischar( mode ),
        error( 'Mode should be a character string' );
    end
    givmode = cellstr( words_luv( lower( mode ) ) );
    ti_mode = strcmp( repmat( givmode, size( time_mode_lst ) ),...
        repmat( time_mode_lst, size( givmode ) ) );
    ou_mode = strcmp( repmat( givmode, size( outp_mode_lst ) ),...
        repmat( outp_mode_lst, size( givmode ) ) );
    tn_mode = strcmp( repmat( givmode, size( tnan_mode_lst ) ),...
        repmat( tnan_mode_lst, size( givmode ) ) );
    all_mode = [ ti_mode ou_mode tn_mode ];
    ti_mode = any( ti_mode, 1 );
    tn_mode = any( tn_mode, 1 );
    ou_mode = any( ou_mode, 1 );
    for i_mode = 1: length( givmode ),
        if ~any( all_mode( i_mode, : ) ),
            error( [ 'unrecognized mode /' givmode{ i_mode } '/'] )
        end
    end
    if any( ti_mode ), ti_mode = find( ti_mode ); else ti_mode = find( time_mode ); end
    if any( ou_mode ), ou_mode = find( ou_mode ); else ou_mode = find( outp_mode ); end
    if any( tn_mode ), tn_mode = find( tn_mode ); else tn_mode = find( tnan_mode ); end
else
    ti_mode = find( time_mode );
    ou_mode = find( outp_mode );
    tn_mode = find( tnan_mode );
end

% Tests completed, real work starts here

% Computes time stamps

switch ti_mode
    case 1,
        % begining of time step
        tim_ag = tstp( 1 : end - 1 );
    case 2,
        % middle of time step
        tim_ag = 0.5 * ( tstp( 1 : end - 1 ) + tstp( 2 : end ) );
    case 3,
        % end of time step
        tim_ag = tstp( 2 : end );
    otherwise
        error( 'unrecognized time mode' )
end

% Attributes times to time steps (uses histmulti5 for its speed)

nb_el_pbin = histmulti5( time, [ -inf; tstp ] );
cs_nb_el_pbin = [ 0; cumsum( nb_el_pbin ) ];

if nb_el_pbin( 1 ) > 0,
   % warning( 'Some data correspond to time before first time step' );
    time( 1 : nb_el_pbin( 1 ) ) = [];
    dat( 1 : nb_el_pbin( 1 ), : ) = [];
end
nb_el_pbin( 1 ) = []; cs_nb_el_pbin( 1 ) = [];
if nb_el_pbin( end ) > 0,
  %  warning( 'Some data correspond to time after last time step' );
    time( end - nb_el_pbin( end ) + 1 : end ) = [];
    dat( end - nb_el_pbin( end ) + 1 : end, : ) = [];
end
nb_el_pbin( end ) = []; cs_nb_el_pbin( end ) = [];

% Creates a bidimensional array of time indices with columns corresponding
% to time bins

nb_bin = length( nb_el_pbin );
ind = repmat( NaN, max( nb_el_pbin ), length( nb_el_pbin ) );
for i_bin = 1 : nb_bin
    ind( 1 : nb_el_pbin( i_bin ), i_bin ) =...
        ( cs_nb_el_pbin( i_bin ) + 1 : cs_nb_el_pbin( i_bin + 1 ) )';
end
ind_val = ~isnan( ind );

% Treats the data in each time series

dat_ag = repmat( NaN, nb_bin, size( dat, 2 ) );
if ou_mode < 4,
    dat_t = repmat( 0, size( ind ) );
else
    dat_t = repmat( NaN, size( ind ) );
end
nb_dat = sum( ind_val );
for i_dat = 1 : size( dat, 2 ),
    dat_t( ind_val ) = dat( :, i_dat );
    if ou_mode < 4 & tn_mode < 2,
        i_nan = isnan( dat_t );
        dat_t( i_nan ) = 0;
        nb_val = nb_dat - sum( i_nan );
    else
        i_nan = false( size( dat_t ) );
        nb_val = nb_dat;
    end
    nb_val( nb_val < 1 ) = NaN;
    switch ou_mode
        case 1,
            % average
            dat_ag( :, i_dat ) = sum( dat_t ) ./ nb_val;
        case 2,
            % sum
            dat_ag( :, i_dat ) = sum( dat_t );
        case 3,
            % variance
            dum = repmat( sum( dat_t ) ./ nb_val , size( dat_t, 1 ), 1 );
            dum( ~ind_val | i_nan ) = 0;
            dat_ag( :, i_dat ) = sum( ( dat_t - dum ).^2 ) ./ (nb_val - 1);
        case 4,
            % maximum
            dat_ag( :, i_dat ) = max( dat_t );
        case 5,
            % minimum
            dat_ag( :, i_dat ) = min( dat_t );
        otherwise
            error( 'unrecognized ouput mode' )
    end
end

% Reshape and resize output if needed

if idimt ~= 1,
    dat_ag = ipermute( dat_ag, iper );
    if nargout > 2,
        nb_dat = ipermute( nb_dat, iper );
    end
end
if length( idimt2 ) == 1 & idimt ~= 1,
    iper = 1 : idimt2; iper( 1 ) = idimt2; iper( idimt2 ) = 1;
    tim_ag = permute( tim_ag, iper );
end
