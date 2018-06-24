# HISS Radiology Classifier

## Update

    vapor clean -y
    rm -rf classifier.xcodeproj
    vapor xcode -y --verbose

## Build 

    vapor build --release --verbose
    
## Run 

    .build/release/Run serve --env production

Open http://localhost:8080/index.html 
