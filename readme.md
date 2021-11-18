# Eco conception as a backend developer

## Implementations

- [Golang](./golang/) server implementation (http + mux)
- [Java](./java/) server implementation (spring boot)
- [NodeJs](./nodejs/) server implementation (express)
- [PHP](./php/) server implementation (laravel)
- [Python](./python/) server implementation (flask)
- [Rust](./rust/) server implementation (actix-web)

## Running the benchmark

You will require a linux machine (I didn't try in a VM nor with Docker Desktop) compatible with powercap and Docker installed.

```bash
# you need root to access the powercal informations
sudo ./scripts/all.sh
```

and then wait, it can take more than a day...

You'll find the results in the `results` folder when everything is done.
