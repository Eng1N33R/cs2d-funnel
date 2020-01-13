
$ORIG_CGO_ENABLED = $env:CGO_ENABLED
$env:CGO_ENABLED = 0

$ORIG_GOOS = $env:GOOS
$env:GOOS = "linux"

go build -a -installsuffix cgo -o out/funnel src/funnel.go

$env:CGO_ENABLED = $ORIG_CGO_ENABLED
$env:GOOS = $ORIG_GOOS