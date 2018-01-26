@for %%i in (%1) do @if NOT "%%~$PATH:i"=="" @copy /Y "%%~$PATH:i" "C:\Users\Brian\AppData\Roaming\dub\packages\dmagick-0.2.1\dmagick\" 
