bin:
	go build -a -installsuffix cgo -o out/funnel src/funnel.go

docker: bin
	docker build -t cs2d-funnel:latest .

clean:
	rm out/funnel