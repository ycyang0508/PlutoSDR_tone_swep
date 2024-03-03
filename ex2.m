% Initialize Script

clear all;

clc;

fs = 1e6;

 

% Initialize SDR

sdrdev('Pluto');

 

% Initialize SDR Receiver Functionality

radio_rx = sdrrx('Pluto',...
    'RadioID',              'usb:0',...
    'CenterFrequency',      1e9,...
    'BasebandSampleRate',   fs,...
    'GainSource',           'AGC Fast Attack',...
    'OutputDataType',       'double',...
    'SamplesPerFrame',      20000);
 

% Initialize SDR Transmit Functionality

radio_tx = sdrtx('Pluto',...
    'RadioID',              'usb:0',...
    'CenterFrequency',      1e9,...
    'BasebandSampleRate',   fs,...
    'Gain',-10);

 

% Create a spectrum analyzer scope to visualize the signal spectrum

scope = dsp.SpectrumAnalyzer(...
    'Name',                 'Spectrum Analyzer',...
    'Title',                'Spectrum Analyzer', ...
    'SpectrumType',         'Power',...
    'FrequencySpan',        'Full', ...
    'SampleRate',           fs, ...
    'YLimits',              [-60,40],...
    'SpectralAverages',     10, ...
    'FrequencySpan',        'Start and stop frequencies', ...
    'StartFrequency',       -100e3, ...
    'StopFrequency',        100e3,...
    'Position',             figposition([20 10 60 60]));

 

% Create TX Chirp from 5KHz - 20KHz

chrp = dsp.Chirp;
chrp.SweepDirection = 'Unidirectional';
chrp.TargetFrequency = 20e3;
chrp.InitialFrequency = 5e3;
chrp.TargetTime = 1;
chrp.SweepTime = 1;
chrp.SamplesPerFrame = 5000;
chrp.SampleRate = fs;
tx_waveform = chrp();
freq = 5e3;
tx_waveform = exp(1i*2*pi*freq/fs*(1:20e3)).';
 

% Do an initial TX/RX so that tic/toc timing 

% works correctly in the main loop

radio_tx(tx_waveform);

data = radio_rx();

 

% Transmit/Receive for 20 seconds

disp('Starting Now');

runtime = tic;

while toc(runtime) < 20

    % Tx
    tx_waveform = exp(1i*2*pi*freq/fs*(1:20e3)).';
    freq = freq + 50;
    radio_tx(tx_waveform);

    

    % Receive a frame

    data = radio_rx();

    

    % Display the frame

    scope(data); 

 

end

 

% Release Pluto resources

release(radio_tx);

release(radio_rx);

disp('Done');
