# HISS Radiology Classifier

## Update

    vapor clean -y
    rm -rf classifier.xcodeproj
    vapor xcode -y --verbose

## Build 

    vapor build --release
    
## Run 

    .build/release/Run serve --env production

