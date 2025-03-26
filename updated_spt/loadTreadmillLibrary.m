function loadTreadmillLibrary()
    loadlibrary('treadmill_remote.dll', @treadmill_proto) % libname == 'treadmill_remote"
    disp('Treadmill library loaded')
end