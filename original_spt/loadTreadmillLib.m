function loadTreadmillLib()
    %eml.extrinsic('loadlibrary');
    loadlibrary('treadmill-remote.dll','treadmill-remote.h','alias','treadmillremote');
    disp('library loaded')
end