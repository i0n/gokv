# gokv

- **Deployment available at:** https://gokv.i0n.io
- **CI:** https://app.circleci.com/pipelines/github/i0n/gokv
- **Docker image:** https://hub.docker.com/repository/docker/i0nw/gokv

To run locally you will need go and/or docker.

    make run

or
  
	make docker-run

## API:

Create:

    curl -X POST \
      -H 'Content-Type: application/json' \
      -d '{"value":"Chris"}' \
      localhost:8080/keys

Read (One):

    curl \
      -H 'Content-Type: application/json' \
      localhost:8080/keys/1

Read (All):

    curl \
      -H 'Content-Type: application/json' \
      localhost:8080/keys

Update:

    curl -X PUT \
          -H 'Content-Type: application/json' \
          -d '{"value":"Sharma"}' \
          localhost:8080/keys/1

Delete:

    curl -X DELETE \
          -H 'Content-Type: application/json' \
          localhost:8080/keys/1

  

## Tests:

    make test-unit
    make test-integration
    make docker-test-functional



