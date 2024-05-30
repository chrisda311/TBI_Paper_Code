function data=bandpass_filter_single_channel(data,low, high, fs,n)

[A,B] = butter(n,[low/(fs/2) high/(fs/2)]);

data=filtfilt(A,B,data);
